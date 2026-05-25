import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/time/calendar.{type Date, type Month, month_to_int, month_to_string}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/calendar as cal

pub type DatePickerAttrs {
  DatePickerAttrs(
    placeholder: String,
    disabled: Bool,
    class: String,
  )
}

pub const default_attrs = DatePickerAttrs(
  placeholder: "Pick a date",
  disabled: False,
  class: "",
)

fn format_date(date: Date) -> String {
  month_to_string(date.month)
  <> " "
  <> int.to_string(date.day)
  <> ", "
  <> int.to_string(date.year)
}

pub fn date_picker_full(
  selected: Option(Date),
  open: Bool,
  view_year: Int,
  view_month: Month,
  on_select: fn(Date) -> msg,
  on_month_change: fn(Int, Month) -> msg,
  on_open_change: fn(Bool) -> msg,
  attrs: DatePickerAttrs,
) -> Element(msg) {
  let extra_class = case attrs.class {
    "" -> a.none()
    c -> a.class(c)
  }
  let display_text = case selected {
    None -> attrs.placeholder
    Some(d) -> format_date(d)
  }
  let #(prev_year, prev_month) = prev_month_nav(view_year, view_month)
  let #(next_year, next_month) = next_month_nav(view_year, view_month)
  h.div(
    [a.class("date-picker"), extra_class],
    [
      h.button(
        [
          a.type_("button"),
          a.class(case selected {
            None -> "date-picker-trigger date-picker-placeholder"
            Some(_) -> "date-picker-trigger"
          }),
          case attrs.disabled {
            True -> a.disabled(True)
            False -> a.none()
          },
          a.attribute("aria-haspopup", "dialog"),
          a.attribute("aria-expanded", case open {
            True -> "true"
            False -> "false"
          }),
          e.on_click(on_open_change(!open)),
        ],
        [
          h.span([a.class("date-picker-icon")], [h.text("📅")]),
          h.text(display_text),
        ],
      ),
      case open {
        False -> h.text("")
        True ->
          h.div(
            [a.class("date-picker-popover"), a.role("dialog")],
            [
              cal.calendar_full(
                selected,
                view_year,
                view_month,
                fn(date) {
                  on_select(date)
                },
                on_month_change(prev_year, prev_month),
                on_month_change(next_year, next_month),
                cal.default_attrs,
              ),
            ],
          )
      },
    ],
  )
}

pub fn date_picker_simple(
  selected: Option(Date),
  open: Bool,
  view_year: Int,
  view_month: Month,
  on_select: fn(Date) -> msg,
  on_month_change: fn(Int, Month) -> msg,
  on_open_change: fn(Bool) -> msg,
) -> Element(msg) {
  date_picker_full(
    selected,
    open,
    view_year,
    view_month,
    on_select,
    on_month_change,
    on_open_change,
    default_attrs,
  )
}

fn prev_month_nav(year: Int, month: Month) -> #(Int, Month) {
  let m = month_to_int(month)
  case m {
    1 -> #(year - 1, to_month(12))
    _ -> #(year, to_month(m - 1))
  }
}

fn next_month_nav(year: Int, month: Month) -> #(Int, Month) {
  let m = month_to_int(month)
  case m {
    12 -> #(year + 1, to_month(1))
    _ -> #(year, to_month(m + 1))
  }
}

fn to_month(n: Int) -> Month {
  case calendar.month_from_int(n) {
    Ok(m) -> m
    Error(_) -> calendar.January
  }
}
