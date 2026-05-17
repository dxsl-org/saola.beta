import gleam/option.{type Option}
import gleam/time/calendar.{type Date, type Month}
import saola/data_table
import saola/toast as saola_toast

// Note: Keep these in sync with the route handlers in view.gleam and the
// nav links in the sidebar.
pub type Route {
  Home
  Alerts
  Badges
  Cards
  Inputs
  Forms
  Buttons
  DropdownMenus
  Tabs
  Dialogs
  Tables
  Toasts
  D3Charts
  MonacoEditor
  ExampleForm
  ExampleSite
  Separators
  Tooltips
  Switches
  Sliders
  Selects
  Fields
  Accordions
  Progresses
  Skeletons
  Avatars
  RadioGroups
  Toggles
  ToggleGroups
  Breadcrumbs
  Paginations
  ScrollAreas
  AspectRatios
  Collapsibles
  Popovers
  AlertDialogs
  HoverCards
  InputOtps
  Sheets
  Menubars
  Calendars
  DatePickers
  Spinners
  NativeSelects
  ButtonGroups
  InputGroups
  ContextMenus
  Drawers
  Sidebars
  Commands
  Resizables
  DataTables
}

pub type Model {
  Model(
    route: Route,
    // ID of the dropdown widget to be open
    // (for the preview page of dropdown menus, where we have many widgets)
    open_dropdown: Option(String),
    // Active tab ID for the Tabs preview page
    active_tab: String,
    // Whether the demo dialog is open
    is_dialog_open: Bool,
    // List of active toasts
    toasts: List(saola_toast.Toast),
    form_name: String,
    form_email: String,
    form_message: String,
    form_submitted_values: List(#(String, String)),
    // Switch preview state: keyed by switch ID
    switch_notifications: Bool,
    switch_marketing: Bool,
    // Slider preview state
    slider_volume: Int,
    slider_brightness: Int,
    // Select preview state
    select_fruit: String,
    select_timezone: String,
    // Accordion preview state
    accordion_open: List(String),
    // Toggle group preview state
    toggle_group_selected: List(String),
    // Pagination preview state
    pagination_page: Int,
    // Collapsible preview state
    collapsible_open: Bool,
    // Popover preview state
    popover_open: Bool,
    // Alert dialog preview state
    alert_dialog_open: Bool,
    // Hover card preview state
    hover_card_open: Bool,
    // Input OTP preview state
    input_otp_value: String,
    // Sheet preview state
    sheet_open: Bool,
    // Menubar preview state
    menubar_open: String,
    // Toggle pressed states
    toggle_bold: Bool,
    toggle_italic: Bool,
    // Calendar / DatePicker preview state
    calendar_selected: Option(Date),
    calendar_view_year: Int,
    calendar_view_month: Month,
    date_picker_selected: Option(Date),
    date_picker_open: Bool,
    date_picker_view_year: Int,
    date_picker_view_month: Month,
    // Native select preview state
    native_select_value: String,
    // Context menu preview state
    context_menu_open: Bool,
    context_menu_x: Int,
    context_menu_y: Int,
    // Drawer preview state
    drawer_open: Bool,
    // Sidebar preview state
    sidebar_open: Bool,
    sidebar_collapsed: Bool,
    // Command preview state
    command_query: String,
    command_highlighted: Int,
    // Resizable preview state
    resizable_sizes: List(Float),
    // Data table preview state
    data_table_state: data_table.DataTableState,
  )
}

pub type Msg {
  OnRouteChange(Route)
  ToggleDropdown(String)
  TabChanged(String)
  OpenDialog
  CloseDialog
  AddToast(saola_toast.Toast)
  DismissToast(String)
  FormNameChanged(String)
  FormEmailChanged(String)
  FormMessageChanged(String)
  FormSubmitted(List(#(String, String)))
  StartedTrial
  SwitchToggled(id: String, value: Bool)
  SliderChanged(id: String, value: String)
  SelectChanged(id: String, value: String)
  AccordionToggled(String)
  ToggleGroupChanged(List(String))
  PaginationChanged(Int)
  CollapsibleToggled
  PopoverClosed
  AlertDialogOpened
  AlertDialogConfirmed
  AlertDialogCancelled
  HoverCardOpened
  HoverCardClosed
  InputOtpChanged(String)
  SheetOpened
  SheetClosed
  MenubarOpened(String)
  MenubarClosed
  ToggleBoldChanged(Bool)
  ToggleItalicChanged(Bool)
  CalendarDateSelected(Date)
  CalendarMonthChanged(Int, Month)
  DatePickerDateSelected(Date)
  DatePickerMonthChanged(Int, Month)
  DatePickerOpenChanged(Bool)
  NativeSelectChanged(String)
  ContextMenuOpened(Int, Int)
  ContextMenuClosed
  DrawerOpened
  DrawerClosed
  SidebarToggled
  SidebarCollapsedToggled
  CommandQueryChanged(String)
  CommandNavUp
  CommandNavDown
  CommandSelected(String)
  ResizableSizesChanged(List(Float))
  DataTableSortChanged(String)
  DataTableFilterChanged(String)
  DataTablePageChanged(Int)
  DataTableSelectChanged(List(String))
}
