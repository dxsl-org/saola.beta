//// Toggle button widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// toggle.toggle_simple(model.bold, "Bold", BoldToggled)              // shortcut
//// toggle.new()
//// |> toggle.variant(toggle.Outline)
//// |> toggle.size(toggle.Large)
//// |> toggle.view(model.bold, "Bold", BoldToggled)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type ToggleVariant {
  Default
  Outline
}

pub type ToggleSize {
  Small
  Medium
  Large
}

/// Presentation options for a toggle. Public for record-update syntax. The
/// `pressed`/`label`/`on_change` are the required data, passed to `view`.
pub type ToggleConfig {
  ToggleConfig(
    variant: ToggleVariant,
    size: ToggleSize,
    disabled: Bool,
    class: String,
  )
}

/// Builder entry point. Defaults: Default, Medium, enabled, no extra class.
pub fn new() -> ToggleConfig {
  ToggleConfig(variant: Default, size: Medium, disabled: False, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> ToggleConfig {
  new()
}

/// Set the variant (Default, Outline).
pub fn variant(config: ToggleConfig, variant: ToggleVariant) -> ToggleConfig {
  ToggleConfig(..config, variant: variant)
}

/// Set the size (Small, Medium — default, Large).
pub fn size(config: ToggleConfig, size: ToggleSize) -> ToggleConfig {
  ToggleConfig(..config, size: size)
}

/// Set the disabled state.
pub fn disabled(config: ToggleConfig, disabled: Bool) -> ToggleConfig {
  ToggleConfig(..config, disabled: disabled)
}

/// Append an extra CSS class. Additive only.
pub fn add_class(config: ToggleConfig, class: String) -> ToggleConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ToggleConfig(..config, class: merged)
}

/// Render the toggle. `pressed` is consumer-owned; `on_change` receives the
/// new pressed Bool.
pub fn view(
  config: ToggleConfig,
  pressed: Bool,
  label: String,
  on_change: fn(Bool) -> msg,
) -> Element(msg) {
  let base_class = case config.variant, config.size {
    Default, Small -> "btn btn-sm btn-ghost"
    Default, Medium -> "btn btn-ghost"
    Default, Large -> "btn btn-lg btn-ghost"
    Outline, Small -> "btn btn-sm btn-outline"
    Outline, Medium -> "btn btn-outline"
    Outline, Large -> "btn btn-lg btn-outline"
  }
  let full_class = case config.class {
    "" -> base_class
    c -> base_class <> " " <> c
  }
  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  h.button(
    list.flatten([
      [
        a.type_("button"),
        a.class(full_class),
        a.attribute("aria-pressed", case pressed {
          True -> "true"
          False -> "false"
        }),
        e.on_click(on_change(!pressed)),
      ],
      disabled_attrs,
    ]),
    [h.text(label)],
  )
}

// --- Convenience shortcuts ---

pub fn toggle_simple(
  pressed: Bool,
  label: String,
  on_change: fn(Bool) -> msg,
) -> Element(msg) {
  new() |> view(pressed, label, on_change)
}
