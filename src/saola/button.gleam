//// Button widget — one public `ButtonConfig` consumed two ways (builder pipes
//// or record update), plus shortcuts. One terminal:
////
//// ```gleam
//// // Builder
//// button.new()
//// |> button.variant(button.Outline)
//// |> button.state(button.Loading)
//// |> button.view("Save", "", Some(SaveClicked))   // empty href → <button>
////
//// // Config (record update)
//// button.view(
////   button.ButtonConfig(..button.default_config(), state: button.Loading),
////   "Save",
////   "",
////   Some(SaveClicked),
//// )
//// ```
////
//// ## Render target — decided by `href`
////
//// A single `view(config, label, href, on_click)` chooses the element from the
//// `href` string: a **non-empty** href renders `<a href>` (navigation,
//// `on_click` ignored); an **empty** href renders `<button>` (uses `on_click`).
//// One function keeps conditional `<a>`-vs-`<button>` rendering trivial.
////
//// ## State (`ButtonState`)
////
//// `state` is one mutually-exclusive enum (consumer-owned, widgets are
//// stateless), modelling an async/checkout flow:
//// `Idle → Loading → {Loaded | Failed}`, plus `Suspended` (a system hold,
//// distinct from `Disabled`). Each non-idle state emits `data-state="..."` so
//// the consumer can style it and animate the loading → loaded → idle hand-off
//// (Basecoat's `.btn { transition: all }`). `loading`/`disabled` setters are
//// sugar over `state`.
////
//// ## Customizing styles
////
//// `src/saola/button.css` is `@generated` from Basecoat — do not edit it
//// (`just build-css` overwrites it). Customize from your own CSS:
//// 1. **Theme tokens** — `:root { --color-primary: ...; --radius-md: ...; }`
//// 2. **Per-widget override** — unlayered `.btn-primary { ... }` beats
////    `@layer saola.*` (no `!important`).
//// 3. **One-off** — `add_class("w-full")`.
//// 4. **Custom accent** — `accent(Accent("var(--chart-2)", "var(--background)"))`
////    recolors the solid look via an inline `--color-primary` override.

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

/// Mutually-exclusive button state (consumer-owned). Models an async/checkout
/// flow: `Idle → Loading → {Loaded | Failed}`.
///
/// - `Loading`: spinner replaces the `before` slot, `aria-busy`, inert.
/// - `Loaded` / `Failed`: outcome states — interactive (e.g. retry); the
///   success/error glyph is a consumer-provided element in a slot.
/// - `Suspended`: a system hold (payment/checkout) — inert + `aria-disabled`,
///   **distinct from `Disabled`** (which is a permission/availability block).
/// - Every non-idle state emits `data-state="..."` for styling + transitions.
pub type ButtonState {
  Idle
  Loading
  Loaded
  Failed
  Suspended
  Disabled
}

pub type ButtonAria {
  ButtonAria(label: String, expanded: Option(Bool))
}

/// Custom accent color for the SOLID look. Overrides the `--color-primary`
/// pair inline so Basecoat's background / hover (`color-mix`) / focus machinery
/// recolors — no parallel CSS. Values accept any CSS color or a theme token
/// (`var(--chart-2)`), keeping custom colors theme-coherent.
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

/// All presentation options. Public (not opaque) so record-update syntax works:
/// `ButtonConfig(..default_config(), state: Loading)`.
///
/// - `before`/`after`: arbitrary children rendered before / after the label.
///   `icon_start`/`icon_end` are single-element shortcuts over them.
/// - `state`: see `ButtonState`. `type_`: only meaningful for the `<button>`
///   render (empty href); ignored for `<a>`.
/// - `class`: appended after the Basecoat variant class — additive only.
pub type ButtonConfig(msg) {
  ButtonConfig(
    variant: ButtonVariant,
    size: ButtonSize,
    before: List(Element(msg)),
    after: List(Element(msg)),
    state: ButtonState,
    type_: Option(ButtonRoleType),
    aria: ButtonAria,
    accent: Option(Accent),
    class: String,
  )
}

pub const default_aria = ButtonAria("", None)

