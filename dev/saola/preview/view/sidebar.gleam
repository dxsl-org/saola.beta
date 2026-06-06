import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as ev

import saola/preview/model.{type Message, ThemeSelected}
import saola/theme.{type Theme}

pub fn view(
  current_route: model.Route,
  current_theme: Theme,
) -> Element(Message) {
  h.div([a.class("sidebar")], [
    h.h2([a.class("sidebar-title")], [element.text("UI Showcase")]),
    theme_switcher(current_theme),
    nav_link("/alerts", "Alerts", current_route == model.Alerts),
    nav_link("/badges", "Badges", current_route == model.Badges),
    nav_link("/cards", "Cards", current_route == model.Cards),
    nav_link("/buttons", "Buttons", current_route == model.Buttons),
    nav_link("/inputs", "Inputs", current_route == model.Inputs),
    nav_link("/forms", "Forms", current_route == model.Forms),
    nav_link("/separators", "Separator", current_route == model.Separators),
    nav_link("/tooltips", "Tooltip", current_route == model.Tooltips),
    nav_link("/switches", "Switch", current_route == model.Switches),
    nav_link("/sliders", "Slider", current_route == model.Sliders),
    nav_link("/selects", "Select", current_route == model.Selects),
    nav_link("/fields", "Field", current_route == model.Fields),
    nav_link("/accordions", "Accordion", current_route == model.Accordions),
    nav_link("/progress", "Progress", current_route == model.Progresses),
    nav_link("/skeletons", "Skeleton", current_route == model.Skeletons),
    nav_link("/avatars", "Avatar", current_route == model.Avatars),
    nav_link("/radio-groups", "Radio Group", current_route == model.RadioGroups),
    nav_link("/toggles", "Toggle", current_route == model.Toggles),
    nav_link(
      "/toggle-groups",
      "Toggle Group",
      current_route == model.ToggleGroups,
    ),
    nav_link("/breadcrumbs", "Breadcrumb", current_route == model.Breadcrumbs),
    nav_link("/paginations", "Pagination", current_route == model.Paginations),
    nav_link("/scroll-areas", "Scroll Area", current_route == model.ScrollAreas),
    nav_link(
      "/aspect-ratios",
      "Aspect Ratio",
      current_route == model.AspectRatios,
    ),
    nav_link(
      "/collapsibles",
      "Collapsible",
      current_route == model.Collapsibles,
    ),
    nav_link("/popovers", "Popover", current_route == model.Popovers),
    nav_link(
      "/alert-dialogs",
      "Alert Dialog",
      current_route == model.AlertDialogs,
    ),
    nav_link("/hover-cards", "Hover Card", current_route == model.HoverCards),
    nav_link("/input-otps", "Input OTP", current_route == model.InputOtps),
    nav_link("/sheets", "Sheet", current_route == model.Sheets),
    nav_link("/menubars", "Menubar", current_route == model.Menubars),
    nav_link("/calendars", "Calendar", current_route == model.Calendars),
    nav_link("/date-pickers", "Date Picker", current_route == model.DatePickers),
    nav_link("/spinners", "Spinner", current_route == model.Spinners),
    nav_link(
      "/native-selects",
      "Native Select",
      current_route == model.NativeSelects,
    ),
    nav_link(
      "/button-groups",
      "Button Group",
      current_route == model.ButtonGroups,
    ),
    nav_link("/input-groups", "Input Group", current_route == model.InputGroups),
    nav_link(
      "/context-menus",
      "Context Menu",
      current_route == model.ContextMenus,
    ),
    nav_link("/drawers", "Drawer", current_route == model.Drawers),
    nav_link("/sidebars", "Sidebar", current_route == model.Sidebars),
    nav_link("/commands", "Command", current_route == model.Commands),
    nav_link("/resizables", "Resizable", current_route == model.Resizables),
    nav_link("/data-tables", "Data Table", current_route == model.DataTables),
    nav_link("/carousels", "Carousel", current_route == model.Carousels),
    nav_link("/comboboxes", "Combobox", current_route == model.Comboboxes),
    nav_link(
      "/navigation-menus",
      "Navigation Menu",
      current_route == model.NavigationMenus,
    ),
    nav_link("/empties", "Empty", current_route == model.Empties),
    nav_link("/items", "Item", current_route == model.Items),
    nav_link(
      "/form-validation",
      "Form Validation",
      current_route == model.FormValidation,
    ),
    nav_link("/searches", "Search", current_route == model.Searches),
    nav_link("/ratings", "Rating", current_route == model.Ratings),
    nav_link(
      "/navigation-bars",
      "Navigation Bar",
      current_route == model.NavigationBars,
    ),
    nav_link("/steppers", "Stepper", current_route == model.Steppers),
    nav_link("/tree-views", "Tree View", current_route == model.TreeViews),
    nav_link("/time-pickers", "Time Picker", current_route == model.TimePickers),
    nav_link(
      "/multiselects",
      "Multiselect",
      current_route == model.Multiselects,
    ),
    nav_link("/timelines", "Timeline", current_route == model.Timelines),
    nav_link("/tabs", "Tabs", current_route == model.Tabs),
    nav_link("/dialogs", "Dialogs", current_route == model.Dialogs),
    nav_link("/tables", "Tables", current_route == model.Tables),
    nav_link("/toasts", "Toasts", current_route == model.Toasts),
    nav_link(
      "/dropdown-menus",
      "Dropdown Menus",
      current_route == model.DropdownMenus,
    ),
    nav_link(
      "/canvas-stress-test",
      "Canvas Stress Test",
      current_route == model.CanvasStressTest,
    ),
    nav_link(
      "/widget-dashboard",
      "Widget Dashboard",
      current_route == model.WidgetDashboard,
    ),
    nav_link(
      "/heatmap-comparison",
      "Heatmap SVG vs Canvas",
      current_route == model.HeatmapComparison,
    ),
    nav_link(
      "/threat-intel-network",
      "Threat Intel Network",
      current_route == model.ThreatIntelNetwork,
    ),
    nav_link("/d3-charts", "D3 Charts", current_route == model.D3Charts),
    nav_link(
      "/monaco-editor",
      "Code Editor",
      current_route == model.MonacoEditor,
    ),
    nav_link(
      "/example-form",
      "Example Form",
      current_route == model.ExampleForm,
    ),
    nav_link(
      "/example-site",
      "Example Site",
      current_route == model.ExampleSite,
    ),
  ])
}

fn nav_link(path: String, label: String, is_active: Bool) -> Element(Message) {
  h.a([a.href(path), a.classes([#("nav-link", True), #("active", is_active)])], [
    element.text(label),
  ])
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
