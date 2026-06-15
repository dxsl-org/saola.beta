import gleam/string
import lustre/element
import lustre/element/html as h
import saola/alert_dialog
import saola/aspect_ratio
import saola/breadcrumb
import saola/collapsible
import saola/hover_card
import saola/input_otp
import saola/menubar
import saola/pagination
import saola/popover
import saola/radio_group
import saola/scroll_area
import saola/sheet
import saola/toggle
import saola/toggle_group

// --- radio_group ---

pub fn radio_group_simple_renders_test() {
  let html =
    radio_group.radio_group_simple(
      options: [
        radio_group.RadioOption("a", "Option A"),
        radio_group.RadioOption("b", "Option B"),
      ],
      value: "a",
      name: "demo",
      on_change: fn(v) { v },
    )
    |> element.to_string
  assert string.contains(html, "role=\"radiogroup\"")
  assert string.contains(html, "type=\"radio\"")
  assert string.contains(html, "Option A")
  assert string.contains(html, "Option B")
}

pub fn radio_group_selected_is_checked_test() {
  let html =
    radio_group.radio_group_simple(
      options: [radio_group.RadioOption("x", "X")],
      value: "x",
      name: "n",
      on_change: fn(v) { v },
    )
    |> element.to_string
  assert string.contains(html, "checked")
}

pub fn radio_group_horizontal_has_data_orientation_test() {
  let html =
    radio_group.new()
    |> radio_group.orientation(radio_group.Horizontal)
    |> radio_group.view(
      [radio_group.RadioOption("a", "A")],
      "a",
      fn(v) { v },
    )
    |> element.to_string
  assert string.contains(html, "data-orientation=\"horizontal\"")
}

pub fn radio_group_disabled_option_test() {
  let html =
    radio_group.radio_group_simple(
      options: [radio_group.RadioOptionDisabled("d", "Disabled")],
      value: "",
      name: "n",
      on_change: fn(v) { v },
    )
    |> element.to_string
  assert string.contains(html, "disabled")
}

// --- toggle ---

pub fn toggle_simple_renders_test() {
  let html =
    toggle.toggle_simple(False, "Bold", fn(v) { v })
    |> element.to_string
  assert string.contains(html, "type=\"button\"")
  assert string.contains(html, "aria-pressed=\"false\"")
  assert string.contains(html, "Bold")
}

pub fn toggle_pressed_has_aria_pressed_true_test() {
  let html =
    toggle.toggle_simple(True, "Bold", fn(v) { v })
    |> element.to_string
  assert string.contains(html, "aria-pressed=\"true\"")
}

pub fn toggle_disabled_test() {
  let html =
    toggle.toggle(
      False,
      "X",
      fn(v) { v },
      toggle.ToggleAttrs(..toggle.default_attrs, disabled: True),
    )
    |> element.to_string
  assert string.contains(html, "disabled")
}

// --- toggle_group ---

pub fn toggle_group_renders_test() {
  let html =
    toggle_group.toggle_group_simple(
      [
        toggle_group.ToggleGroupItem("a", "A"),
        toggle_group.ToggleGroupItem("b", "B"),
      ],
      ["a"],
      fn(v) { v },
    )
    |> element.to_string
  assert string.contains(html, "role=\"group\"")
  assert string.contains(html, "data-value=\"a\"")
  assert string.contains(html, "data-value=\"b\"")
}

pub fn toggle_group_selected_has_aria_pressed_true_test() {
  let html =
    toggle_group.toggle_group_simple(
      [toggle_group.ToggleGroupItem("x", "X")],
      ["x"],
      fn(v) { v },
    )
    |> element.to_string
  assert string.contains(html, "aria-pressed=\"true\"")
}

// --- breadcrumb ---

pub fn breadcrumb_renders_test() {
  let html =
    breadcrumb.breadcrumb_simple([
      breadcrumb.BreadcrumbLink("Home", "/"),
      breadcrumb.BreadcrumbPage("Current"),
    ])
    |> element.to_string
  assert string.contains(html, "aria-label=\"Breadcrumb\"")
  assert string.contains(html, "class=\"breadcrumb\"")
  assert string.contains(html, "Home")
  assert string.contains(html, "aria-current=\"page\"")
}