/// Builder entry point. Defaults: Primary, Medium, no children, `Idle`, no
/// explicit type (renders `type="button"`), empty aria, no accent, no class.
pub fn new() -> ButtonConfig(msg) {
  ButtonConfig(
    variant: Primary,
    size: Medium,
    before: [],
    after: [],
    state: Idle,
    type_: None,
    aria: default_aria,
    accent: None,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
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

/// Children rendered before the label. Replaced by a spinner while `Loading`.
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

/// Set the button state. See `ButtonState`.
pub fn state(config: ButtonConfig(msg), state: ButtonState) -> ButtonConfig(msg) {
  ButtonConfig(..config, state: state)
}

/// Sugar over `state`: `loading(True)` == `state(Loading)`, `loading(False)`
/// == `state(Idle)`. For the success/failed/suspended states use `state`.
pub fn loading(config: ButtonConfig(msg), is_loading: Bool) -> ButtonConfig(msg) {
  state(config, case is_loading {
    True -> Loading
    False -> Idle
  })
}

/// Sugar over `state`: `disabled(True)` == `state(Disabled)`, `disabled(False)`
/// == `state(Idle)`.
pub fn disabled(config: ButtonConfig(msg), is_disabled: Bool) -> ButtonConfig(msg) {
  state(config, case is_disabled {
    True -> Disabled
    False -> Idle
  })
}

/// Form role (`type="button" | "submit" | "reset"`). Ignored for `<a>`.
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
/// default `Primary` variant.
pub fn accent(config: ButtonConfig(msg), accent: Accent) -> ButtonConfig(msg) {
  ButtonConfig(..config, accent: Some(accent))
}

/// Append an extra CSS class after the Basecoat variant class. Additive only.
pub fn add_class(config: ButtonConfig(msg), class: String) -> ButtonConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ButtonConfig(..config, class: merged)
}

// --- Terminal ---

/// Render the button. The `href` chooses the element:
/// - **non-empty** `href` → `<a href>` (navigation; `on_click` ignored). While
///   the state is inert (`Loading`/`Suspended`/`Disabled`) the `href` is omitted
///   so the link is genuinely non-navigable, with `aria-disabled` + `tabindex`.
/// - **empty** `href` → `<button>` using `on_click` (omitted while inert);
///   `Disabled` uses native `disabled`, other inert states use `aria-disabled`
///   so they stay in the accessibility tree.
pub fn view(
  config: ButtonConfig(msg),
  label: String,
  href: String,
  on_click: Option(msg),
) -> Element(msg) {
  case string.trim(href) {
    "" -> render_button(config, label, on_click)
    url -> render_anchor(config, label, url)
  }
}

// --- Internal rendering helpers ---

fn interactive(state: ButtonState) -> Bool {
  case state {
    Idle | Loaded | Failed -> True
    Loading | Suspended | Disabled -> False
  }
}

fn render_button(
  config: ButtonConfig(msg),
  label: String,
  on_click: Option(msg),
) -> Element(msg) {
  let click_attrs = case on_click, interactive(config.state) {
    Some(msg), True -> [e.on_click(msg)]
    _, _ -> []
  }
  // Default to type="button": an unset <button> is type="submit" per HTML and
  // would submit its enclosing <form>.
  let type_attrs = case config.type_ {
    None | Some(Regular) -> [a.type_("button")]
    Some(Submit) -> [a.type_("submit")]
    Some(Reset) -> [a.type_("reset")]
  }
  h.button(
    list.flatten([
      [a.class(css_class(config, label))],
      accent_attrs(config),
      button_state_attrs(config.state),
      click_attrs,
      type_attrs,
      aria_attrs(config),
    ]),
    content(config, label),
  )
}

fn render_anchor(
  config: ButtonConfig(msg),
  label: String,
  url: String,
) -> Element(msg) {
  let href_attrs = case interactive(config.state) {
    True -> [a.href(url)]
    False -> []
  }
  h.a(
    list.flatten([
      [a.class(css_class(config, label))],
      href_attrs,
      accent_attrs(config),
      anchor_state_attrs(config.state),
      aria_attrs(config),
    ]),
    content(config, label),
  )
}

/// `<button>` state attributes. `Disabled` uses the native attribute; other
/// inert states use `aria-disabled` so the button stays in the a11y tree.
fn button_state_attrs(state: ButtonState) -> List(a.Attribute(msg)) {
  case state {
    Idle -> []
    Loading -> [
      a.attribute("aria-busy", "true"),
      a.attribute("aria-disabled", "true"),
      a.attribute("data-state", "loading"),
    ]
    Loaded -> [a.attribute("data-state", "loaded")]
    Failed -> [a.attribute("data-state", "failed")]
    Suspended -> [
      a.attribute("aria-disabled", "true"),
      a.attribute("data-state", "suspended"),
    ]
    Disabled -> [a.disabled(True)]
  }
}

/// `<a>` state attributes. Anchors have no native disabled, so every inert
/// state uses `aria-disabled` + `tabindex="-1"` (href is omitted by the caller).
fn anchor_state_attrs(state: ButtonState) -> List(a.Attribute(msg)) {
  let inert = [
    a.attribute("aria-disabled", "true"),
    a.attribute("tabindex", "-1"),
  ]
  case state {
    Idle -> []
    Loading ->
      list.flatten([
        [a.attribute("aria-busy", "true")],
        inert,
        [a.attribute("data-state", "loading")],
      ])
    Loaded -> [a.attribute("data-state", "loaded")]
    Failed -> [a.attribute("data-state", "failed")]
    Suspended ->
      list.flatten([inert, [a.attribute("data-state", "suspended")]])
    Disabled -> inert
  }
}

/// Build the Basecoat class. An empty label with a glyph (a `before`/`after`
/// child or the loading spinner) is icon-only and uses Basecoat's square
/// `-icon-` variant; otherwise the text-padded variant.
fn css_class(config: ButtonConfig(msg), label: String) -> String {
  // Medium has no size segment in Basecoat (`btn-primary`); Large/Small do.
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
  let loading = case config.state {
    Loading -> True
    _ -> False
  }
  let has_glyph = case config.before, config.after, loading {
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

/// Inline override of the `--color-primary` pair so Basecoat's solid machinery
/// recolors to the custom accent.
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
  let lead = case config.state {
    Loading -> [spinner.spinner(spinner.Small, "")]
    _ -> config.before
  }
  let label_el = case string.trim(label) {
    "" -> []
    text -> [h.text(text)]
  }
  list.flatten([lead, label_el, config.after])
}

// --- Convenience shortcuts ---

pub fn button_primary(label: String, click_message: msg) -> Element(msg) {
  new() |> view(label, "", Some(click_message))
}

pub fn button_secondary(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Secondary) |> view(label, "", Some(click_message))
}

pub fn button_outline(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Outline) |> view(label, "", Some(click_message))
}

