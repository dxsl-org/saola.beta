import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/uri.{type Uri}

import lustre
import lustre/attribute as a
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html as h
import modem

import gleam/time/calendar
import saola/data_table
import saola/preview/model.{
  type Model, type Msg, AccordionToggled, Accordions, AddToast, AlertDialogCancelled,
  AlertDialogConfirmed, AlertDialogOpened, AlertDialogs, Alerts, AspectRatios, Avatars,
  Badges, Breadcrumbs, ButtonGroups, Buttons, CalendarDateSelected, CalendarMonthChanged,
  Calendars, Cards, CarouselChanged, Carousels, CloseDialog, CollapsibleToggled, Collapsibles,
  ComboboxOpenChanged, ComboboxQueryChanged, ComboboxSelected, Comboboxes, CommandNavDown,
  CommandNavUp, CommandQueryChanged, CommandSelected, Commands, ContextMenuClosed,
  ContextMenuOpened, ContextMenus, D3Charts, DataTableFilterChanged, DataTablePageChanged,
  DataTableSelectChanged, DataTableSortChanged, DataTables, DatePickerDateSelected,
  DatePickerMonthChanged, DatePickerOpenChanged, DatePickers, Dialogs, DismissToast,
  DrawerClosed, DrawerOpened, Drawers, DropdownMenus, ExampleForm, ExampleSite, Fields,
  FormEmailChanged, FormMessageChanged, FormNameChanged, FormSubmitted, Forms, Home,
  HoverCardClosed, HoverCardOpened, HoverCards, InputGroups, InputOtpChanged, InputOtps,
  Inputs, MenubarClosed, MenubarOpened, Menubars, Model, MonacoEditor, NavMenuOpenChanged,
  NavigationMenus, NativeSelectChanged, NativeSelects, OnRouteChange, OpenDialog, Paginations,
  PaginationChanged, PopoverClosed, Popovers, Progresses, RadioGroups, ResizableSizesChanged,
  Resizables, ScrollAreas, SelectChanged, Selects, Separators, SheetClosed, SheetOpened,
  Sheets, SidebarCollapsedToggled, SidebarToggled, Sidebars, Skeletons, SliderChanged,
  Sliders, Spinners, StartedTrial, Switches, SwitchToggled, TabChanged, Tables, Tabs,
  Toasts, ToggleBoldChanged, ToggleDropdown, ToggleGroupChanged, ToggleGroups,
  ToggleItalicChanged, Toggles, Tooltips,
}
import saola/preview/view as views

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let whatnext = case modem.initial_uri() {
    Ok(uri) -> {
      use dispatch <- effect.from
      dispatch(on_url_change(uri))
    }
    Error(_) -> effect.none()
  }
  #(
    Model(
      route: Home,
      open_dropdown: None,
      active_tab: "account",
      is_dialog_open: False,
      toasts: [],
      form_name: "",
      form_email: "",
      form_message: "",
      form_submitted_values: [],
      switch_notifications: True,
      switch_marketing: False,
      slider_volume: 60,
      slider_brightness: 80,
      select_fruit: "apple",
      select_timezone: "asia/ho_chi_minh",
      accordion_open: [],
      toggle_group_selected: [],
      pagination_page: 1,
      collapsible_open: False,
      popover_open: False,
      alert_dialog_open: False,
      hover_card_open: False,
      input_otp_value: "",
      sheet_open: False,
      menubar_open: "",
      toggle_bold: False,
      toggle_italic: False,
      calendar_selected: None,
      calendar_view_year: 2026,
      calendar_view_month: calendar.May,
      date_picker_selected: None,
      date_picker_open: False,
      date_picker_view_year: 2026,
      date_picker_view_month: calendar.May,
      native_select_value: "apple",
      context_menu_open: False,
      context_menu_x: 0,
      context_menu_y: 0,
      drawer_open: False,
      sidebar_open: True,
      sidebar_collapsed: False,
      command_query: "",
      command_highlighted: -1,
      resizable_sizes: [30.0, 70.0],
      data_table_state: data_table.default_state,
      carousel_index: 0,
      carousel_can_prev: False,
      carousel_can_next: True,
      combobox_value: None,
      combobox_query: "",
      combobox_open: False,
      nav_menu_open: None,
    ),
    effect.batch([modem.init(on_url_change), whatnext]),
  )
}

