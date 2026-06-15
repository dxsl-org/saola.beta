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
////
//// ## Customizing styles
////
//// `src/saola/button.css` is `@generated` from Basecoat — do not edit it
//// (`just build-css` overwrites it). Customize from your own CSS in one of
//// three layers, least to most invasive:
////
//// 1. **Theme tokens** — recolor/reshape every widget at once:
////    ```css
////    :root { --color-primary: oklch(0.55 0.22 263); --radius-md: 0.25rem; }
////    ```
//// 2. **Per-widget override** — target the Basecoat class. All Saola CSS lives
////    in `@layer saola.*`, so any unlayered rule of yours wins — no
////    `!important`, no specificity battle:
////    ```css
////    .btn-lg-primary { background: #ff5722; text-transform: uppercase; }
////    ```
//// 3. **One-off** — `add_class` appends a class after the variant class:
////    ```gleam
////    button.new() |> button.add_class("w-full") |> button.view("Save", Some(Msg))
////    ```
//// 4. **Custom accent (typed, in-Gleam)** — `accent` recolors the solid look by
////    overriding `--color-primary` inline; Basecoat's hover/focus follow. Point
////    it at a theme token to stay theme-coherent:
////    ```gleam
////    button.new()
////    |> button.accent(button.Accent("var(--chart-2)", "var(--background)"))
////    |> button.view("Brand", Some(Msg))
////    ```

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
  Medium
  Large
  Small
}

pub type ButtonAria {
  ButtonAria(label: String, expanded: Option(Bool))
}

