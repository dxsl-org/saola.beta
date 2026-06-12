import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/time/calendar.{
  type Date, type Month, April, August, Date, December, February, January, July,
  June, March, May, November, October, September, month_to_int, month_to_string,
}
import gleam/time/timestamp
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type CalendarAttrs {
  CalendarAttrs(today: Option(Date), show_outside_days: Bool, class: String)
}

pub const default_attrs = CalendarAttrs(
  today: None,
  show_outside_days: True,
  class: "",
)

// ── Date helpers ──────────────────────────────────────────

fn days_in_month(year: Int, month: Month) -> Int {
  case month {
    January | March | May | July | August | October | December -> 31
    April | June | September | November -> 30
    February ->
      case calendar.is_leap_year(year) {
        True -> 29
        False -> 28
      }
  }
}

// Zeller's congruence — returns 0=Sunday … 6=Saturday
fn day_of_week(year: Int, month: Month) -> Int {
  let m = month_to_int(month)
  let #(zm, zy) = case m <= 2 {
    True -> #(m + 12, year - 1)
    False -> #(m, year)
  }
  let k = zy % 100
  let j = zy / 100
  let h = { 1 + 13 * { zm + 1 } / 5 + k + k / 4 + j / 4 - 2 * j } % 7
  let dow = { h + 6 } % 7
  case dow < 0 {
    True -> dow + 7
    False -> dow
  }
}

pub fn prev_month(year: Int, month: Month) -> #(Int, Month) {
  case month {
    January -> #(year - 1, December)
    February -> #(year, January)
    March -> #(year, February)
    April -> #(year, March)
    May -> #(year, April)
    June -> #(year, May)
    July -> #(year, June)
    August -> #(year, July)
    September -> #(year, August)
    October -> #(year, September)
    November -> #(year, October)
    December -> #(year, November)
  }
}

pub fn next_month(year: Int, month: Month) -> #(Int, Month) {
  case month {
    January -> #(year, February)
    February -> #(year, March)
    March -> #(year, April)
    April -> #(year, May)
    May -> #(year, June)
    June -> #(year, July)
    July -> #(year, August)
    August -> #(year, September)
    September -> #(year, October)
    October -> #(year, November)
    November -> #(year, December)
    December -> #(year + 1, January)
  }
}

/// Return the current local date. Uses the system clock.
pub fn today() -> Date {
  let #(date, _) =
    timestamp.to_calendar(timestamp.system_time(), calendar.local_offset())
  date
}

fn cell_indices(n: Int) -> List(Int) {
  case n <= 0 {
    True -> []
    False -> list.append(cell_indices(n - 1), [n - 1])
  }
}

// For a given cell index (0..41), return the date it represents and
// whether it belongs to the current month.
fn cell_date(
  idx: Int,
  year: Int,
  month: Month,
  first_dow: Int,
  dim: Int,
) -> #(Date, Bool) {
  case idx < first_dow {
    True -> {
      let #(py, pm) = prev_month(year, month)
      let prev_dim = days_in_month(py, pm)
      #(Date(py, pm, prev_dim - first_dow + idx + 1), False)
    }
    False ->
      case idx < first_dow + dim {
        True -> #(Date(year, month, idx - first_dow + 1), True)
        False -> {
          let #(ny, nm) = next_month(year, month)
          #(Date(ny, nm, idx - first_dow - dim + 1), False)
        }
      }
  }
}

fn dates_equal(a: Date, b: Date) -> Bool {
  a.year == b.year && a.month == b.month && a.day == b.day
}

// ── Rendering ─────────────────────────────────────────────

fn render_day_cell(
  date: Date,
  is_current_month: Bool,
  selected: Option(Date),
  today: Option(Date),
  show_outside: Bool,
  on_select: fn(Date) -> msg,
) -> Element(msg) {
  let is_selected = case selected {
    Some(s) -> dates_equal(date, s)
    None -> False
  }
  let is_today = case today {
    Some(t) -> dates_equal(date, t)
    None -> False
  }
  let base_class = case is_selected {
    True -> "calendar-day calendar-day-selected"
    False ->
      case is_today {
        True -> "calendar-day calendar-day-today"
        False ->
          case is_current_month {
            True -> "calendar-day"
            False -> "calendar-day calendar-day-outside"
          }
      }
  }
  case !is_current_month && !show_outside {
    True -> h.div([a.class("calendar-day calendar-day-empty")], [])
    False -> {
      let selected_attrs = case is_selected {
        True -> [a.attribute("aria-selected", "true")]
        False -> []
      }
      let disabled_attrs = case !is_current_month {
        True -> [a.attribute("aria-disabled", "true")]
        False -> []
      }
      h.button(
        list.flatten([
          [
            a.type_("button"),
            a.class(base_class),
            a.attribute(
              "aria-label",
              month_to_string(date.month)
                <> " "
                <> int.to_string(date.day)
                <> ", "
                <> int.to_string(date.year),
            ),
            e.on_click(on_select(date)),
          ],
          selected_attrs,
          disabled_attrs,
        ]),
        [h.text(int.to_string(date.day))],
      )
    }
  }
}

pub fn calendar(
  selected: Option(Date),
  view_year: Int,
  view_month: Month,
  on_select: fn(Date) -> msg,
  on_prev_month: msg,
  on_next_month: msg,
  attrs: CalendarAttrs,
) -> Element(msg) {
  let dim = days_in_month(view_year, view_month)
  let first_dow = day_of_week(view_year, view_month)
  let extra_class_attrs = case attrs.class {
    "" -> []
    c -> [a.class(c)]
  }
  let day_headers =
    ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    |> list.map(fn(d) { h.div([a.class("calendar-day-header")], [h.text(d)]) })
  let cells =
    cell_indices(42)
    |> list.map(fn(idx) {
      let #(date, is_current) =
        cell_date(idx, view_year, view_month, first_dow, dim)
      render_day_cell(
        date,
        is_current,
        selected,
        attrs.today,
        attrs.show_outside_days,
        on_select,
      )
    })
  h.div(list.flatten([[a.class("calendar")], extra_class_attrs]), [
    h.div([a.class("calendar-header")], [
      h.button(
        [
          a.type_("button"),
          a.class("calendar-nav-btn"),
          a.attribute("aria-label", "Previous month"),
          e.on_click(on_prev_month),
        ],
        [h.text("‹")],
      ),
      h.div([a.class("calendar-title")], [
        h.text(month_to_string(view_month) <> " " <> int.to_string(view_year)),
      ]),
      h.button(
        [
          a.type_("button"),
          a.class("calendar-nav-btn"),
          a.attribute("aria-label", "Next month"),
          e.on_click(on_next_month),
        ],
        [h.text("›")],
      ),
    ]),
    h.div([a.class("calendar-grid")], list.append(day_headers, cells)),
  ])
}

pub fn calendar_simple(
  selected: Option(Date),
  view_year: Int,
  view_month: Month,
  on_select: fn(Date) -> msg,
  on_prev_month: msg,
  on_next_month: msg,
) -> Element(msg) {
  calendar(
    selected,
    view_year,
    view_month,
    on_select,
    on_prev_month,
    on_next_month,
    default_attrs,
  )
}
