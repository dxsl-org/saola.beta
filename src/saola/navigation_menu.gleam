//// Navigation menu widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// navigation_menu.navigation_menu_simple(items, model.open, OnOpenChange)  // shortcut
//// navigation_menu.new()
//// |> navigation_menu.add_class("my-nav")
//// |> navigation_menu.view(items, model.open, OnOpenChange)
//// ```

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/icon/lc

pub type NavMenuContent(msg) {
  NavMenuSimple(items: List(#(String, String)))
  NavMenuRich(content: Element(msg))
}

pub type NavMenuItem(msg) {
  NavMenuLink(label: String, href: String, active: Bool)
  NavMenuDropdown(label: String, id: String, content: NavMenuContent(msg))
}

/// Presentation options for a navigation menu. Public for record-update syntax.
/// The items/open_id/on_open_change are the required data, passed to `view`.
pub type NavMenuConfig {
  NavMenuConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> NavMenuConfig {
  NavMenuConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> NavMenuConfig {
  new()
}

/// Append an extra CSS class on the `<nav>`. Additive only.
pub fn add_class(config: NavMenuConfig, class: String) -> NavMenuConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  NavMenuConfig(class: merged)
}

fn render_simple_panel(items: List(#(String, String))) -> Element(msg) {
  h.ul(
    [a.class("nav-menu-simple-list")],
    list.map(items, fn(pair) {
      let #(label, href) = pair
      h.li([], [
        h.a([a.href(href), a.class("nav-menu-simple-link")], [h.text(label)]),
      ])
    }),
  )
}

fn render_content(content: NavMenuContent(msg)) -> Element(msg) {
  case content {
    NavMenuSimple(items) -> render_simple_panel(items)
    NavMenuRich(el) -> el
  }
}

fn render_item(
  item: NavMenuItem(msg),
  open_id: Option(String),
  on_open_change: fn(Option(String)) -> msg,
) -> Element(msg) {
  case item {
    NavMenuLink(label, href, active) -> {
      let cls = case active {
        True -> "nav-menu-link nav-menu-link-active"
        False -> "nav-menu-link"
      }
      h.li([a.class("nav-menu-item")], [
        h.a([a.href(href), a.class(cls)], [h.text(label)]),
      ])
    }
    NavMenuDropdown(label, id, content) -> {
      let is_open = case open_id {
        Some(o) -> o == id
        None -> False
      }
      let next_open = case is_open {
        True -> None
        False -> Some(id)
      }
      let panel = case is_open {
        False -> element.none()
        True ->
          h.div([a.class("nav-menu-content"), a.attribute("role", "menu")], [
            render_content(content),
          ])
      }
      h.li([a.class("nav-menu-item")], [
        h.button(
          [
            a.type_("button"),
            a.class("nav-menu-trigger"),
            a.attribute("aria-expanded", case is_open {
              True -> "true"
              False -> "false"
            }),
            a.attribute("aria-haspopup", "true"),
            e.on_click(on_open_change(next_open)),
          ],
          [h.text(label), lc.chevron_down([a.class("nav-menu-trigger-icon")])],
        ),
        panel,
      ])
    }
  }
}

/// Render the navigation menu. `open_id` is the open dropdown's id (or None);
/// `on_open_change` toggles it.
pub fn view(
  config: NavMenuConfig,
  items: List(NavMenuItem(msg)),
  open_id: Option(String),
  on_open_change: fn(Option(String)) -> msg,
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.nav(
    list.flatten([
      [a.class("nav-menu"), a.attribute("aria-label", "Main")],
      extra_class_attrs,
    ]),
    [
      h.ul(
        [a.class("nav-menu-list")],
        list.map(items, fn(i) { render_item(i, open_id, on_open_change) }),
      ),
    ],
  )
}

// --- Convenience shortcuts ---

pub fn navigation_menu_simple(
  items: List(NavMenuItem(msg)),
  open_id: Option(String),
  on_open_change: fn(Option(String)) -> msg,
) -> Element(msg) {
  new() |> view(items, open_id, on_open_change)
}
