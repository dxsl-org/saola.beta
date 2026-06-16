//// Dropdown menu widget — dual-style `Config` (uniform Saola pattern).
//// Consolidates the former TriggerAttrs + MinorAttrs into one `Config`.
////
//// ```gleam
//// dropdown_menu.dropdown_simple(items: items, is_open: model.open, trigger_click: Toggle)  // shortcut
//// dropdown_menu.new()
//// |> dropdown_menu.trigger_label("Actions")
//// |> dropdown_menu.view(items, model.open, Toggle)
//// ```
////
//// NOTE: uses a `data-popover` attribute (not the native popover API) so the
//// menu can be positioned with standard CSS relative to the trigger.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import typeid

pub type BaseDropdownMenuItem(a) {
  /// A clickable menu item (text only)
  Item(label: String)
  /// A clickable menu item with an icon
  ItemWithIcon(icon: Element(a), label: String)
  /// A clickable menu item that links to a URL
  Link(label: String, url: String)
  /// A link with an icon
  LinkWithIcon(icon: Element(a), label: String, url: String)
  Separator
}

pub type DropdownMenuItem(a) {
  Flat(BaseDropdownMenuItem(a))
  /// A group of items with a label
  Group(label: String, items: List(BaseDropdownMenuItem(a)))
}

/// All presentation options. Public for record-update syntax. The `items`,
/// `is_open`, and `trigger_click` are the required data, passed to `view`.
pub type DropdownMenuConfig(a) {
  DropdownMenuConfig(
    trigger_label: String,
    trigger_icon: Option(Element(a)),
    trigger_class: String,
    id: String,
    main_class: String,
    popover_class: String,
    menu_class: String,
  )
}

/// Builder entry point. Defaults: trigger label "Open", no icon, auto id.
pub fn new() -> DropdownMenuConfig(a) {
  DropdownMenuConfig(
    trigger_label: "Open",
    trigger_icon: None,
    trigger_class: "",
    id: "",
    main_class: "",
    popover_class: "",
    menu_class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> DropdownMenuConfig(a) {
  new()
}

/// Set the trigger button label.
pub fn trigger_label(
  config: DropdownMenuConfig(a),
  label: String,
) -> DropdownMenuConfig(a) {
  DropdownMenuConfig(..config, trigger_label: label)
}

/// Set the trigger button icon.
pub fn trigger_icon(
  config: DropdownMenuConfig(a),
  icon: Element(a),
) -> DropdownMenuConfig(a) {
  DropdownMenuConfig(..config, trigger_icon: Some(icon))
}

/// Set an extra class on the trigger button.
pub fn trigger_class(
  config: DropdownMenuConfig(a),
  class: String,
) -> DropdownMenuConfig(a) {
  DropdownMenuConfig(..config, trigger_class: class)
}

/// Set the base id (auto-generated when empty).
pub fn id(config: DropdownMenuConfig(a), id: String) -> DropdownMenuConfig(a) {
  DropdownMenuConfig(..config, id: id)
}

/// Set an extra class on the root container.
pub fn main_class(
  config: DropdownMenuConfig(a),
  class: String,
) -> DropdownMenuConfig(a) {
  DropdownMenuConfig(..config, main_class: class)
}

/// Set an extra class on the popover wrapper.
pub fn popover_class(
  config: DropdownMenuConfig(a),
  class: String,
) -> DropdownMenuConfig(a) {
  DropdownMenuConfig(..config, popover_class: class)
}

/// Set an extra class on the menu.
pub fn menu_class(
  config: DropdownMenuConfig(a),
  class: String,
) -> DropdownMenuConfig(a) {
  DropdownMenuConfig(..config, menu_class: class)
}

fn render_menu_item(item: DropdownMenuItem(a)) -> Element(a) {
  case item {
    Flat(base_item) -> render_base_item(base_item)
    Group(label, items) -> render_item_group(label, items)
  }
}

fn render_base_item(item: BaseDropdownMenuItem(a)) -> Element(a) {
  case item {
    Item(label) -> h.div([a.role("menuitem")], [h.text(label)])
    ItemWithIcon(icon, label) ->
      h.div([a.role("menuitem")], [icon, h.text(label)])
    Link(label, url) -> h.a([a.role("menuitem"), a.href(url)], [h.text(label)])
    LinkWithIcon(icon, label, url) ->
      h.a([a.role("menuitem"), a.href(url)], [icon, h.text(label)])
    Separator -> h.hr([a.role("separator")])
  }
}

fn render_item_group(
  label: String,
  items: List(BaseDropdownMenuItem(a)),
) -> Element(a) {
  let group_id =
    typeid.new(prefix: "grp")
    |> result.map(typeid.to_string)
    |> result.unwrap("grp")
  let label_id = group_id <> "-label"
  h.div([a.role("group"), a.aria_labelledby(label_id)], [
    h.div([a.role("heading"), a.id(label_id)], [h.text(label)]),
    h.div([], items |> list.map(render_base_item)),
  ])
}

/// Render the dropdown menu. `is_open` is consumer-owned; `trigger_click` fires
/// when the trigger button is clicked.
pub fn view(
  config: DropdownMenuConfig(a),
  items: List(DropdownMenuItem(a)),
  is_open: Bool,
  trigger_click: a,
) -> Element(a) {
  let base_id =
    case config.id {
      "" -> typeid.new(prefix: "menu") |> result.map(typeid.to_string)
      id -> Ok(id)
    }
    |> result.unwrap("menu-fallback")
  let trigger_id = base_id <> "-trigger"
  let menu_id = base_id <> "-menu"
  let popover_id = base_id <> "-popover"

  let trigger_main_attrs = [
    a.type_("button"),
    a.id(trigger_id),
    e.on_click(trigger_click),
    a.class("btn-outline"),
    a.aria_haspopup("menu"),
    a.aria_expanded(False),
    a.aria_controls(menu_id),
  ]
  let trigger_class_attrs = case config.trigger_class {
    "" -> []
    c -> [a.class(c)]
  }
  let trigger_icon_el = case config.trigger_icon {
    None -> element.none()
    Some(icon) -> icon
  }
  let btn_trigger =
    h.button(list.flatten([trigger_main_attrs, trigger_class_attrs]), [
      trigger_icon_el,
      h.text(config.trigger_label),
    ])

  let menu_class_attrs = case config.menu_class {
    "" -> []
    c -> [a.class(c)]
  }
  let menu =
    h.div(
      list.flatten([
        [a.role("menu"), a.id(menu_id), a.aria_labelledby(trigger_id)],
        menu_class_attrs,
      ]),
      items |> list.map(render_menu_item),
    )

  let popover =
    h.div(
      [
        a.id(popover_id),
        a.data("popover", ""),
        a.class(config.popover_class),
        a.aria_hidden(!is_open),
      ],
      [menu],
    )

  let main_class_attr = a.class("dropdown-menu " <> config.main_class)
  h.div([a.id(base_id), main_class_attr], [btn_trigger, popover])
}

// --- Convenience shortcuts ---

pub fn dropdown_simple(
  items items: List(DropdownMenuItem(a)),
  is_open is_open: Bool,
  trigger_click trigger_click: a,
) -> Element(a) {
  new() |> view(items, is_open, trigger_click)
}

pub fn dropdown_with_trigger(
  items items: List(DropdownMenuItem(a)),
  trigger_label label: String,
  is_open is_open: Bool,
  trigger_click trigger_click: a,
) -> Element(a) {
  DropdownMenuConfig(..new(), trigger_label: label)
  |> view(items, is_open, trigger_click)
}
