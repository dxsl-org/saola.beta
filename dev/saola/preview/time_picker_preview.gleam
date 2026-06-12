import gleam/int
import gleam/option.{None, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, TimePickerChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/time_picker

pub fn view(model: Model) -> Element(Message) {
  let display_value = case model.time_picker_value {
    None -> "None"
    Some(tv) -> display_time(tv)
  }
  doc_page.doc_page(
    "Time Picker",
    "A time input using native selects for hour, minute, and second.",
    [
      DocSection("24-hour", "24-hour (simple)", [
        h.div([a.class("grid gap-4 mt-4")], [
          time_picker.time_picker_simple(
            model.time_picker_value,
            TimePickerChanged,
          ),
        ]),
      ]),
      DocSection("12-hour", "12-hour format", [
        h.div([a.class("grid gap-4 mt-4")], [
          time_picker.time_picker(
            model.time_picker_value,
            time_picker.TwelveHour,
            TimePickerChanged,
            time_picker.default_attrs,
          ),
        ]),
      ]),
      DocSection("with-seconds", "With seconds", [
        h.div([a.class("grid gap-4 mt-4")], [
          time_picker.time_picker(
            model.time_picker_value,
            time_picker.TwentyFourHour,
            TimePickerChanged,
            time_picker.TimePickerAttrs(
              show_seconds: True,
              disabled: False,
              class: "",
            ),
          ),
        ]),
      ]),
      DocSection("disabled", "Disabled", [
        h.div([a.class("grid gap-4 mt-4")], [
          time_picker.time_picker(
            None,
            time_picker.TwentyFourHour,
            TimePickerChanged,
            time_picker.TimePickerAttrs(
              show_seconds: False,
              disabled: True,
              class: "",
            ),
          ),
          h.div([a.class("mt-4")], [
            h.p([a.class("text-muted-foreground text-sm")], [
              text("Current value: " <> display_value),
            ]),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/time_picker",
          "",
          "// Simple 24-hour",
          "time_picker.time_picker_simple(model.time_picker_value, TimePickerChanged)",
          "",
          "// With seconds",
          "time_picker.time_picker(",
          "  model.time_picker_value, time_picker.TwentyFourHour, TimePickerChanged,",
          "  time_picker.TimePickerAttrs(show_seconds: True, disabled: False, class: \"\"),",
          ")",
        ]),
      ]),
    ],
  )
}

fn display_time(tv: time_picker.TimeValue) -> String {
  let pad = fn(n: Int) -> String {
    let s = int.to_string(n)
    case string.length(s) < 2 {
      True -> "0" <> s
      False -> s
    }
  }
  let base = pad(tv.hour) <> ":" <> pad(tv.minute)
  case tv.second {
    None -> base
    Some(s) -> base <> ":" <> pad(s)
  }
}