/// Custom accent color for the SOLID look. Overrides the `--color-primary`
/// pair inline so Basecoat's existing background / hover (`color-mix`) / focus
/// machinery recolors itself — no parallel CSS. `bg`/`fg` accept any CSS color
/// (`oklch(...)`, `#hex`) or a theme token reference (`var(--chart-2)`), which
/// keeps custom colors sourced from the active theme.
pub type Accent {
  Accent(bg: String, fg: String)
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
/// - `before`/`after`: arbitrary children rendered before / after the label
///   (an icon, a badge, several elements). `icon_start`/`icon_end` are
///   single-element shortcuts over these. The loading spinner and the
///   "loaded" check are nothing special — just elements you place in a slot.
/// - `loading`: replaces the `before` slot with a spinner, sets
///   `aria-busy="true"`, and blocks interaction (disabled / aria-disabled).
/// - `type_`: only meaningful for `view`; `view_anchor` ignores it.
/// - `class`: appended after the Basecoat variant class — additive only,
///   the default class cannot be removed.
pub type ButtonConfig(msg) {
  ButtonConfig(
    variant: ButtonVariant,
    size: ButtonSize,
    before: List(Element(msg)),
    after: List(Element(msg)),
    loading: Bool,
    disabled: Bool,
    type_: Option(ButtonRoleType),
    aria: ButtonAria,
    accent: Option(Accent),
    class: String,
  )
}

pub const default_aria = ButtonAria("", None)

/// Builder entry point. Defaults: Primary, Medium, no children, not loading,
/// not disabled, no explicit type (renders `type="button"`), empty aria, no
/// extra class.
pub fn new() -> ButtonConfig(msg) {
  ButtonConfig(
    variant: Primary,
    size: Medium,
    before: [],
    after: [],
    loading: False,
    disabled: False,
    type_: None,
    aria: default_aria,
    accent: None,
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

/// Set the size (Medium — default, Large, Small).
pub fn size(config: ButtonConfig(msg), size: ButtonSize) -> ButtonConfig(msg) {
  ButtonConfig(..config, size: size)
}

/// Children rendered before the label (icon, badge, spinner, several
/// elements). Replaced by a spinner while `loading`.
pub fn before(
  config: ButtonConfig(msg),
  children: List(Element(msg)),
) -> ButtonConfig(msg) {
  ButtonConfig(..config, before: children)
}

/// Children rendered after the label.
pub fn after(
  config: ButtonConfig(msg),
  children: List(Element(msg)),
) -> ButtonConfig(msg) {
  ButtonConfig(..config, after: children)
}

/// Single-icon shortcut for `before` — `icon_start(x)` == `before([x])`.
pub fn icon_start(
  config: ButtonConfig(msg),
  icon: Element(msg),
) -> ButtonConfig(msg) {
  before(config, [icon])
}

/// Single-icon shortcut for `after` — `icon_end(x)` == `after([x])`.
pub fn icon_end(
  config: ButtonConfig(msg),
  icon: Element(msg),
) -> ButtonConfig(msg) {
  after(config, [icon])
}

/// Loading state: a spinner replaces the `before` slot, `aria-busy="true"` is
/// set, and the button is non-interactive while True. The consumer owns the
/// Bool (widgets are stateless). A "loaded" look is just a check element placed
/// in `before` once loading clears — no dedicated state needed; Basecoat's
/// `transition: all` smooths the loading → loaded → idle hand-off.
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

/// Custom accent color for the solid look — see `Accent`. Best with the
/// default `Primary` variant; on outline/ghost the override is inert because
/// those variants don't read `--color-primary` for their fill.
pub fn accent(config: ButtonConfig(msg), accent: Accent) -> ButtonConfig(msg) {
  ButtonConfig(..config, accent: Some(accent))
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
  // Default to type="button": a <button> with no type is type="submit" per
  // HTML, so an unset button inside a <form> would submit it unintentionally.
  let type_attrs = case config.type_ {
    None | Some(Regular) -> [a.type_("button")]
    Some(Submit) -> [a.type_("submit")]
    Some(Reset) -> [a.type_("reset")]
  }
  h.button(
    list.flatten([
      [a.class(css_class(config, label))],
      accent_attrs(config),
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
/// to a URL. `config.type_` is ignored.
///
/// When `disabled`/`loading`, the `href` is **omitted** (alongside
/// `aria-disabled="true"` + `tabindex="-1"`): anchors have no native disabled
/// and `aria-disabled` is advisory only, so keeping `href` would leave the
/// link mouse-clickable and still navigating. No `href` = not a hyperlink =
/// genuinely inert, while `aria-disabled` keeps it announced to screen readers.
pub fn view_anchor(
  config: ButtonConfig(msg),
  label: String,
  href: String,
) -> Element(msg) {
  let non_interactive = config.disabled || config.loading
  let href_attrs = case non_interactive {
    True -> []
    False -> [a.href(href)]
  }
  let non_interactive_attrs = case non_interactive {
    True -> [a.attribute("aria-disabled", "true"), a.attribute("tabindex", "-1")]
    False -> []
  }
  h.a(
    list.flatten([
      [a.class(css_class(config, label))],
      href_attrs,
      accent_attrs(config),
      busy_attrs(config),
      non_interactive_attrs,
      aria_attrs(config),
    ]),
    content(config, label),
  )
}

// --- Internal rendering helpers ---

/// Build the Basecoat class. An empty label with a lead element (icon_start
/// or the loading spinner) is an icon-only button and uses Basecoat's square
/// `-icon-` variant (e.g. `btn-sm-icon-outline`) instead of the text-padded
/// variant — otherwise the button has no text to size against and renders
/// mis-shapen.
fn css_class(config: ButtonConfig(msg), label: String) -> String {
  // Medium has no size segment in Basecoat (`btn-primary`); Large/Small do
  // (`btn-lg-primary`, `btn-sm-primary`).
  let size_seg = case config.size {
    Medium -> ""
    Large -> "-lg"
    Small -> "-sm"
  }
  let variant_token = case config.variant {
    Primary -> "primary"
    Secondary -> "secondary"
    Outline -> "outline"
    Ghost -> "ghost"
    Link -> "link"
    Destructive -> "destructive"
  }
  // Icon-only = no text label but at least one glyph in a slot (before/after
  // children or the loading spinner). Without this, a slot-only button gets the
  // text-padded variant and renders mis-shapen.
  let has_glyph = case config.before, config.after, config.loading {
    [], [], False -> False
    _, _, _ -> True
  }
  let icon_seg = case string.trim(label) == "" && has_glyph {
    True -> "-icon"
    False -> ""
  }
  let base = "btn" <> size_seg <> icon_seg <> "-" <> variant_token
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

/// Inline override of the `--color-primary` pair so Basecoat's solid machinery
/// recolors to the custom accent. Two `a.style` attributes (Lustre's style is
/// per-property) that merge into the element's `style`.
fn accent_attrs(config: ButtonConfig(msg)) -> List(a.Attribute(msg)) {
  case config.accent {
    None -> []
    Some(acc) -> [
      a.style("--color-primary", acc.bg),
      a.style("--color-primary-foreground", acc.fg),
    ]
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
    True -> [spinner.spinner(spinner.Small, "")]
    False -> config.before
  }
  let label_el = case string.trim(label) {
    "" -> []
    text -> [h.text(text)]
  }
  list.flatten([lead, label_el, config.after])
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

/// Link-styled button (looks like a hyperlink, acts as a `<button>`).
/// For real navigation use `button_link_anchor` (renders `<a href>`).
pub fn button_link(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Link) |> view(label, Some(click_message))
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

/// Destructive button rendered as `<a href>`. Use for navigation URLs.
pub fn button_destructive_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Destructive) |> view_anchor(label, href)
}

/// Link-styled button rendered as `<a href>` — the most natural navigation
/// link (looks like a hyperlink, is one).
pub fn button_link_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Link) |> view_anchor(label, href)
}
