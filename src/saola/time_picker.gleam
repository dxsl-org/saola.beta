//// Time picker widget (native selects) — dual-style `Config` (uniform pattern):
////
//// ```gleam
//// time_picker.time_picker_simple(model.time, TimeChanged)           // shortcut (24h)
//// time_picker.new()
//// |> time_picker.format(time_picker.TwelveHour)
//// |> time_picker.show_seconds(True)
//// |> time_picker.view(model.time, TimeChanged)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type TimePickerFormat {
  TwelveHour
  TwentyFourHour
}

pub type TimeValue {
  TimeValue(hour: Int, minute: Int, second: Option(Int))
}

/// Presentation options for a time picker. Public for record-update syntax. The
/// `value` and `on_change` are the required data, passed to `view`.
pub type TimePickerConfig {
  TimePickerConfig(
    format: TimePickerFormat,
    show_seconds: Bool,
    disabled: Bool,
    class: String,
  )
}

/// Builder entry point. Defaults: 24-hour, no seconds, enabled, no class.
pub fn new() -> TimePickerConfig {
  TimePickerConfig(
    format: TwentyFourHour,
    show_seconds: False,
    disabled: False,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> TimePickerConfig {
  new()
}

/// Set the hour format (TwelveHour, TwentyFourHour — default).
pub fn format(config: TimePickerConfig, format: TimePickerFormat) -> TimePickerConfig {
  TimePickerConfig(..config, format: format)
}

/// Show a seconds select (default off).
pub fn show_seconds(config: TimePickerConfig, show: Bool) -> TimePickerConfig {
  TimePickerConfig(..config, show_seconds: show)
}

/// Set the disabled state.
pub fn disabled(config: TimePickerConfig, disabled: Bool) -> TimePickerConfig {
  TimePickerConfig(..config, disabled: disabled)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: TimePickerConfig, class: String) -> TimePickerConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  TimePickerConfig(..config, class: merged)
}

/// Render the time picker (hour, minute, optional second selects).
pub fn view(
  config: TimePickerConfig,
  value: Option(TimeValue),
  on_change: fn(TimeValue) -> msg,
) -> Element(msg) {
  let current = case value {
    None -> TimeValue(0, 0, None)
    Some(v) -> v
  }
  let root_class = case config.class {
    "" -> "time-picker"
    c -> "time-picker " <> c
  }
  let max_hour = case config.format {
    TwelveHour -> 12
    TwentyFourHour -> 23
  }
  let min_hour = case config.format {
    TwelveHour -> 1
    TwentyFourHour -> 0
  }
  let hour_opts = range(min_hour, max_hour)
  let minute_opts = range(0, 59)
  let second_opts = range(0, 59)

  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }

  let hour_select =
    h.div([a.class("time-picker-field")], [
      h.label([a.class("time-picker-label")], [h.text("HH")]),
      h.select(
        list.flatten([
          [
            a.class("select time-picker-select"),
            a.attribute("aria-label", "Hour"),
            e.on_change(fn(v) {
              let h = int.parse(v) |> result_unwrap(current.hour)
              on_change(TimeValue(..current, hour: h))
            }),
          ],
          disabled_attrs,
        ]),
        list.map(hour_opts, fn(n) {
          let selected_attrs = case n == current.hour {
            True -> [a.selected(True)]
            False -> []
          }
          h.option(
            list.flatten([[a.value(int.to_string(n))], selected_attrs]),
            pad2(n),
          )
        }),
      ),
    ])

  let colon1 = h.span([a.class("time-picker-sep")], [h.text(":")])

  let minute_select =
    h.div([a.class("time-picker-field")], [
      h.label([a.class("time-picker-label")], [h.text("MM")]),
      h.select(
        list.flatten([
          [
            a.class("select time-picker-select"),
            a.attribute("aria-label", "Minute"),
            e.on_change(fn(v) {
              let m = int.parse(v) |> result_unwrap(current.minute)
              on_change(TimeValue(..current, minute: m))
            }),
          ],
          disabled_attrs,
        ]),
        list.map(minute_opts, fn(n) {
          let selected_attrs = case n == current.minute {
            True -> [a.selected(True)]
            False -> []
          }
          h.option(
            list.flatten([[a.value(int.to_string(n))], selected_attrs]),
            pad2(n),
          )
        }),
      ),
    ])

  let second_section = case config.show_seconds {
    False -> []
    True -> {
      let cur_sec = case current.second {
        None -> 0
        Some(s) -> s
      }
      [
        h.span([a.class("time-picker-sep")], [h.text(":")]),
        h.div([a.class("time-picker-field")], [
          h.label([a.class("time-picker-label")], [h.text("SS")]),
          h.select(
            list.flatten([
              [
                a.class("select time-picker-select"),
                a.attribute("aria-label", "Second"),
                e.on_change(fn(v) {
                  let s = int.parse(v) |> result_unwrap(cur_sec)
                  on_change(TimeValue(..current, second: Some(s)))
                }),
              ],
              disabled_attrs,
            ]),
            list.map(second_opts, fn(n) {
              let selected_attrs = case n == cur_sec {
                True -> [a.selected(True)]
                False -> []
              }
              h.option(
                list.flatten([[a.value(int.to_string(n))], selected_attrs]),
                pad2(n),
              )
            }),
          ),
        ]),
      ]
    }
  }

  h.div([a.class(root_class)], [hour_select, colon1, minute_select, ..second_section])
}

// --- Convenience shortcuts ---

pub fn time_picker_simple(
  value: Option(TimeValue),
  on_change: fn(TimeValue) -> msg,
) -> Element(msg) {
  new() |> view(value, on_change)
}

fn pad2(n: Int) -> String {
  let s = int.to_string(n)
  case string.length(s) < 2 {
    True -> "0" <> s
    False -> s
  }
}

fn range(from: Int, to: Int) -> List(Int) {
  case from > to {
    True -> []
    False -> [from, ..range(from + 1, to)]
  }
}

fn result_unwrap(r: Result(a, e), default: a) -> a {
  case r {
    Ok(v) -> v
    Error(_) -> default
  }
}
