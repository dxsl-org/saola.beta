import gleam/option.{None, Some}

import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/dropdown_menu as dd
import saola/icon/lc
import saola/icon/lp
import saola/icon/ls
import saola/icon/lt
import saola/preview/event_helper
import saola/preview/model.{
  type Message, type Model, ToggleDropdown, UserClickedOutside,
}
import saola/preview/view/doc_page.{DocSection}

fn is_dropdown_open(model: Model, id: String) -> Bool {
  case model.open_dropdown {
    Some(open_id) -> open_id == id
    None -> False
  }
}

pub fn view(model: Model) -> Element(Message) {
  let basic_items = [
    dd.Flat(dd.Item("Save")),
    dd.Flat(dd.Item("Edit")),
    dd.Flat(dd.Separator),
    dd.Flat(dd.Item("Delete")),
  ]

  let items_with_icons = [
    lp.plus([]) |> dd.ItemWithIcon("New Item") |> dd.Flat,
    lp.pencil([]) |> dd.ItemWithIcon("Edit Item") |> dd.Flat,
    dd.Separator |> dd.Flat,
    lt.trash([]) |> dd.ItemWithIcon("Delete Item") |> dd.Flat,
  ]

  let items_with_links = [
    dd.Flat(dd.Link("Dashboard", "/dashboard")),
    dd.Flat(dd.Link("Settings", "/settings")),
    dd.Flat(dd.Separator),
    dd.Flat(dd.Link("Logout", "/logout")),
  ]

  let grouped_items = [
    dd.Group("Actions", [
      dd.Item("Save"),
      dd.Item("Edit"),
    ]),
    dd.Flat(dd.Separator),
    dd.Group("Navigation", [
      dd.Item("Home"),
      dd.Item("Profile"),
    ]),
  ]

  let mixed_items = [
    dd.Flat(dd.Item("Plain Item")),
    dd.Flat(dd.ItemWithIcon(ls.star([]), "Starred Item")),
    dd.Flat(dd.Link("External Link", "https://example.com")),
    dd.Flat(dd.LinkWithIcon(lc.chevron_down([]), "Download", "/download")),
    dd.Flat(dd.Separator),
    dd.Group("Submenu", [
      dd.Item("Sub Item 1"),
      dd.Item("Sub Item 2"),
    ]),
  ]

  // Wrapping the page in a div that fires UserClickedOutside whenever the user
  // clicks anywhere that is not inside a `.dropdown-menu` element, allowing all
  // open dropdowns to be closed.
  doc_page.doc_page("Dropdown Menus", "Showcase of dropdown menu components.", [
    DocSection("demo", "Demo", [
      h.div(
        [event_helper.on_click_outside(".dropdown-menu", UserClickedOutside)],
        [
          h.div([a.class("grid gap-8")], [
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("Basic Dropdown")]),
              dd.dropdown_simple(
                items: basic_items,
                is_open: is_dropdown_open(model, "basic"),
                trigger_click: ToggleDropdown("basic"),
              ),
            ]),
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("With Trigger Label")]),
              dd.dropdown_with_trigger(
                items: items_with_icons,
                trigger_label: "Actions",
                is_open: is_dropdown_open(model, "actions"),
                trigger_click: ToggleDropdown("actions"),
              ),
            ]),
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("With Icons")]),
              dd.dropdown_simple(
                items: items_with_icons,
                is_open: is_dropdown_open(model, "icons"),
                trigger_click: ToggleDropdown("icons"),
              ),
            ]),
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("With Links")]),
              dd.dropdown_simple(
                items: items_with_links,
                is_open: is_dropdown_open(model, "links"),
                trigger_click: ToggleDropdown("links"),
              ),
            ]),
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("Grouped Items")]),
              dd.dropdown_simple(
                items: grouped_items,
                is_open: is_dropdown_open(model, "grouped"),
                trigger_click: ToggleDropdown("grouped"),
              ),
            ]),
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("Mixed Item Types")]),
              dd.dropdown_simple(
                items: mixed_items,
                is_open: is_dropdown_open(model, "mixed"),
                trigger_click: ToggleDropdown("mixed"),
              ),
            ]),
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("Custom Trigger with Icon")]),
              dd.new()
                |> dd.trigger_label("")
                |> dd.trigger_icon(ls.settings([]))
                |> dd.view(
                  mixed_items,
                  is_dropdown_open(model, "custom-icon"),
                  ToggleDropdown("custom-icon"),
                ),
            ]),
            h.div([a.class("grid gap-4")], [
              h.h2([], [text("Custom Configuration")]),
              dd.new()
                |> dd.trigger_label("Menu Options")
                |> dd.trigger_icon(lc.chevron_down([]))
                |> dd.trigger_class("btn-custom")
                |> dd.id("my-dropdown")
                |> dd.main_class("custom-main")
                |> dd.popover_class("custom-popover")
                |> dd.menu_class("custom-menu")
                |> dd.view(
                  mixed_items,
                  is_dropdown_open(model, "custom-config"),
                  ToggleDropdown("custom-config"),
                ),
            ]),
          ]),
        ],
      ),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/dropdown_menu as dd",
        "",
        "dd.dropdown_simple(",
        "  items: [dd.Flat(dd.Item(\"Save\")), dd.Flat(dd.Separator), dd.Flat(dd.Item(\"Delete\"))],",
        "  is_open: model.dropdown_open,",
        "  trigger_click: ToggleDropdown(\"my-menu\"),",
        ")",
      ]),
    ]),
  ])
}
