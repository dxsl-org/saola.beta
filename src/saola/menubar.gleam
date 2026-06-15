//// Menubar widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// menubar.menubar_simple(items, model.open, OnOpen, OnClose)         // shortcut
//// menubar.new()
//// |> menubar.add_class("my-menubar")
//// |> menubar.view(items, model.open, OnOpen, OnClose)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type MenubarItem(msg) {
  MenubarItem(label: String, items: List(MenubarSubItem(msg)))
  MenubarItemDisabled(label: String)
}

pub type MenubarSubItem(msg) {
  MenubarSubItem(label: String, on_click: msg)
  MenubarSubItemDisabled(label: String)
  MenubarSeparator
}

/// Presentation options for a menubar. Public for record-update syntax. The
/// items/open_menu/handlers are the required data, passed to `view`.
pub type MenubarConfig {
  MenubarConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> MenubarConfig {
  MenubarConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> MenubarConfig {
  new()
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: MenubarConfig, class: String) -> MenubarConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  MenubarConfig(class: merged)
}

/// Render the menubar. `open_menu` is the label of the open top-level menu (or
/// "" for none); `on_open`/`on_close` toggle it.
pub fn view(
  config: MenubarConfig,
  items: List(MenubarItem(msg)),
  open_menu: String,
  on_open: fn(String) -> msg,
  on_close: fn() -> msg,
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(
    list.flatten([[a.class("menubar"), a.role("menubar")], extra_class_attrs]),
    list.map(items, fn(item) {
      case item {
        MenubarItemDisabled(label) ->
          h.button(
            [a.type_("button"), a.class("menubar-trigger"), a.disabled(True)],
            [h.text(label)],
          )
        MenubarItem(label, sub_items) -> {
          let is_open = open_menu == label
          h.div([a.class("menubar-menu")], [
            h.button(
              [
                a.type_("button"),
                a.class("menubar-trigger"),
                a.attribute("aria-haspopup", "menu"),
                a.attribute("aria-expanded", case is_open {
                  True -> "true"
                  False -> "false"
                }),
                e.on_click(case is_open {
                  True -> on_close()
                  False -> on_open(label)
                }),
              ],
              [h.text(label)],
            ),
            case is_open {
              False -> h.text("")
              True ->
                h.div(
                  [a.class("dropdown-menu"), a.role("menu")],
                  list.map(sub_items, fn(sub) {
                    case sub {
                      MenubarSeparator ->
                        h.div(
                          [a.class("dropdown-separator"), a.role("separator")],
                          [],
                        )
                      MenubarSubItemDisabled(l) ->
                        h.div(
                          [
                            a.class("dropdown-item"),
                            a.attribute("aria-disabled", "true"),
                          ],
                          [h.text(l)],
                        )
                      MenubarSubItem(l, click_msg) ->
                        h.button(
                          [
                            a.type_("button"),
                            a.class("dropdown-item"),
                            a.role("menuitem"),
                            e.on_click(click_msg),
                          ],
                          [h.text(l)],
                        )
                    }
                  }),
                )
            },
          ])
        }
      }
    }),
  )
}

// --- Convenience shortcuts ---

pub fn menubar_simple(
  items: List(MenubarItem(msg)),
  open_menu: String,
  on_open: fn(String) -> msg,
  on_close: fn() -> msg,
) -> Element(msg) {
  new() |> view(items, open_menu, on_open, on_close)
}
