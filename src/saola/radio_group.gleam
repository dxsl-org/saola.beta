//// Radio group widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// radio_group.radio_group_simple(                                    // shortcut
////   options: opts, value: model.theme, name: "theme", on_change: ThemeChanged,
//// )
//// radio_group.new()
//// |> radio_group.name("theme")
//// |> radio_group.orientation(radio_group.Horizontal)
//// |> radio_group.view(opts, model.theme, ThemeChanged)
//// ```

import gleam/list
import gleam/result
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import typeid

pub const class_input = "input"

pub const class_label = "label"

pub type RadioOption {
  RadioOption(value: String, label: String)
  RadioOptionDisabled(value: String, label: String)
}

pub type RadioGroupOrientation {
  Horizontal
  Vertical
}

/// Presentation options for a radio group. Public for record-update syntax.
/// The `options`, selected `value`, and `on_change` handler are required (`view`).
pub type RadioGroupConfig {
  RadioGroupConfig(
    name: String,
    orientation: RadioGroupOrientation,
    disabled: Bool,
    required: Bool,
    class: String,
  )
}

/// Builder entry point. Defaults: no name, Vertical, enabled, optional, no class.
pub fn new() -> RadioGroupConfig {
  RadioGroupConfig(
    name: "",
    orientation: Vertical,
    disabled: False,
    required: False,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> RadioGroupConfig {
  new()
}

/// Set the shared `name` attribute for the group's inputs.
pub fn name(config: RadioGroupConfig, name: String) -> RadioGroupConfig {
  RadioGroupConfig(..config, name: name)
}

/// Set the orientation (Vertical — default, Horizontal).
pub fn orientation(
  config: RadioGroupConfig,
  orientation: RadioGroupOrientation,
) -> RadioGroupConfig {
  RadioGroupConfig(..config, orientation: orientation)
}

/// Set the disabled state (applies to all options).
pub fn disabled(config: RadioGroupConfig, disabled: Bool) -> RadioGroupConfig {
  RadioGroupConfig(..config, disabled: disabled)
}

/// Set the required state.
pub fn required(config: RadioGroupConfig, required: Bool) -> RadioGroupConfig {
  RadioGroupConfig(..config, required: required)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: RadioGroupConfig, class: String) -> RadioGroupConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  RadioGroupConfig(..config, class: merged)
}

fn render_option(
  opt: RadioOption,
  selected_value: String,
  config: RadioGroupConfig,
  on_change: fn(String) -> msg,
  group_id: String,
) -> Element(msg) {
  let #(value, label, is_disabled) = case opt {
    RadioOption(v, l) -> #(v, l, False)
    RadioOptionDisabled(v, l) -> #(v, l, True)
  }
  let input_id = group_id <> "-" <> value
  let name_attrs = case config.name {
    "" -> []
    n -> [a.name(n)]
  }
  let checked_attrs = case selected_value == value {
    True -> [a.checked(True)]
    False -> []
  }
  let disabled_attrs = case is_disabled || config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  let required_attrs = case config.required {
    True -> [a.required(True)]
    False -> []
  }
  h.label([a.class(class_label <> " gap-2 cursor-pointer")], [
    h.input(
      list.flatten([
        [a.type_("radio"), a.class(class_input), a.id(input_id)],
        name_attrs,
        [a.value(value)],
        checked_attrs,
        disabled_attrs,
        required_attrs,
        [e.on_check(fn(_) { on_change(value) })],
      ]),
    ),
    h.text(label),
  ])
}

/// Render the radio group. `value` is the selected option's value;
/// `on_change` receives the newly-selected value.
pub fn view(
  config: RadioGroupConfig,
  options: List(RadioOption),
  value: String,
  on_change: fn(String) -> msg,
) -> Element(msg) {
  let group_id =
    typeid.new(prefix: "rg")
    |> result.map(typeid.to_string)
    |> result.unwrap("radio-group")
  let orientation_attrs = case config.orientation {
    Horizontal -> [a.attribute("data-orientation", "horizontal")]
    Vertical -> []
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(
    list.flatten([
      [a.class("radio-group")],
      extra_class_attrs,
      [a.role("radiogroup")],
      orientation_attrs,
    ]),
    list.map(options, fn(opt) {
      render_option(opt, value, config, on_change, group_id)
    }),
  )
}

// --- Convenience shortcuts ---

pub fn radio_group_simple(
  options options: List(RadioOption),
  value value: String,
  name name: String,
  on_change on_change: fn(String) -> msg,
) -> Element(msg) {
  RadioGroupConfig(..new(), name: name) |> view(options, value, on_change)
}
