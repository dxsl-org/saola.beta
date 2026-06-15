//// Native select widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// select.select_simple(options, Picked)                              // shortcut
//// select.new()
//// |> select.name("country")
//// |> select.required(True)
//// |> select.view(options, select.SyncValue(model.country), Picked)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub const class_select = "select"

pub type SelectOption {
  SelectOption(value: String, label: String)
  SelectOptionDisabled(value: String, label: String)
}

pub type SelectValue {
  /// Seeds the selected value once. Use with the `formal` library.
  InitValue(String)
  /// Kept in sync with the app model.
  SyncValue(String)
}

/// Presentation options for a select. Public for record-update syntax. The
/// `options`, `value`, and `on_change` handler are the required data (`view`).
pub type SelectConfig {
  SelectConfig(
    id: String,
    name: String,
    disabled: Bool,
    required: Bool,
    aria_invalid: Bool,
    class: String,
  )
}

/// Builder entry point. Defaults: no id/name, enabled, optional, valid, no class.
pub fn new() -> SelectConfig {
  SelectConfig(
    id: "",
    name: "",
    disabled: False,
    required: False,
    aria_invalid: False,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SelectConfig {
  new()
}

/// Set the `id` attribute.
pub fn id(config: SelectConfig, id: String) -> SelectConfig {
  SelectConfig(..config, id: id)
}

/// Set the `name` attribute.
pub fn name(config: SelectConfig, name: String) -> SelectConfig {
  SelectConfig(..config, name: name)
}

/// Set the disabled state.
pub fn disabled(config: SelectConfig, disabled: Bool) -> SelectConfig {
  SelectConfig(..config, disabled: disabled)
}

/// Set the required state.
pub fn required(config: SelectConfig, required: Bool) -> SelectConfig {
  SelectConfig(..config, required: required)
}

/// Set `aria-invalid="true"` for validation styling.
pub fn aria_invalid(config: SelectConfig, aria_invalid: Bool) -> SelectConfig {
  SelectConfig(..config, aria_invalid: aria_invalid)
}

/// Append an extra CSS class after the base `select` class. Additive only.
pub fn add_class(config: SelectConfig, class: String) -> SelectConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SelectConfig(..config, class: merged)
}

fn render_option(opt: SelectOption) -> Element(msg) {
  case opt {
    SelectOption(value:, label:) -> h.option([a.value(value)], label)
    SelectOptionDisabled(value:, label:) ->
      h.option([a.value(value), a.disabled(True)], label)
  }
}

/// Render the `<select>`. `value` binds via the `SelectValue` ADT; `on_change`
/// wires the change handler.
pub fn view(
  config: SelectConfig,
  options: List(SelectOption),
  value: SelectValue,
  on_change: fn(String) -> msg,
) -> Element(msg) {
  let id_attrs = case config.id {
    "" -> []
    v -> [a.id(v)]
  }
  let name_attrs = case config.name {
    "" -> []
    n -> [a.name(n)]
  }
  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  let required_attrs = case config.required {
    True -> [a.required(True)]
    False -> []
  }
  let aria_invalid_attrs = case config.aria_invalid {
    True -> [a.attribute("aria-invalid", "true")]
    False -> []
  }
  let class_str = case config.class {
    "" -> class_select
    c -> class_select <> " " <> c
  }
  h.select(
    list.flatten([
      [a.class(class_str)],
      id_attrs,
      name_attrs,
      [
        case value {
          InitValue(v) -> a.default_value(v)
          SyncValue(v) -> a.value(v)
        },
      ],
      disabled_attrs,
      required_attrs,
      aria_invalid_attrs,
      [e.on_input(on_change)],
    ]),
    list.map(options, render_option),
  )
}

// --- Convenience shortcuts ---

pub fn select_simple(
  options: List(SelectOption),
  on_change: fn(String) -> msg,
) -> Element(msg) {
  new() |> view(options, InitValue(""), on_change)
}
