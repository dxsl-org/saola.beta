//// Sidebar widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// sidebar.sidebar_simple(model.open, content)                       // shortcut
//// sidebar.new()
//// |> sidebar.side(sidebar.Right)
//// |> sidebar.collapsible(sidebar.Icon)
//// |> sidebar.view(model.open, Some(header), content, Some(footer))
//// ```
//// Consumer owns the open/closed state. The structural sub-elements
//// (`sidebar_header`, `sidebar_group`, `sidebar_menu_item`, …) stay flat —
//// they are layout pieces, not standalone configurable widgets.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// Which edge the sidebar docks to.
pub type SidebarSide {
  Left
  Right
}

/// Collapse behaviour: slide off-canvas, shrink to an icon rail, or never
/// collapse (`SidebarNone`).
pub type SidebarCollapsible {
  Offcanvas
  Icon
  SidebarNone
}

/// Visual treatment: flush (`Default`), detached card (`Floating`), or inset
/// within the content frame (`Inset`).
pub type SidebarVariant {
  Default
  Floating
  Inset
}

/// Presentation options for a sidebar. Public for record-update syntax. The
/// open state, header, content, and footer are the required data, passed to
/// `view`.
pub type SidebarConfig {
  SidebarConfig(
    side: SidebarSide,
    variant: SidebarVariant,
    collapsible: SidebarCollapsible,
    class: String,
  )
}

/// Builder entry point. Defaults: Left side, Default variant, Offcanvas
/// collapsible, no extra class.
pub fn new() -> SidebarConfig {
  SidebarConfig(
    side: Left,
    variant: Default,
    collapsible: Offcanvas,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SidebarConfig {
  new()
}

/// Set the side the sidebar docks to (Left — default, Right).
pub fn side(config: SidebarConfig, side: SidebarSide) -> SidebarConfig {
  SidebarConfig(..config, side: side)
}

/// Set the variant (Default, Floating, Inset).
pub fn variant(config: SidebarConfig, variant: SidebarVariant) -> SidebarConfig {
  SidebarConfig(..config, variant: variant)
}

/// Set the collapse behavior (Offcanvas — default, Icon, SidebarNone).
pub fn collapsible(
  config: SidebarConfig,
  collapsible: SidebarCollapsible,
) -> SidebarConfig {
  SidebarConfig(..config, collapsible: collapsible)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: SidebarConfig, class: String) -> SidebarConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SidebarConfig(..config, class: merged)
}

/// Render the sidebar. `open` is owned by the consumer's model.
pub fn view(
  config: SidebarConfig,
  open: Bool,
  header: Option(Element(msg)),
  content: Element(msg),
  footer: Option(Element(msg)),
) -> Element(msg) {
  let side_class = case config.side {
    Left -> "sidebar-left"
    Right -> "sidebar-right"
  }
  let variant_class = case config.variant {
    Default -> ""
    Floating -> " sidebar-floating"
    Inset -> " sidebar-inset"
  }
  let collapsible_class = case config.collapsible {
    Offcanvas -> " sidebar-collapsible-offcanvas"
    Icon -> " sidebar-collapsible-icon"
    SidebarNone -> ""
  }
  let open_class = case open {
    True -> " sidebar-open"
    False -> " sidebar-closed"
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let full_class =
    "sidebar " <> side_class <> variant_class <> collapsible_class <> open_class
  h.aside(
    list.flatten([
      [a.class(full_class), a.attribute("aria-label", "Sidebar")],
      extra_class_attrs,
    ]),
    list.flatten([
      [
        case header {
          None -> element.none()
          Some(hdr) -> hdr
        },
      ],
      [content],
      [
        case footer {
          None -> element.none()
          Some(ftr) -> ftr
        },
      ],
    ]),
  )
}

// ── Sub-elements (structural — kept flat) ─────────────────────────────────────

/// Header slot — typically a brand/logo. Pass to `view`'s `header` param.
pub fn sidebar_header(children: List(Element(msg))) -> Element(msg) {
  h.div([a.class("sidebar-header")], children)
}

/// Footer slot — typically user/account controls. Pass to `view`'s `footer`.
pub fn sidebar_footer(children: List(Element(msg))) -> Element(msg) {
  h.div([a.class("sidebar-footer")], children)
}

/// Scrollable content slot holding one or more `sidebar_group`s.
pub fn sidebar_content(children: List(Element(msg))) -> Element(msg) {
  h.div([a.class("sidebar-content")], children)
}

/// A labelled group of `sidebar_menu_item`s. `label` is the section heading
/// (omitted when `None`).
pub fn sidebar_group(
  label: Option(String),
  children: List(Element(msg)),
) -> Element(msg) {
  h.nav([a.class("sidebar-group")], [
    case label {
      None -> element.none()
      Some(l) -> h.div([a.class("sidebar-group-label")], [h.text(l)])
    },
    h.ul([a.class("sidebar-menu")], children),
  ])
}

/// Secondary options for a menu item: an optional `badge` (count/status) and
/// an extra `class`. Use `default_menu_item_attrs` for the common case.
pub type SidebarMenuItemAttrs {
  SidebarMenuItemAttrs(badge: String, class: String)
}

/// No badge, no extra class.
pub const default_menu_item_attrs = SidebarMenuItemAttrs(badge: "", class: "")

/// A navigation entry inside a `sidebar_group`. `active` marks the current
/// page; `attrs` carries the optional badge/class.
pub fn sidebar_menu_item(
  label: String,
  href: String,
  icon: Option(Element(msg)),
  active: Bool,
  attrs: SidebarMenuItemAttrs,
) -> Element(msg) {
  let btn_class = case active {
    True -> "sidebar-menu-button sidebar-menu-button-active"
    False -> "sidebar-menu-button"
  }
  let extra_class_attrs = case attrs.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.li(list.flatten([[a.class("sidebar-menu-item")], extra_class_attrs]), [
    h.a([a.href(href), a.class(btn_class)], [
      case icon {
        None -> element.none()
        Some(i) -> h.span([a.class("sidebar-menu-icon")], [i])
      },
      h.span([a.class("sidebar-menu-label")], [h.text(label)]),
      case attrs.badge {
        "" -> element.none()
        b ->
          h.span([a.class("sidebar-menu-badge"), a.attribute("aria-label", b)], [
            h.text(b),
          ])
      },
    ]),
  ])
}

/// A toggle button that fires `on_click` to open/close the sidebar. Place it
/// outside the sidebar (e.g. in a top bar).
pub fn sidebar_trigger(on_click: msg) -> Element(msg) {
  h.button(
    [
      a.type_("button"),
      a.class("sidebar-trigger"),
      a.attribute("aria-label", "Toggle sidebar"),
      e.on_click(on_click),
    ],
    [h.text("☰")],
  )
}

// ── Convenience shortcuts ─────────────────────────────────────────────────────

/// A left-docked sidebar with only content (no header/footer), default style.
pub fn sidebar_simple(open: Bool, content: Element(msg)) -> Element(msg) {
  new() |> view(open, None, content, None)
}