fn on_url_change(uri: Uri) -> Msg {
  let route = case uri.path {
    "/alerts" -> Alerts
    "/badges" -> Badges
    "/cards" -> Cards
    "/buttons" -> Buttons
    "/inputs" -> Inputs
    "/forms" -> Forms
    "/dropdown-menus" -> DropdownMenus
    "/tabs" -> Tabs
    "/dialogs" -> Dialogs
    "/tables" -> Tables
    "/toasts" -> Toasts
    "/d3-charts" -> D3Charts
    "/monaco-editor" -> MonacoEditor
    "/example-form" -> ExampleForm
    "/example-site" -> ExampleSite
    "/separators" -> Separators
    "/tooltips" -> Tooltips
    "/switches" -> Switches
    "/sliders" -> Sliders
    "/selects" -> Selects
    "/fields" -> Fields
    "/accordions" -> Accordions
    "/progress" -> Progresses
    "/skeletons" -> Skeletons
    "/avatars" -> Avatars
    "/radio-groups" -> RadioGroups
    "/toggles" -> Toggles
    "/toggle-groups" -> ToggleGroups
    "/breadcrumbs" -> Breadcrumbs
    "/paginations" -> Paginations
    "/scroll-areas" -> ScrollAreas
    "/aspect-ratios" -> AspectRatios
    "/collapsibles" -> Collapsibles
    "/popovers" -> Popovers
    "/alert-dialogs" -> AlertDialogs
    "/hover-cards" -> HoverCards
    "/input-otps" -> InputOtps
    "/sheets" -> Sheets
    "/menubars" -> Menubars
    "/calendars" -> Calendars
    "/date-pickers" -> DatePickers
    "/spinners" -> Spinners
    "/native-selects" -> NativeSelects
    "/button-groups" -> ButtonGroups
    "/input-groups" -> InputGroups
    "/context-menus" -> ContextMenus
    "/drawers" -> Drawers
    "/sidebars" -> Sidebars
    "/commands" -> Commands
    "/resizables" -> Resizables
    "/data-tables" -> DataTables
    "/carousels" -> Carousels
    "/comboboxes" -> Comboboxes
    "/navigation-menus" -> NavigationMenus
    _ -> Home
  }
  OnRouteChange(route)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    OnRouteChange(route) -> #(Model(..model, route: route), effect.none())
    ToggleDropdown(id) -> {
      let new_open = case model.open_dropdown {
        Some(current) if current == id -> None
        _ -> Some(id)
      }
      #(Model(..model, open_dropdown: new_open), effect.none())
    }
    TabChanged(id) -> #(Model(..model, active_tab: id), effect.none())
    OpenDialog -> #(Model(..model, is_dialog_open: True), effect.none())
    CloseDialog -> #(Model(..model, is_dialog_open: False), effect.none())
    AddToast(toast) -> #(
      Model(..model, toasts: list.append(model.toasts, [toast])),
      effect.none(),
    )
    DismissToast(id) -> #(
      Model(
        ..model,
        toasts: list.filter(model.toasts, fn(t) { t.id != id }),
      ),
      effect.none(),
    )
    FormNameChanged(name) -> #(Model(..model, form_name: name), effect.none())
    FormEmailChanged(email) -> #(
      Model(..model, form_email: email),
      effect.none(),
    )
    FormMessageChanged(message) -> #(
      Model(..model, form_message: message),
      effect.none(),
    )
    FormSubmitted(values) -> #(
      Model(..model, form_submitted_values: values),
      effect.none(),
    )
    StartedTrial -> #(model, effect.none())
    SwitchToggled(id, value) ->
      case id {
        "notifications" -> #(
          Model(..model, switch_notifications: value),
          effect.none(),
        )
        "marketing" -> #(
          Model(..model, switch_marketing: value),
          effect.none(),
        )
        _ -> #(model, effect.none())
      }
    SliderChanged(id, value) -> {
      let n = int.parse(value) |> result_unwrap(0)
      case id {
        "volume" -> #(Model(..model, slider_volume: n), effect.none())
        "brightness" -> #(Model(..model, slider_brightness: n), effect.none())
        _ -> #(model, effect.none())
      }
    }
    SelectChanged(id, value) ->
      case id {
        "fruit" -> #(Model(..model, select_fruit: value), effect.none())
        "timezone" -> #(Model(..model, select_timezone: value), effect.none())
        _ -> #(model, effect.none())
      }
    AccordionToggled(id) -> {
      let open = case list.contains(model.accordion_open, id) {
        True -> list.filter(model.accordion_open, fn(x) { x != id })
        False -> [id, ..model.accordion_open]
      }
      #(Model(..model, accordion_open: open), effect.none())
    }
    ToggleGroupChanged(selected) -> #(
      Model(..model, toggle_group_selected: selected),
      effect.none(),
    )
    PaginationChanged(page) -> #(
      Model(..model, pagination_page: page),
      effect.none(),
    )
    CollapsibleToggled -> #(
      Model(..model, collapsible_open: !model.collapsible_open),
      effect.none(),
    )
    PopoverClosed -> #(Model(..model, popover_open: False), effect.none())
    AlertDialogOpened -> #(
      Model(..model, alert_dialog_open: True),
      effect.none(),
    )
    AlertDialogConfirmed -> #(
      Model(..model, alert_dialog_open: False),
      effect.none(),
    )
    AlertDialogCancelled -> #(
      Model(..model, alert_dialog_open: False),
      effect.none(),
    )
    HoverCardOpened -> #(Model(..model, hover_card_open: True), effect.none())
    HoverCardClosed -> #(Model(..model, hover_card_open: False), effect.none())
    InputOtpChanged(val) -> #(
      Model(..model, input_otp_value: val),
      effect.none(),
    )
    SheetOpened -> #(Model(..model, sheet_open: True), effect.none())
    SheetClosed -> #(Model(..model, sheet_open: False), effect.none())
    MenubarOpened(menu) -> #(
      Model(..model, menubar_open: menu),
      effect.none(),
    )
    MenubarClosed -> #(Model(..model, menubar_open: ""), effect.none())
    ToggleBoldChanged(val) -> #(
      Model(..model, toggle_bold: val),
      effect.none(),
    )
    ToggleItalicChanged(val) -> #(
      Model(..model, toggle_italic: val),
      effect.none(),
    )
    CalendarDateSelected(date) -> #(
      Model(..model, calendar_selected: Some(date)),
      effect.none(),
    )
    CalendarMonthChanged(year, month) -> #(
      Model(..model, calendar_view_year: year, calendar_view_month: month),
      effect.none(),
    )
    DatePickerDateSelected(date) -> #(
      Model(
        ..model,
        date_picker_selected: Some(date),
        date_picker_open: False,
      ),
      effect.none(),
    )
    DatePickerMonthChanged(year, month) -> #(
      Model(
        ..model,
        date_picker_view_year: year,
        date_picker_view_month: month,
      ),
      effect.none(),
    )
    DatePickerOpenChanged(open) -> #(
      Model(..model, date_picker_open: open),
      effect.none(),
    )
    NativeSelectChanged(val) -> #(
      Model(..model, native_select_value: val),
      effect.none(),
    )
    ContextMenuOpened(x, y) -> #(
      Model(..model, context_menu_open: True, context_menu_x: x, context_menu_y: y),
      effect.none(),
    )
    ContextMenuClosed -> #(
      Model(..model, context_menu_open: False),
      effect.none(),
    )
    DrawerOpened -> #(Model(..model, drawer_open: True), effect.none())
    DrawerClosed -> #(Model(..model, drawer_open: False), effect.none())
    SidebarToggled -> #(
      Model(..model, sidebar_open: !model.sidebar_open),
      effect.none(),
    )
    SidebarCollapsedToggled -> #(
      Model(..model, sidebar_collapsed: !model.sidebar_collapsed),
      effect.none(),
    )
    CommandQueryChanged(q) -> #(
      Model(..model, command_query: q, command_highlighted: -1),
      effect.none(),
    )
    CommandNavUp -> #(
      Model(
        ..model,
        command_highlighted: model.command_highlighted - 1,
      ),
      effect.none(),
    )
    CommandNavDown -> #(
      Model(
        ..model,
        command_highlighted: model.command_highlighted + 1,
      ),
      effect.none(),
    )
    CommandSelected(_) -> #(
      Model(..model, command_query: "", command_highlighted: -1),
      effect.none(),
    )
    ResizableSizesChanged(sizes) -> #(
      Model(..model, resizable_sizes: sizes),
      effect.none(),
    )
    DataTableSortChanged(key) -> #(
      Model(
        ..model,
        data_table_state: data_table.toggle_sort(model.data_table_state, key),
      ),
      effect.none(),
    )
    DataTableFilterChanged(q) -> #(
      Model(
        ..model,
        data_table_state: data_table.set_filter(model.data_table_state, q),
      ),
      effect.none(),
    )
    DataTablePageChanged(p) -> #(
      Model(
        ..model,
        data_table_state: data_table.set_page(model.data_table_state, p),
      ),
      effect.none(),
    )
    DataTableSelectChanged(ids) -> #(
      Model(
        ..model,
        data_table_state: data_table.DataTableState(
          ..model.data_table_state,
          selected: ids,
        ),
      ),
      effect.none(),
    )
    CarouselChanged(idx, can_prev, can_next) -> #(
      Model(
        ..model,
        carousel_index: idx,
        carousel_can_prev: can_prev,
        carousel_can_next: can_next,
      ),
      effect.none(),
    )
    ComboboxOpenChanged(open) -> #(
      Model(..model, combobox_open: open),
      effect.none(),
    )
    ComboboxQueryChanged(q) -> #(
      Model(..model, combobox_query: q),
      effect.none(),
    )
    ComboboxSelected(val) -> #(
      Model(..model, combobox_value: Some(val), combobox_open: False),
      effect.none(),
    )
    NavMenuOpenChanged(id) -> #(
      Model(..model, nav_menu_open: id),
      effect.none(),
    )
  }
}