pub fn breadcrumb_separator_renders_test() {
  let html =
    breadcrumb.breadcrumb_simple([
      breadcrumb.BreadcrumbLink("A", "/a"),
      breadcrumb.BreadcrumbPage("B"),
    ])
    |> element.to_string
  assert string.contains(html, "breadcrumb-separator")
  assert string.contains(html, "aria-hidden=\"true\"")
}

// --- pagination ---

pub fn pagination_renders_test() {
  let html =
    pagination.pagination_simple(2, 5, fn(p) { p })
    |> element.to_string
  assert string.contains(html, "role=\"navigation\"")
  assert string.contains(html, "class=\"pagination")
  assert string.contains(html, "Previous")
  assert string.contains(html, "Next")
}

pub fn pagination_current_page_aria_current_test() {
  let html =
    pagination.pagination_simple(3, 5, fn(p) { p })
    |> element.to_string
  assert string.contains(html, "aria-current=\"page\"")
}

pub fn pagination_first_page_prev_disabled_test() {
  let html =
    pagination.pagination_simple(1, 5, fn(p) { p })
    |> element.to_string
  assert string.contains(html, "disabled")
}

// --- scroll_area ---

pub fn scroll_area_renders_test() {
  let html =
    scroll_area.scroll_area_simple(h.p([], [h.text("content")]), "200px")
    |> element.to_string
  assert string.contains(html, "class=\"scroll-area")
  assert string.contains(html, "class=\"scroll-area-viewport\"")
  assert string.contains(html, "content")
}

pub fn scroll_area_viewport_has_role_region_test() {
  let html =
    scroll_area.scroll_area_simple(h.p([], [h.text("data")]), "300px")
    |> element.to_string
  assert string.contains(html, "role=\"region\"")
}

pub fn scroll_area_viewport_has_aria_label_test() {
  let html =
    scroll_area.scroll_area_simple(h.p([], [h.text("data")]), "300px")
    |> element.to_string
  assert string.contains(html, "aria-label=\"Scrollable content\"")
}

// --- aspect_ratio ---

pub fn aspect_ratio_renders_test() {
  let html =
    aspect_ratio.aspect_ratio(16.0 /. 9.0, h.text("content"))
    |> element.to_string
  assert string.contains(html, "class=\"aspect-ratio\"")
  assert string.contains(html, "padding-bottom")
}

// --- collapsible ---

pub fn collapsible_closed_has_aria_hidden_test() {
  let html =
    collapsible.collapsible_simple(False, "Show", h.text("content"), fn() {
      Nil
    })
    |> element.to_string
  assert string.contains(html, "aria-expanded=\"false\"")
  assert string.contains(html, "aria-hidden=\"true\"")
}

pub fn collapsible_open_test() {
  let html =
    collapsible.collapsible_simple(True, "Hide", h.text("content"), fn() { Nil })
    |> element.to_string
  assert string.contains(html, "aria-expanded=\"true\"")
  assert string.contains(html, "aria-hidden=\"false\"")
}

// --- popover ---

pub fn popover_closed_renders_no_content_test() {
  let html =
    popover.popover_simple(
      False,
      h.button([], [h.text("Trigger")]),
      h.text("pop"),
      fn() { Nil },
    )
    |> element.to_string
  assert string.contains(html, "popover-wrapper")
  assert !string.contains(html, "role=\"dialog\"")
}

pub fn popover_open_renders_content_test() {
  let html =
    popover.popover_simple(
      True,
      h.button([], [h.text("Trigger")]),
      h.p([], [h.text("popover content")]),
      fn() { Nil },
    )
    |> element.to_string
  assert string.contains(html, "role=\"dialog\"")
  assert string.contains(html, "popover content")
}

// --- alert_dialog ---

