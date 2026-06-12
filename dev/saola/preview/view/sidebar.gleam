import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as ev

import saola/preview/base_path
import saola/preview/model.{type Message, ThemeSelected}
import saola/theme.{type Theme}

pub fn view(
  current_route: model.Route,
  current_theme: Theme,
) -> Element(Message) {
  h.div([a.class("sidebar")], [
    h.h2([a.class("sidebar-title")], [element.text("UI Showcase")]),
    theme_switcher(current_theme),
    section("Forms & Input", forms_links(), current_route),
    section("Buttons & Menus", button_links(), current_route),
    section("Layout & Display", layout_links(), current_route),
    section("Feedback", feedback_links(), current_route),
    section("Overlays", overlay_links(), current_route),
    section("Navigation", navigation_links(), current_route),
    section("Charts & Canvas", chart_links(), current_route),
    section("Demos & Examples", demo_links(), current_route),
    h.a(
      [
        // Static gleam-docs site next to the SPA; local dev has no /api/.
        a.href(base_path.href("/api/")),
        a.rel("external"),
        a.class("nav-link"),
      ],
      [element.text("API Reference")],
    ),
  ])
}

fn forms_links() -> List(#(String, String, model.Route)) {
  [
    #("/inputs", "Inputs", model.Inputs),
    #("/input-groups", "Input Group", model.InputGroups),
    #("/input-otps", "Input OTP", model.InputOtps),
    #("/forms", "Forms", model.Forms),
    #("/form-validation", "Form Validation", model.FormValidation),
    #("/fields", "Field", model.Fields),
    #("/selects", "Select", model.Selects),
    #("/native-selects", "Native Select", model.NativeSelects),
    #("/comboboxes", "Combobox", model.Comboboxes),
    #("/multiselects", "Multiselect", model.Multiselects),
    #("/switches", "Switch", model.Switches),
    #("/sliders", "Slider", model.Sliders),
    #("/radio-groups", "Radio Group", model.RadioGroups),
    #("/toggles", "Toggle", model.Toggles),
    #("/toggle-groups", "Toggle Group", model.ToggleGroups),
    #("/searches", "Search", model.Searches),
    #("/ratings", "Rating", model.Ratings),
    #("/calendars", "Calendar", model.Calendars),
    #("/date-pickers", "Date Picker", model.DatePickers),
    #("/time-pickers", "Time Picker", model.TimePickers),
  ]
}

fn button_links() -> List(#(String, String, model.Route)) {
  [
    #("/buttons", "Buttons", model.Buttons),
    #("/button-groups", "Button Group", model.ButtonGroups),
    #("/commands", "Command", model.Commands),
    #("/dropdown-menus", "Dropdown Menu", model.DropdownMenus),
    #("/context-menus", "Context Menu", model.ContextMenus),
    #("/menubars", "Menubar", model.Menubars),
  ]
}

fn layout_links() -> List(#(String, String, model.Route)) {
  [
    #("/cards", "Cards", model.Cards),
    #("/separators", "Separator", model.Separators),
    #("/aspect-ratios", "Aspect Ratio", model.AspectRatios),
    #("/scroll-areas", "Scroll Area", model.ScrollAreas),
    #("/resizables", "Resizable", model.Resizables),
    #("/collapsibles", "Collapsible", model.Collapsibles),
    #("/accordions", "Accordion", model.Accordions),
    #("/tabs", "Tabs", model.Tabs),
    #("/items", "Item", model.Items),
    #("/empties", "Empty", model.Empties),
    #("/tables", "Tables", model.Tables),
    #("/data-tables", "Data Table", model.DataTables),
    #("/tree-views", "Tree View", model.TreeViews),
    #("/timelines", "Timeline", model.Timelines),
    #("/carousels", "Carousel", model.Carousels),
    #("/avatars", "Avatar", model.Avatars),
  ]
}

fn feedback_links() -> List(#(String, String, model.Route)) {
  [
    #("/alerts", "Alerts", model.Alerts),
    #("/badges", "Badges", model.Badges),
    #("/toasts", "Toasts", model.Toasts),
    #("/tooltips", "Tooltip", model.Tooltips),
    #("/progress", "Progress", model.Progresses),
    #("/skeletons", "Skeleton", model.Skeletons),
    #("/spinners", "Spinner", model.Spinners),
  ]
}

fn overlay_links() -> List(#(String, String, model.Route)) {
  [
    #("/dialogs", "Dialogs", model.Dialogs),
    #("/alert-dialogs", "Alert Dialog", model.AlertDialogs),
    #("/sheets", "Sheet", model.Sheets),
    #("/drawers", "Drawer", model.Drawers),
    #("/popovers", "Popover", model.Popovers),
    #("/hover-cards", "Hover Card", model.HoverCards),
  ]
}

fn navigation_links() -> List(#(String, String, model.Route)) {
  [
    #("/breadcrumbs", "Breadcrumb", model.Breadcrumbs),
    #("/paginations", "Pagination", model.Paginations),
    #("/navigation-menus", "Navigation Menu", model.NavigationMenus),
    #("/navigation-bars", "Navigation Bar", model.NavigationBars),
    #("/sidebars", "Sidebar", model.Sidebars),
    #("/steppers", "Stepper", model.Steppers),
  ]
}

fn chart_links() -> List(#(String, String, model.Route)) {
  [
    #("/d3-charts", "D3 Charts", model.D3Charts),
    #("/heatmap-comparison", "Heatmap SVG vs Canvas", model.HeatmapComparison),
    #("/canvas-stress-test", "Canvas Stress Test", model.CanvasStressTest),
  ]
}

fn demo_links() -> List(#(String, String, model.Route)) {
  [
    #("/widget-dashboard", "Widget Dashboard", model.WidgetDashboard),
    #("/threat-intel-network", "Threat Intel Network", model.ThreatIntelNetwork),
    #("/monaco-editor", "Code Editor", model.MonacoEditor),
    #("/example-form", "Example Form", model.ExampleForm),
    #("/example-site", "Example Site", model.ExampleSite),
  ]
}

fn section(
  title: String,
  links: List(#(String, String, model.Route)),
  current_route: model.Route,
) -> Element(Message) {
  h.div([a.class("sidebar-section")], [
    h.h3([a.class("sidebar-section-title")], [element.text(title)]),
    ..list.map(links, fn(link) {
      nav_link(link.0, link.1, current_route == link.2)
    })
  ])
}

fn nav_link(path: String, label: String, is_active: Bool) -> Element(Message) {
  h.a(
    [
      a.href(base_path.href(path)),
      a.classes([#("nav-link", True), #("active", is_active)]),
    ],
    [element.text(label)],
  )
}

fn theme_switcher(current_theme: Theme) -> Element(Message) {
  h.div([a.class("theme-toggle")], [
    theme_btn("Light", theme.Light, current_theme),
    theme_btn("Dark", theme.Dark, current_theme),
    theme_btn("System", theme.System, current_theme),
  ])
}

fn theme_btn(
  label: String,
  variant: Theme,
  current_theme: Theme,
) -> Element(Message) {
  h.button(
    [
      a.type_("button"),
      a.classes([#("nav-link", True), #("active", current_theme == variant)]),
      ev.on_click(ThemeSelected(variant)),
    ],
    [element.text(label)],
  )
}