fn result_unwrap(r: Result(a, e), default: a) -> a {
  case r {
    Ok(v) -> v
    Error(_) -> default
  }
}

fn view(model: Model) -> Element(Msg) {
  h.div([a.class("app-container")], [
    sidebar(model.route),
    main_pane(model),
  ])
}

fn sidebar(current_route: model.Route) -> Element(Msg) {
  h.div([a.class("sidebar")], [
    h.h2([a.class("sidebar-title")], [element.text("UI Showcase")]),
    nav_link("/alerts", "Alerts", current_route == Alerts),
    nav_link("/badges", "Badges", current_route == Badges),
    nav_link("/cards", "Cards", current_route == Cards),
    nav_link("/buttons", "Buttons", current_route == Buttons),
    nav_link("/inputs", "Inputs", current_route == Inputs),
    nav_link("/forms", "Forms", current_route == Forms),
    nav_link("/separators", "Separator", current_route == Separators),
    nav_link("/tooltips", "Tooltip", current_route == Tooltips),
    nav_link("/switches", "Switch", current_route == Switches),
    nav_link("/sliders", "Slider", current_route == Sliders),
    nav_link("/selects", "Select", current_route == Selects),
    nav_link("/fields", "Field", current_route == Fields),
    nav_link("/accordions", "Accordion", current_route == Accordions),
    nav_link("/progress", "Progress", current_route == Progresses),
    nav_link("/skeletons", "Skeleton", current_route == Skeletons),
    nav_link("/avatars", "Avatar", current_route == Avatars),
    nav_link("/radio-groups", "Radio Group", current_route == RadioGroups),
    nav_link("/toggles", "Toggle", current_route == Toggles),
    nav_link("/toggle-groups", "Toggle Group", current_route == ToggleGroups),
    nav_link("/breadcrumbs", "Breadcrumb", current_route == Breadcrumbs),
    nav_link("/paginations", "Pagination", current_route == Paginations),
    nav_link("/scroll-areas", "Scroll Area", current_route == ScrollAreas),
    nav_link("/aspect-ratios", "Aspect Ratio", current_route == AspectRatios),
    nav_link("/collapsibles", "Collapsible", current_route == Collapsibles),
    nav_link("/popovers", "Popover", current_route == Popovers),
    nav_link("/alert-dialogs", "Alert Dialog", current_route == AlertDialogs),
    nav_link("/hover-cards", "Hover Card", current_route == HoverCards),
    nav_link("/input-otps", "Input OTP", current_route == InputOtps),
    nav_link("/sheets", "Sheet", current_route == Sheets),
    nav_link("/menubars", "Menubar", current_route == Menubars),
    nav_link("/calendars", "Calendar", current_route == Calendars),
    nav_link("/date-pickers", "Date Picker", current_route == DatePickers),
    nav_link("/spinners", "Spinner", current_route == Spinners),
    nav_link("/native-selects", "Native Select", current_route == NativeSelects),
    nav_link("/button-groups", "Button Group", current_route == ButtonGroups),
    nav_link("/input-groups", "Input Group", current_route == InputGroups),
    nav_link("/context-menus", "Context Menu", current_route == ContextMenus),
    nav_link("/drawers", "Drawer", current_route == Drawers),
    nav_link("/sidebars", "Sidebar", current_route == Sidebars),
    nav_link("/commands", "Command", current_route == Commands),
    nav_link("/resizables", "Resizable", current_route == Resizables),
    nav_link("/data-tables", "Data Table", current_route == DataTables),
    nav_link("/carousels", "Carousel", current_route == Carousels),
    nav_link("/comboboxes", "Combobox", current_route == Comboboxes),
    nav_link("/navigation-menus", "Navigation Menu", current_route == NavigationMenus),
    nav_link("/dropdown-menus", "Dropdown Menus", current_route == DropdownMenus),
    nav_link("/tabs", "Tabs", current_route == Tabs),
    nav_link("/dialogs", "Dialogs", current_route == Dialogs),
    nav_link("/tables", "Tables", current_route == Tables),
    nav_link("/toasts", "Toasts", current_route == Toasts),
    nav_link("/d3-charts", "D3 Charts", current_route == D3Charts),
    nav_link("/monaco-editor", "Code Editor", current_route == MonacoEditor),
    nav_link("/example-form", "Example Form", current_route == ExampleForm),
    nav_link("/example-site", "Example Site", current_route == ExampleSite),
  ])
}

