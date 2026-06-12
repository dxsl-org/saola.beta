import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type NativeSelectOption {
  NativeSelectOption(value: String, label: String)
  NativeSelectOptGroup(label: String, options: List(NativeSelectOption))
}

pub type NativeSelectSize {
  Default
  Small
}

pub type NativeSelectAttrs {
  NativeSelectAttrs(size: NativeSelectSize, disabled: Bool, class: String)
}

pub const default_attrs = NativeSelectAttrs(
  size: Default,
  disabled: False,
  class: "",
)

fn render_option(
  opt: NativeSelectOption,
  current_value: String,
) -> Element(msg) {
  case opt {
    NativeSelectOption(value, label) ->
      h.option([a.value(value), a.selected(value == current_value)], label)
    NativeSelectOptGroup(group_label, options) ->
      h.optgroup(
        [a.attribute("label", group_label)],
        list.map(options, fn(o) { render_option(o, current_value) }),
      )
  }
}

pub fn native_select(
  options: List(NativeSelectOption),
  value: String,
  name: String,
  on_change: fn(String) -> msg,
  attrs: NativeSelectAttrs,
) -> Element(msg) {
  let size_class = case attrs.size {
    Default -> "native-select"
    Small -> "native-select native-select-sm"
  }
  let extra_class_attrs = case attrs.class {
    "" -> []
    c -> [a.class(c)]
  }
  let disabled_attrs = case attrs.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  h.div(
    list.flatten([[a.class("native-select-wrapper")], extra_class_attrs]),
    [
      h.select(
        list.flatten([
          [a.class(size_class), a.name(name)],
          disabled_attrs,
          [e.on_input(on_change)],
        ]),
        list.map(options, fn(o) { render_option(o, value) }),
      ),
      h.span(
        [a.class("native-select-icon"), a.attribute("aria-hidden", "true")],
        [h.text("▾")],
      ),
    ],
  )
}

pub fn native_select_simple(
  options: List(NativeSelectOption),
  value: String,
  name: String,
  on_change: fn(String) -> msg,
) -> Element(msg) {
  native_select(options, value, name, on_change, default_attrs)
}