pub fn button_ghost(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Ghost) |> view(label, "", Some(click_message))
}

pub fn button_destructive(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Destructive) |> view(label, "", Some(click_message))
}

/// Link-styled button (looks like a hyperlink, acts as a `<button>`).
/// For real navigation use `button_link_anchor` (renders `<a href>`).
pub fn button_link(label: String, click_message: msg) -> Element(msg) {
  new() |> variant(Link) |> view(label, "", Some(click_message))
}

/// Submit button (type="submit"). Use inside a <form>.
pub fn button_submit(label: String) -> Element(msg) {
  new() |> type_(Submit) |> view(label, "", None)
}

/// Small icon-only close button (×) with an accessible "Close" label.
pub fn button_close(click_message: msg) -> Element(msg) {
  new()
  |> variant(Outline)
  |> size(Small)
  |> icon_start(lx.x([]))
  |> aria(ButtonAria("Close", None))
  |> view("", "", Some(click_message))
}

// --- Anchor shortcuts (non-empty href → <a>) ---

/// Primary button rendered as `<a href>`. Use for navigation URLs.
pub fn button_primary_anchor(label: String, href: String) -> Element(msg) {
  new() |> view(label, href, None)
}

/// Secondary button rendered as `<a href>`. Use for navigation URLs.
pub fn button_secondary_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Secondary) |> view(label, href, None)
}

/// Outline button rendered as `<a href>`. Use for navigation URLs.
pub fn button_outline_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Outline) |> view(label, href, None)
}

/// Ghost button rendered as `<a href>`. Use for navigation URLs.
pub fn button_ghost_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Ghost) |> view(label, href, None)
}

/// Destructive button rendered as `<a href>`. Use for navigation URLs.
pub fn button_destructive_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Destructive) |> view(label, href, None)
}

/// Link-styled button rendered as `<a href>` — the most natural navigation link.
pub fn button_link_anchor(label: String, href: String) -> Element(msg) {
  new() |> variant(Link) |> view(label, href, None)
}