fn nav_link(path: String, label: String, is_active: Bool) -> Element(Msg) {
  let active_class = case is_active {
    True -> " active"
    False -> ""
  }
  h.a(
    [a.href(path), a.class("nav-link" <> active_class)],
    [element.text(label)],
  )
}

fn main_pane(model: Model) -> Element(Msg) {
  h.div([a.class("main-pane")], [
    case model.route {
      Home -> h.div([], [element.text("Select a widget category to preview.")])
      Alerts -> views.view_alerts()
      Badges -> views.view_badges()
      Cards -> views.view_cards()
      Buttons -> views.view_buttons()
      Inputs -> views.view_inputs()
      Forms -> views.view_forms()
      Separators -> views.view_separators()
      Tooltips -> views.view_tooltips()
      Switches -> views.view_switches(model)
      Sliders -> views.view_sliders(model)
      Selects -> views.view_selects(model)
      Fields -> views.view_fields(model)
      DropdownMenus -> views.view_dropdown_menus(model)
      Tabs -> views.view_tabs(model)
      Dialogs -> views.view_dialogs(model)
      Tables -> views.view_tables()
      Toasts -> views.view_toasts(model)
      Accordions -> views.view_accordions(model)
      Progresses -> views.view_progresses()
      Skeletons -> views.view_skeletons()
      Avatars -> views.view_avatars()
      RadioGroups -> views.view_radio_groups(model)
      Toggles -> views.view_toggles(model)
      ToggleGroups -> views.view_toggle_groups(model)
      Breadcrumbs -> views.view_breadcrumbs()
      Paginations -> views.view_paginations(model)
      ScrollAreas -> views.view_scroll_areas()
      AspectRatios -> views.view_aspect_ratios()
      Collapsibles -> views.view_collapsibles(model)
      Popovers -> views.view_popovers(model)
      AlertDialogs -> views.view_alert_dialogs(model)
      HoverCards -> views.view_hover_cards(model)
      InputOtps -> views.view_input_otps(model)
      Sheets -> views.view_sheets(model)
      Menubars -> views.view_menubars(model)
      Calendars -> views.view_calendars(model)
      DatePickers -> views.view_date_pickers(model)
      Spinners -> views.view_spinners()
      NativeSelects -> views.view_native_selects(model)
      ButtonGroups -> views.view_button_groups()
      InputGroups -> views.view_input_groups()
      ContextMenus -> views.view_context_menus(model)
      Drawers -> views.view_drawers(model)
      Sidebars -> views.view_sidebars(model)
      Commands -> views.view_commands(model)
      Resizables -> views.view_resizables(model)
      DataTables -> views.view_data_tables(model)
      Carousels -> views.view_carousels(model)
      Comboboxes -> views.view_comboboxes(model)
      NavigationMenus -> views.view_navigation_menus(model)
      D3Charts -> views.view_d3_charts()
      MonacoEditor -> views.view_monaco_editor()
      ExampleForm -> views.view_form_example(model)
      ExampleSite -> views.view_small_site_example(model)
    },
  ])
}
