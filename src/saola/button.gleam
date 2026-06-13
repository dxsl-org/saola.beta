//// Button widget — one shared `ButtonConfig` consumed through two styles:
////
//// Builder style (pipe setters):
//// ```gleam
//// button.new()
//// |> button.variant(button.Outline)
//// |> button.icon_end(lc.arrow_right([]))
//// |> button.loading(model.saving)
//// |> button.view("Save", Some(SaveClicked))
//// ```
////
//// Config style (record update):
//// ```gleam
//// button.view(
////   button.ButtonConfig(..button.default_config(), loading: model.saving),
////   "Save",
////   Some(SaveClicked),
//// )
//// ```
////
//// Render-as is decided by the terminal call, never by config:
//// `view` renders `<button>` (requires `Option(msg)`),
//// `view_anchor` renders `<a>` (requires `href`).

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

import saola/icon/lx
import saola/spinner

pub type ButtonVariant {
  Primary
  Secondary
  Outline
  Ghost
  Link
  Destructive
}

pub type ButtonSize {
  Large
  Small
}

pub type ButtonAria {
  ButtonAria(label: String, expanded: Option(Bool))
}

pub type ButtonRoleType {
  /// Render as type='button'
  Regular
  /// Render as type='submit'
  Submit
  /// Render as type='reset'
  Reset
}

/// All presentation options shared by `view` (<button>) and `view_anchor` (<a>).
///
/// Public (not opaque) so both access styles work: record update
/// `ButtonConfig(..default_config(), loading: True)` and pipe setters
/// `new() |> loading(True)`.
///
/// - `loading`: renders a spinner in place of `icon_start`, sets
///   `aria-busy="true"`, and blocks interaction (disabled / aria-disabled).
/// - `type_`: only meaningful for `view`; `view_anchor` ignores it.
/// - `class`: appended after the Basecoat variant class — additive only,
///   the default class cannot be removed.
pub type ButtonConfig(msg) {
  ButtonConfig(
    variant: ButtonVariant,
    size: ButtonSize,
    icon_start: Option(Element(msg)),
    icon_end: Option(Element(msg)),
    loading: Bool,
    disabled: Bool,
    type_: Option(ButtonRoleType),
    aria: ButtonAria,
    class: String,
  )
}

pub const default_aria = ButtonAria("", None)

