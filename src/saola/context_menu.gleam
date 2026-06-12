import gleam/dynamic/decode
import gleam/int
import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type ContextMenuItem(msg) {
  ContextMenuAction(label: String, on_click: msg)
  ContextMenuActionShortcut(label: String, shortcut: String, on_click: msg)
  ContextMenuDestructive(label: String, on_click: msg)
  ContextMenuDisabled(label: String)
  ContextMenuSeparator
  ContextMenuGroup(label: String, items: List(ContextMenuItem(msg)))
}

pub type ContextMenuAttrs {
  ContextMenuAttrs(class: String)
}

pub const default_attrs = ContextMenuAttrs(class: "")

fn decode_coords(callback: fn(Int, Int) -> msg) -> decode.Decoder(msg) {
  use x <- decode.field("clientX", decode.int)
  use y <- decode.field("clientY", decode.int)
  decode.success(callback(x, y))
}

fn render_item(item: ContextMenuItem(msg)) -> Element(msg) {
  case item {
    ContextMenuAction(label, on_click) ->
      h.button(
        [
          a.type_("button"),
          a.class("context-menu-item"),
          a.attribute("role", "menuitem"),
          e.on_click(on_click),
        ],
        [h.text(label)],
      )
    ContextMenuActionShortcut(label, shortcut, on_click) ->
      h.button(
        [
          a.type_("button"),
          a.class("context-menu-item"),
          a.attribute("role", "menuitem"),
          e.on_click(on_click),
        ],
        [
          h.text(label),
          h.span([a.class("context-menu-shortcut")], [h.text(shortcut)]),
        ],
      )
    ContextMenuDestructive(label, on_click) ->
      h.button(
        [
          a.type_("button"),
          a.class("context-menu-item context-menu-item-destructive"),
          a.attribute("role", "menuitem"),
          e.on_click(on_click),
        ],
        [h.text(label)],
      )
    ContextMenuDisabled(label) ->
      h.div(
        [
          a.class("context-menu-item context-menu-item-disabled"),
          a.attribute("role", "menuitem"),
          a.attribute("aria-disabled", "true"),
        ],
        [h.text(label)],
      )
    ContextMenuSeparator ->
      h.div(
        [a.class("context-menu-separator"), a.attribute("role", "separator")],
        [],
      )
    ContextMenuGroup(group_label, group_items) ->
      h.div(
        [a.attribute("role", "group"), a.attribute("aria-label", group_label)],
        [
          h.div([a.class("context-menu-group-label")], [h.text(group_label)]),
          ..list.map(group_items, render_item)
        ],
      )
  }
}

pub fn context_menu(
  trigger: Element(msg),
  items: List(ContextMenuItem(msg)),
  open: Bool,
  x: Int,
  y: Int,
  on_context_menu: fn(Int, Int) -> msg,
  on_close: fn() -> msg,
  attrs: ContextMenuAttrs,
) -> Element(msg) {
  let extra_class = case attrs.class {
    "" -> a.none()
    c -> a.class(c)
  }
  h.div(
    [
      a.class("context-menu-trigger"),
      extra_class,
      e.on("contextmenu", decode_coords(on_context_menu)) |> e.prevent_default,
    ],
    [
      trigger,
      case open {
        False -> h.text("")
        True ->
          h.div([], [
            h.div(
              [a.class("context-menu-backdrop"), e.on_click(on_close())],
              [],
            ),
            h.div(
              [
                a.class("context-menu-popup"),
                a.attribute("role", "menu"),
                a.style("left", int.to_string(x) <> "px"),
                a.style("top", int.to_string(y) <> "px"),
              ],
              list.map(items, render_item),
            ),
          ])
      },
    ],
  )
}

pub fn context_menu_simple(
  trigger: Element(msg),
  items: List(ContextMenuItem(msg)),
  open: Bool,
  x: Int,
  y: Int,
  on_context_menu: fn(Int, Int) -> msg,
  on_close: fn() -> msg,
) -> Element(msg) {
  context_menu(
    trigger,
    items,
    open,
    x,
    y,
    on_context_menu,
    on_close,
    default_attrs,
  )
}
