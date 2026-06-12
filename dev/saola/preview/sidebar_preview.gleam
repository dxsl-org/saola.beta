import gleam/option.{None, Some}
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, SidebarToggled}
import saola/preview/view/doc_page.{DocSection}
import saola/sidebar

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page("Sidebar", "A collapsible sidebar navigation panel.", [
    DocSection("demo", "Demo", [
      h.div([a.class("grid gap-8")], [
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("Simple sidebar")]),
          sidebar.sidebar_trigger(SidebarToggled),
          h.div(
            [
              a.class("flex border rounded overflow-hidden"),
              a.style("height", "300px"),
            ],
            [
              sidebar.sidebar_simple(
                model.sidebar_open,
                sidebar.sidebar_content([
                  sidebar.sidebar_group(Some("Navigation"), [
                    sidebar.sidebar_menu_item(
                      "Home",
                      "#",
                      None,
                      True,
                      sidebar.default_menu_item_attrs,
                    ),
                    sidebar.sidebar_menu_item(
                      "Dashboard",
                      "#",
                      None,
                      False,
                      sidebar.default_menu_item_attrs,
                    ),
                    sidebar.sidebar_menu_item(
                      "Settings",
                      "#",
                      None,
                      False,
                      sidebar.default_menu_item_attrs,
                    ),
                  ]),
                ]),
              ),
              h.div([a.class("flex-1 p-4 text-sm text-muted")], [
                text("Main content area"),
              ]),
            ],
          ),
        ]),
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("With header, footer and badge")]),
          h.div(
            [
              a.class("flex border rounded overflow-hidden"),
              a.style("height", "320px"),
            ],
            [
              sidebar.sidebar(
                True,
                Some(
                  sidebar.sidebar_header([
                    h.div([a.class("font-semibold text-sm")], [
                      text("Acme Inc."),
                    ]),
                  ]),
                ),
                sidebar.sidebar_content([
                  sidebar.sidebar_group(Some("Projects"), [
                    sidebar.sidebar_menu_item(
                      "Alpha",
                      "#",
                      None,
                      False,
                      sidebar.default_menu_item_attrs,
                    ),
                    sidebar.sidebar_menu_item(
                      "Beta",
                      "#",
                      None,
                      True,
                      sidebar.default_menu_item_attrs,
                    ),
                    sidebar.sidebar_menu_item(
                      "Gamma",
                      "#",
                      None,
                      False,
                      sidebar.default_menu_item_attrs,
                    ),
                  ]),
                  sidebar.sidebar_group(Some("Team"), [
                    sidebar.sidebar_menu_item(
                      "Members",
                      "#",
                      None,
                      False,
                      sidebar.default_menu_item_attrs,
                    ),
                    sidebar.sidebar_menu_item(
                      "Notifications",
                      "#",
                      None,
                      False,
                      sidebar.SidebarMenuItemAttrs(badge: "3", class: ""),
                    ),
                  ]),
                ]),
                Some(
                  sidebar.sidebar_footer([
                    h.div([a.class("text-xs text-muted")], [text("v1.0.0")]),
                  ]),
                ),
                sidebar.default_attrs,
              ),
              h.div([a.class("flex-1 p-4 text-sm text-muted")], [
                text("Main content area"),
              ]),
            ],
          ),
        ]),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/sidebar",
        "import gleam/option.{None, Some}",
        "",
        "// model.sidebar_open : Bool",
        "sidebar.sidebar_trigger(SidebarToggled)",
        "sidebar.sidebar_simple(",
        "  model.sidebar_open,",
        "  sidebar.sidebar_content([...]),",
        ")",
      ]),
    ]),
  ])
}