/// Builder entry point. Defaults: Primary, Large, no icons, not loading,
/// not disabled, no type attribute, empty aria, no extra class.
pub fn new() -> ButtonConfig(msg) {
  ButtonConfig(
    variant: Primary,
    size: Large,
    icon_start: None,
    icon_end: None,
    loading: False,
    disabled: False,
    type_: None,
    aria: default_aria,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax:
/// `ButtonConfig(..default_config(), disabled: True)`.
pub fn default_config() -> ButtonConfig(msg) {
  new()
}

// --- Builder setters ---

/// Set the visual variant (Primary, Secondary, Outline, Ghost, Link, Destructive).
pub fn variant(
  config: ButtonConfig(msg),
  variant: ButtonVariant,
) -> ButtonConfig(msg) {
  ButtonConfig(..config, variant: variant)
}

/// Set the size (Large, Small).
pub fn size(config: ButtonConfig(msg), size: ButtonSize) -> ButtonConfig(msg) {
  ButtonConfig(..config, size: size)
}

/// Icon rendered before the label. Replaced by a spinner while `loading`.
pub fn icon_start(
  config: ButtonConfig(msg),
  icon: Element(msg),
) -> ButtonConfig(msg) {
  ButtonConfig(..config, icon_start: Some(icon))
}

/// Icon rendered after the label.
pub fn icon_end(
  config: ButtonConfig(msg),
  icon: Element(msg),
) -> ButtonConfig(msg) {
  ButtonConfig(..config, icon_end: Some(icon))
}

/// Loading state: spinner replaces `icon_start`, `aria-busy="true"` is set,
/// and the button is non-interactive while True. The consumer owns the Bool
/// (widgets are stateless).
pub fn loading(config: ButtonConfig(msg), loading: Bool) -> ButtonConfig(msg) {
  ButtonConfig(..config, loading: loading)
}

/// Disabled state. On `view` this is the native `disabled` attribute; on
/// `view_anchor` it maps to `aria-disabled="true"` + `tabindex="-1"`.
pub fn disabled(config: ButtonConfig(msg), disabled: Bool) -> ButtonConfig(msg) {
  ButtonConfig(..config, disabled: disabled)
}

/// Form role (`type="button" | "submit" | "reset"`). `view_anchor` ignores it.
pub fn type_(
  config: ButtonConfig(msg),
  role: ButtonRoleType,
) -> ButtonConfig(msg) {
  ButtonConfig(..config, type_: Some(role))
}

/// ARIA attributes (label, expanded).
pub fn aria(config: ButtonConfig(msg), aria: ButtonAria) -> ButtonConfig(msg) {
  ButtonConfig(..config, aria: aria)
}

/// Append an extra CSS class after the Basecoat variant class.
/// Additive only — the default class cannot be removed.
pub fn add_class(config: ButtonConfig(msg), class: String) -> ButtonConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ButtonConfig(..config, class: merged)
}

// --- Terminals ---

/// Render as `<button>`. Use for in-page actions (dialogs, toggles, submits).
/// `on_click` is omitted from the DOM while `disabled` or `loading`.
/// `loading` uses `aria-disabled` instead of native `disabled` so the button
/// stays in the accessibility tree and `aria-busy` remains announceable.
pub fn view(
  config: ButtonConfig(msg),
  label: String,
  on_click: Option(msg),
) -> Element(msg) {
  let interactive = !config.disabled && !config.loading
  let click_attrs = case on_click {
    Some(msg) if interactive -> [e.on_click(msg)]
    _ -> []
  }
  let disabled_attrs = case config.disabled, config.loading {
    True, _ -> [a.disabled(True)]
    False, True -> [a.attribute("aria-disabled", "true")]
    False, False -> []
  }
  let type_attrs = case config.type_ {
    None -> []
    Some(Regular) -> [a.type_("button")]
    Some(Submit) -> [a.type_("submit")]
    Some(Reset) -> [a.type_("reset")]
  }
  h.button(
    list.flatten([
      [a.class(css_class(config))],
      busy_attrs(config),
      click_attrs,
      disabled_attrs,
      type_attrs,
      aria_attrs(config),
    ]),
    content(config, label),
  )
}

/// Render as `<a href>` styled as a button. Use when the action navigates
/// to a URL. `disabled`/`loading` map to `aria-disabled` + `tabindex="-1"`
/// (anchors have no native disabled). `config.type_` is ignored.
pub fn view_anchor(
  config: ButtonConfig(msg),
  label: String,
  href: String,
) -> Element(msg) {
  let non_interactive_attrs = case config.disabled || config.loading {
    True -> [
      a.attribute("aria-disabled", "true"),
      a.attribute("tabindex", "-1"),
    ]
    False -> []
  }
  h.a(
    list.flatten([
      [a.class(css_class(config)), a.href(href)],
      busy_attrs(config),
      non_interactive_attrs,
      aria_attrs(config),
    ]),
    content(config, label),
  )
}

// --- Internal rendering helpers ---

fn css_class(config: ButtonConfig(msg)) -> String {
  let base = case config.size, config.variant {
    Large, Primary -> "btn-lg-primary"
    Large, Secondary -> "btn-lg-secondary"
    Large, Outline -> "btn-lg-outline"
    Large, Ghost -> "btn-lg-ghost"
    Large, Link -> "btn-lg-link"
    Large, Destructive -> "btn-lg-destructive"
    Small, Primary -> "btn-sm-primary"
    Small, Secondary -> "btn-sm-secondary"
    Small, Outline -> "btn-sm-outline"
    Small, Ghost -> "btn-sm-ghost"
    Small, Link -> "btn-sm-link"
    Small, Destructive -> "btn-sm-destructive"
  }
  case config.class {
    "" -> base
    extra -> base <> " " <> extra
  }
}

fn busy_attrs(config: ButtonConfig(msg)) -> List(a.Attribute(msg)) {
  case config.loading {
    True -> [a.attribute("aria-busy", "true")]
    False -> []
  }
}

fn aria_attrs(config: ButtonConfig(msg)) -> List(a.Attribute(msg)) {
  let label_attrs = case config.aria.label {
    "" -> []
    l -> [a.aria_label(l)]
  }
  let expanded_attrs = case config.aria.expanded {
    None -> []
    Some(expanded) -> [a.aria_expanded(expanded)]
  }
  list.flatten([label_attrs, expanded_attrs])
}

fn content(config: ButtonConfig(msg), label: String) -> List(Element(msg)) {
  let lead = case config.loading {
    True -> spinner.spinner(spinner.Small, "")
    False -> option.unwrap(config.icon_start, element.none())
  }
  let label_el = case string.trim(label) {
    "" -> element.none()
    text -> h.text(text)
  }
  let trail = option.unwrap(config.icon_end, element.none())
  [lead, label_el, trail]
}

// --- Convenience shortcuts ---

pub fn button_primary(label: String, click_message: msg) -> Element(msg) {
  new() |> view(label, Some(click_message))
}

pub fn button_secondary(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Secondary) |> view(label, Some(click_message))
}

pub fn button_outline(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Outline) |> view(label, Some(click_message))
}

pub fn button_ghost(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Ghost) |> view(label, Some(click_message))
}

pub fn button_destructive(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Destructive) |> view(label, Some(click_message))
}

/// Submit button (type="submit"). Use inside a <form>.
pub fn button_submit(label: String) -> Element(msg) {
  new() |> type_(Submit) |> view(label, None)
}

/// Small icon-only close button (×) with an accessible "Close" label.
pub fn button_close(click_message: msg) -> Element(msg) {
  new()
  |> variant(Outline)
  |> size(Small)
  |> icon_start(lx.x([]))
  |> aria(ButtonAria("Close", None))
  |> view("", Some(click_message))
}

// --- Anchor shortcuts ---

/// Primary button rendered as `<a href>`. Use for navigation URLs.
pub fn button_primary_anchor(label: String, href: String) -> Element(msg) {
  new() |> view_anchor(label, href)
}

/// Secondary button rendered as `<a href>`. Use for navigation URLs.
pub fn button_secondary_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Secondary) |> view_anchor(label, href)
}

/// Outline button rendered as `<a href>`. Use for navigation URLs.
pub fn button_outline_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Outline) |> view_anchor(label, href)
}

/// Ghost button rendered as `<a href>`. Use for navigation URLs.
pub fn button_ghost_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Ghost) |> view_anchor(label, href)
}
