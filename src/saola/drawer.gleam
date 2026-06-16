//// Drawer widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// drawer.drawer_simple(model.open, "Cart", body, CloseDrawer)        // shortcut (bottom)
//// drawer.new()
//// |> drawer.side(drawer.Right)
//// |> drawer.description("3 items")
//// |> drawer.footer(checkout_button)
//// |> drawer.view(model.open, "Cart", body, CloseDrawer)
//// ```

import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type DrawerSide {
  Bottom
  Top
  Left
  Right
}

/// Presentation options for a drawer. Public for record-update syntax. The
/// `open`/`title`/`content`/`on_close` are the required data (`view`).
pub type DrawerConfig(msg) {
  DrawerConfig(
    side: DrawerSide,
    description: Option(String),
    footer: Option(Element(msg)),
    class: String,
  )
}

/// Builder entry point. Defaults: Bottom side, no description/footer/class.
pub fn new() -> DrawerConfig(msg) {
  DrawerConfig(side: Bottom, description: None, footer: None, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> DrawerConfig(msg) {
  new()
}

/// Set the side the drawer slides in from (Bottom — default, Top, Left, Right).
pub fn side(config: DrawerConfig(msg), side: DrawerSide) -> DrawerConfig(msg) {
  DrawerConfig(..config, side: side)
}

/// Set the header description.
pub fn description(
  config: DrawerConfig(msg),
  description: String,
) -> DrawerConfig(msg) {
  DrawerConfig(..config, description: Some(description))
}

/// Set the footer element.
pub fn footer(
  config: DrawerConfig(msg),
  footer: Element(msg),
) -> DrawerConfig(msg) {
  DrawerConfig(..config, footer: Some(footer))
}

/// Append an extra CSS class on the drawer. Additive only.
pub fn add_class(
  config: DrawerConfig(msg),
  class: String,
) -> DrawerConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  DrawerConfig(..config, class: merged)
}

/// Render the drawer (renders nothing while `open` is False). The backdrop and
/// (for top/bottom) a drag handle are included automatically.
pub fn view(
  config: DrawerConfig(msg),
  open: Bool,
  title: String,
  content: Element(msg),
  on_close: fn() -> msg,
) -> Element(msg) {
  case open {
    False -> h.text("")
    True -> {
      let side_class = case config.side {
        Bottom -> "drawer drawer-bottom"
        Top -> "drawer drawer-top"
        Left -> "drawer drawer-left"
        Right -> "drawer drawer-right"
      }
      let full_class = case config.class {
        "" -> side_class
        c -> side_class <> " " <> c
      }
      let show_handle = case config.side {
        Bottom | Top -> True
        Left | Right -> False
      }
      h.div([a.class("drawer-root")], [
        h.div([a.class("drawer-backdrop"), e.on_click(on_close())], []),
        h.div(
          [
            a.class(full_class),
            a.role("dialog"),
            a.attribute("aria-modal", "true"),
            a.attribute("aria-labelledby", "drawer-title"),
          ],
          [
            case show_handle {
              True -> h.div([a.class("drawer-handle")], [])
              False -> h.text("")
            },
            h.div([a.class("drawer-header")], [
              h.h2([a.class("drawer-title"), a.id("drawer-title")], [
                h.text(title),
              ]),
              case config.description {
                None -> h.text("")
                Some(d) -> h.p([a.class("drawer-description")], [h.text(d)])
              },
            ]),
            h.div([a.class("drawer-content")], [content]),
            case config.footer {
              None -> h.text("")
              Some(f) -> h.div([a.class("drawer-footer")], [f])
            },
          ],
        ),
      ])
    }
  }
}

// --- Convenience shortcuts ---

pub fn drawer_simple(
  open: Bool,
  title: String,
  content: Element(msg),
  on_close: fn() -> msg,
) -> Element(msg) {
  new() |> view(open, title, content, on_close)
}
