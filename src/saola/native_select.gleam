//// Native select widget (styled `<select>` with optgroups) — dual-style
//// `Config` (uniform Saola pattern):
////
//// ```gleam
//// native_select.native_select_simple(opts, model.v, "country", Picked)  // shortcut
//// native_select.new()
//// |> native_select.size(native_select.Small)
//// |> native_select.view(opts, model.v, "country", Picked)
//// ```

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

/// Presentation options for a native select. Public for record-update syntax.
/// The `options`, `value`, `name`, and `on_change` are required data (`view`).
pub type NativeSelectConfig {
  NativeSelectConfig(size: NativeSelectSize, disabled: Bool, class: String)
}

/// Builder entry point. Defaults: Default size, enabled, no extra class.
pub fn new() -> NativeSelectConfig {
  NativeSelectConfig(size: Default, disabled: False, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> NativeSelectConfig {
  new()
}

/// Set the size (Default, Small).
pub fn size(config: NativeSelectConfig, size: NativeSelectSize) -> NativeSelectConfig {
  NativeSelectConfig(..config, size: size)
}

/// Set the disabled state.
pub fn disabled(config: NativeSelectConfig, disabled: Bool) -> NativeSelectConfig {
  NativeSelectConfig(..config, disabled: disabled)
}

/// Append an extra CSS class on the wrapper. Additive only.
pub fn add_class(config: NativeSelectConfig, class: String) -> NativeSelectConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  NativeSelectConfig(..config, class: merged)
}

fn render_option(opt: NativeSelectOption, current_value: String) -> Element(msg) {
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

/// Render the styled native `<select>`. `value` marks the selected option;
/// `name` sets the form name; `on_change` wires the change handler.
pub fn view(
  config: NativeSelectConfig,
  options: List(NativeSelectOption),
  value: String,
  name: String,
  on_change: fn(String) -> msg,
) -> Element(msg) {
  let size_class = case config.size {
    Default -> "native-select"
    Small -> "native-select native-select-sm"
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let disabled_attrs = case config.disabled {
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

// --- Convenience shortcuts ---

pub fn native_select_simple(
  options: List(NativeSelectOption),
  value: String,
  name: String,
  on_change: fn(String) -> msg,
) -> Element(msg) {
  new() |> view(options, value, name, on_change)
}