pub fn alert_dialog_closed_renders_empty_test() {
  let html =
    alert_dialog.alert_dialog_simple(False, "Title", "Desc", Nil, Nil)
    |> element.to_string
  assert !string.contains(html, "role=\"alertdialog\"")
}

pub fn alert_dialog_open_renders_content_test() {
  let html =
    alert_dialog.alert_dialog_simple(
      True,
      "Delete?",
      "Cannot be undone.",
      Nil,
      Nil,
    )
    |> element.to_string
  assert string.contains(html, "role=\"alertdialog\"")
  assert string.contains(html, "aria-modal=\"true\"")
  assert string.contains(html, "Delete?")
  assert string.contains(html, "Cannot be undone.")
}

// --- hover_card ---

pub fn hover_card_closed_renders_no_card_test() {
  let html =
    hover_card.hover_card_simple(
      False,
      h.span([], [h.text("trigger")]),
      h.text("card"),
    )
    |> element.to_string
  assert string.contains(html, "hover-card-wrapper")
  assert !string.contains(html, "role=\"tooltip\"")
}

pub fn hover_card_open_renders_card_test() {
  let html =
    hover_card.hover_card_simple(
      True,
      h.span([], [h.text("trigger")]),
      h.p([], [h.text("card content")]),
    )
    |> element.to_string
  assert string.contains(html, "role=\"tooltip\"")
  assert string.contains(html, "card content")
}

// --- input_otp ---

pub fn input_otp_renders_slots_test() {
  let html =
    input_otp.input_otp_simple("", fn(v) { v })
    |> element.to_string
  assert string.contains(html, "class=\"input-otp")
  assert string.contains(html, "aria-label=\"One-time password\"")
  assert string.contains(html, "otp-slot-0")
  assert string.contains(html, "otp-slot-5")
}

pub fn input_otp_custom_length_test() {
  let html =
    input_otp.input_otp(
      "",
      fn(v) { v },
      input_otp.InputOtpAttrs(..input_otp.default_attrs, length: 4),
    )
    |> element.to_string
  assert string.contains(html, "otp-slot-3")
  assert !string.contains(html, "otp-slot-4")
}

// --- sheet ---

pub fn sheet_closed_renders_empty_test() {
  let html =
    sheet.sheet_simple(False, "Title", h.text("content"), fn() { Nil })
    |> element.to_string
  assert !string.contains(html, "role=\"dialog\"")
}

pub fn sheet_open_renders_content_test() {
  let html =
    sheet.sheet_simple(True, "My Sheet", h.p([], [h.text("sheet body")]), fn() {
      Nil
    })
    |> element.to_string
  assert string.contains(html, "role=\"dialog\"")
  assert string.contains(html, "My Sheet")
  assert string.contains(html, "sheet body")
}

pub fn sheet_side_class_test() {
  let html =
    sheet.sheet(
      True,
      "Left",
      h.text(""),
      fn() { Nil },
      sheet.SheetAttrs(side: sheet.Left, class: ""),
    )
    |> element.to_string
  assert string.contains(html, "sheet-left")
}

// --- menubar ---

pub fn menubar_renders_test() {
  let html =
    menubar.menubar_simple(
      [menubar.MenubarItem("File", [menubar.MenubarSubItem("New", Nil)])],
      "",
      fn(_) { Nil },
      fn() { Nil },
    )
    |> element.to_string
  assert string.contains(html, "role=\"menubar\"")
  assert string.contains(html, "File")
  assert string.contains(html, "aria-haspopup=\"menu\"")
}

pub fn menubar_open_menu_shows_items_test() {
  let html =
    menubar.menubar_simple(
      [
        menubar.MenubarItem("Edit", [
          menubar.MenubarSubItem("Cut", Nil),
          menubar.MenubarSeparator,
          menubar.MenubarSubItem("Copy", Nil),
        ]),
      ],
      "Edit",
      fn(_) { Nil },
      fn() { Nil },
    )
    |> element.to_string
  assert string.contains(html, "role=\"menu\"")
  assert string.contains(html, "Cut")
  assert string.contains(html, "Copy")
  assert string.contains(html, "role=\"separator\"")
}
