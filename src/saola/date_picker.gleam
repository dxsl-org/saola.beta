//// Date picker widget (trigger + calendar popover) — dual-style `Config`:
////
//// ```gleam
//// date_picker.date_picker_simple(sel, open, yr, mo, OnSel, OnMonth, OnOpen)  // shortcut
//// date_picker.new()
//// |> date_picker.placeholder("Choose a date")
//// |> date_picker.view(sel, open, yr, mo, OnSel, OnMonth, OnOpen)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/time/calendar.{type Date, type Month, month_to_int, month_to_string}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/calendar as cal

/// Presentation options for a date picker. Public for record-update syntax. The
/// selected/open/view_year/view_month/handlers are the required data (`view`).
pub type DatePickerConfig {
  DatePickerConfig(placeholder: String, disabled: Bool, class: String)
}

/// Builder entry point. Defaults: "Pick a date" placeholder, enabled.
pub fn new() -> DatePickerConfig {
  DatePickerConfig(placeholder: "Pick a date", disabled: False, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> DatePickerConfig {
  new()
}

/// Set the trigger placeholder (shown when no date is selected).
pub fn placeholder(config: DatePickerConfig, placeholder: String) -> DatePickerConfig {
  DatePickerConfig(..config, placeholder: placeholder)
}

/// Set the disabled state.
pub fn disabled(config: DatePickerConfig, disabled: Bool) -> DatePickerConfig {
  DatePickerConfig(..config, disabled: disabled)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: DatePickerConfig, class: String) -> DatePickerConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  DatePickerConfig(..config, class: merged)
}

fn format_date(date: Date) -> String {
  month_to_string(date.month)
  <> " "
  <> int.to_string(date.day)
  <> ", "
  <> int.to_string(date.year)
}

/// Render the date picker. `open` is consumer-owned; the popover hosts a
/// calendar wired to `on_select`/`on_month_change`.
pub fn view(
  config: DatePickerConfig,
  selected: Option(Date),
  open: Bool,
  view_year: Int,
  view_month: Month,
  on_select: fn(Date) -> msg,
  on_month_change: fn(Int, Month) -> msg,
  on_open_change: fn(Bool) -> msg,
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  let display_text = case selected {
    None -> config.placeholder
    Some(d) -> format_date(d)
  }
  let #(prev_year, prev_month) = prev_month_nav(view_year, view_month)
  let #(next_year, next_month) = next_month_nav(view_year, view_month)
  h.div(list.flatten([[a.class("date-picker")], extra_class_attrs]), [
    h.button(
      list.flatten([
        [
          a.type_("button"),
          a.class(case selected {
            None -> "date-picker-trigger date-picker-placeholder"
            Some(_) -> "date-picker-trigger"
          }),
        ],
        disabled_attrs,
        [
          a.attribute("aria-haspopup", "dialog"),
          a.attribute("aria-expanded", case open {
            True -> "true"
            False -> "false"
          }),
          e.on_click(on_open_change(!open)),
        ],
      ]),
      [
        h.span([a.class("date-picker-icon")], [h.text("📅")]),
        h.text(display_text),
      ],
    ),
    case open {
      False -> h.text("")
      True ->
        h.div([a.class("date-picker-popover"), a.role("dialog")], [
          cal.view(
            cal.new(),
            selected,
            view_year,
            view_month,
            fn(date) { on_select(date) },
            on_month_change(prev_year, prev_month),
            on_month_change(next_year, next_month),
          ),
        ])
    },
  ])
}

// --- Convenience shortcuts ---

pub fn date_picker_simple(
  selected: Option(Date),
  open: Bool,
  view_year: Int,
  view_month: Month,
  on_select: fn(Date) -> msg,
  on_month_change: fn(Int, Month) -> msg,
  on_open_change: fn(Bool) -> msg,
) -> Element(msg) {
  new()
  |> view(
    selected,
    open,
    view_year,
    view_month,
    on_select,
    on_month_change,
    on_open_change,
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
