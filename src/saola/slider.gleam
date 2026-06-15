//// Range slider widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// slider.slider_simple(model.volume, VolumeChanged)                  // shortcut
//// slider.new()
//// |> slider.max(10)
//// |> slider.step(2)
//// |> slider.view(slider.SyncValue(model.volume), VolumeChanged)
//// ```

import gleam/int
import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub const class_input = "input"

pub type SliderValue {
  /// Seeds the value once. Use with the `formal` library.
  InitValue(Int)
  /// Kept in sync with the app model.
  SyncValue(Int)
}

/// Presentation options for a slider. Public for record-update syntax. The
/// `value` and `on_input` handler are the required data, passed to `view`.
pub type SliderConfig {
  SliderConfig(
    min: Int,
    max: Int,
    step: Int,
    disabled: Bool,
    name: String,
    class: String,
    aria_label: String,
  )
}

/// Builder entry point. Defaults: 0–100, step 1, enabled, no name/class/label.
pub fn new() -> SliderConfig {
  SliderConfig(
    min: 0,
    max: 100,
    step: 1,
    disabled: False,
    name: "",
    class: "",
    aria_label: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SliderConfig {
  new()
}

/// Set the minimum value (default 0).
pub fn min(config: SliderConfig, min: Int) -> SliderConfig {
  SliderConfig(..config, min: min)
}

/// Set the maximum value (default 100).
pub fn max(config: SliderConfig, max: Int) -> SliderConfig {
  SliderConfig(..config, max: max)
}

/// Set the step increment (default 1).
pub fn step(config: SliderConfig, step: Int) -> SliderConfig {
  SliderConfig(..config, step: step)
}

/// Set the disabled state.
pub fn disabled(config: SliderConfig, disabled: Bool) -> SliderConfig {
  SliderConfig(..config, disabled: disabled)
}

/// Set the `name` attribute.
pub fn name(config: SliderConfig, name: String) -> SliderConfig {
  SliderConfig(..config, name: name)
}

/// Set the accessible label.
pub fn aria_label(config: SliderConfig, aria_label: String) -> SliderConfig {
  SliderConfig(..config, aria_label: aria_label)
}

/// Append an extra CSS class after the base `input` class. Additive only.
pub fn add_class(config: SliderConfig, class: String) -> SliderConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SliderConfig(..config, class: merged)
}

fn fill_pct(value: Int, min: Int, max: Int) -> String {
  let range = max - min
  let pct = case range {
    0 -> 0
    r -> { value - min } * 100 / r
  }
  int.clamp(pct, min: 0, max: 100) |> int.to_string
}

/// Render the `<input type=range>`. `value` binds via the `SliderValue` ADT.
pub fn view(
  config: SliderConfig,
  value: SliderValue,
  on_input: fn(String) -> msg,
) -> Element(msg) {
  let raw_value = case value {
    InitValue(v) -> v
    SyncValue(v) -> v
  }
  let pct = fill_pct(raw_value, config.min, config.max)
  let value_attr = case value {
    InitValue(v) -> a.default_value(int.to_string(v))
    SyncValue(v) -> a.value(int.to_string(v))
  }
  let name_attrs = case config.name {
    "" -> []
    n -> [a.name(n)]
  }
  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  let aria_label_attrs = case config.aria_label {
    "" -> []
    l -> [a.aria_label(l)]
  }
  let class_str = case config.class {
    "" -> class_input
    c -> class_input <> " " <> c
  }
  h.input(list.flatten([
    [
      a.type_("range"),
      a.class(class_str),
      a.min(int.to_string(config.min)),
      a.max(int.to_string(config.max)),
      a.step(int.to_string(config.step)),
      value_attr,
      a.style("--slider-value", pct <> "%"),
    ],
    name_attrs,
    disabled_attrs,
    aria_label_attrs,
    [e.on_input(on_input)],
  ]))
}

// --- Convenience shortcuts ---

pub fn slider_simple(value: Int, on_input: fn(String) -> msg) -> Element(msg) {
  new() |> view(SyncValue(value), on_input)
}
