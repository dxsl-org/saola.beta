import gleam/option.{None, Some}
import gleam/string
import gleam/time/calendar.{type Date, April, Date, February, January, March}
import lustre/element
import saola/calendar as cal
import saola/date_picker

// msg type for tests: Option(Date) — None serves as a no-op message

fn on_select(d: Date) -> option.Option(Date) {
  Some(d)
}

fn on_prev() -> option.Option(Date) {
  None
}

fn on_next() -> option.Option(Date) {
  None
}

// --- calendar helpers ---

pub fn prev_month_jan_wraps_test() {
  let #(y, m) = cal.prev_month(2026, January)
  let assert 2025 = y
  let assert calendar.December = m
}

pub fn prev_month_mid_year_test() {
  let #(y, m) = cal.prev_month(2026, April)
  let assert 2026 = y
  let assert March = m
}

pub fn next_month_dec_wraps_test() {
  let #(y, m) = cal.next_month(2025, calendar.December)
  let assert 2026 = y
  let assert January = m
}

pub fn next_month_mid_year_test() {
  let #(y, m) = cal.next_month(2026, March)
  let assert 2026 = y
  let assert April = m
}

pub fn today_returns_date_test() {
  let d = cal.today_date()
  let assert True = d.year >= 2024
  let assert True = d.day >= 1
  let assert True = d.day <= 31
}

// --- calendar rendering ---

pub fn calendar_simple_renders_test() {
  let html =
    cal.calendar_simple(
      None,
      2026,
      calendar.May,
      on_select,
      on_prev(),
      on_next(),
    )
    |> element.to_string()
  let assert True = string.contains(html, "calendar")
  let assert True = string.contains(html, "May 2026")
  let assert True = string.contains(html, "calendar-grid")
}

pub fn calendar_renders_day_headers_test() {
  let html =
    cal.calendar_simple(None, 2026, January, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "Su")
  let assert True = string.contains(html, "Mo")
  let assert True = string.contains(html, "Sa")
}

pub fn calendar_renders_cells_test() {
  let html =
    cal.calendar_simple(None, 2026, January, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "calendar-day")
}

pub fn calendar_nav_buttons_test() {
  let html =
    cal.calendar_simple(None, 2026, January, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "Previous month")
  let assert True = string.contains(html, "Next month")
  let assert True = string.contains(html, "calendar-nav-btn")
}

pub fn calendar_selected_date_test() {
  let selected = Some(Date(2026, January, 15))
  let html =
    cal.calendar_simple(
      selected,
      2026,
      January,
      on_select,
      on_prev(),
      on_next(),
    )
    |> element.to_string()
  let assert True = string.contains(html, "calendar-day-selected")
  let assert True = string.contains(html, "aria-selected")
}

pub fn calendar_today_highlight_test() {
  let today = Date(2026, January, 10)
  let html =
    cal.new()
    |> cal.today(today)
    |> cal.view(None, 2026, January, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "calendar-day-today")
}

pub fn calendar_outside_days_hidden_test() {
  let html =
    cal.new()
    |> cal.show_outside_days(False)
    |> cal.view(None, 2026, January, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "calendar-day-empty")
}

pub fn calendar_outside_days_shown_by_default_test() {
  let html =
    cal.calendar_simple(None, 2026, February, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "calendar-day-outside")
}

pub fn calendar_title_shows_month_year_test() {
  let html =
    cal.calendar_simple(None, 2026, March, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "March 2026")
}

pub fn calendar_aria_label_on_day_test() {
  let html =
    cal.calendar_simple(None, 2026, January, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "aria-label")
  let assert True = string.contains(html, "January")
}

pub fn calendar_custom_class_test() {
  let html =
    cal.new()
    |> cal.add_class("my-custom")
    |> cal.view(None, 2026, January, on_select, on_prev(), on_next())
    |> element.to_string()
  let assert True = string.contains(html, "my-custom")
}

// --- date_picker rendering ---
// msg type for date_picker tests: Result(Date, Nil)

fn dp_on_select(d: Date) -> Result(Date, Nil) {
  Ok(d)
}

fn dp_on_month(_y: Int, _m: calendar.Month) -> Result(Date, Nil) {
  Error(Nil)
}

fn dp_on_open(_b: Bool) -> Result(Date, Nil) {
  Error(Nil)
}

pub fn date_picker_simple_renders_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "date-picker")
  let assert True = string.contains(html, "date-picker-trigger")
}

pub fn date_picker_shows_placeholder_when_no_selection_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "Pick a date")
  let assert True = string.contains(html, "date-picker-placeholder")
}

pub fn date_picker_shows_selected_date_test() {
  let selected = Some(Date(2026, January, 20))
  let html =
    date_picker.date_picker_simple(
      selected,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "January 20, 2026")
}

pub fn date_picker_closed_hides_calendar_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert False = string.contains(html, "calendar-grid")
}

pub fn date_picker_open_shows_calendar_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      True,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "date-picker-popover")
  let assert True = string.contains(html, "calendar-grid")
  let assert True = string.contains(html, "role=\"dialog\"")
}

pub fn date_picker_aria_expanded_false_when_closed_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "aria-expanded=\"false\"")
}

pub fn date_picker_aria_expanded_true_when_open_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      True,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "aria-expanded=\"true\"")
}

pub fn date_picker_custom_placeholder_test() {
  let html =
    date_picker.new()
    |> date_picker.placeholder("Select a date...")
    |> date_picker.view(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "Select a date...")
}

pub fn date_picker_disabled_test() {
  let html =
    date_picker.new()
    |> date_picker.disabled(True)
    |> date_picker.view(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "disabled")
}

pub fn date_picker_has_calendar_icon_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "date-picker-icon")
}

pub fn date_picker_aria_haspopup_test() {
  let html =
    date_picker.date_picker_simple(
      None,
      False,
      2026,
      January,
      dp_on_select,
      dp_on_month,
      dp_on_open,
    )
    |> element.to_string()
  let assert True = string.contains(html, "aria-haspopup=\"dialog\"")
}
