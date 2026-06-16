//// Progress bar widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// progress.progress_simple(65)                       // shortcut (0–100)
//// progress.new()
//// |> progress.max(5)
//// |> progress.variant(progress.Success)
//// |> progress.label("Step 3 of 5")
//// |> progress.view(3)
//// ```

import gleam/int
import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type ProgressVariant {
  Default
  Success
  Destructive
}

/// Presentation options for a progress bar. Public for record-update syntax.
/// The current `value` is the required data, passed to `view`.
pub type ProgressConfig {
  ProgressConfig(
    min: Int,
    max: Int,
    variant: ProgressVariant,
    label: String,
    class: String,
  )
}

/// Builder entry point. Defaults: 0–100 range, Default variant, no label/class.
pub fn new() -> ProgressConfig {
  ProgressConfig(min: 0, max: 100, variant: Default, label: "", class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> ProgressConfig {
  new()
}

/// Set the minimum value (default 0).
pub fn min(config: ProgressConfig, min: Int) -> ProgressConfig {
  ProgressConfig(..config, min: min)
}

/// Set the maximum value (default 100).
pub fn max(config: ProgressConfig, max: Int) -> ProgressConfig {
  ProgressConfig(..config, max: max)
}

/// Set the variant (Default, Success, Destructive).
pub fn variant(
  config: ProgressConfig,
  variant: ProgressVariant,
) -> ProgressConfig {
  ProgressConfig(..config, variant: variant)
}

/// Set the accessible label.
pub fn label(config: ProgressConfig, label: String) -> ProgressConfig {
  ProgressConfig(..config, label: label)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: ProgressConfig, class: String) -> ProgressConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ProgressConfig(..config, class: merged)
}

fn fill_pct(value: Int, min: Int, max: Int) -> String {
  let range = max - min
  let pct = case range {
    0 -> 0
    r -> { value - min } * 100 / r
  }
  int.clamp(pct, min: 0, max: 100) |> int.to_string
}

/// Render the progress bar with the given current `value` (within min..max).
/// The fill width is set via inline `width`.
pub fn view(config: ProgressConfig, value: Int) -> Element(msg) {
  let pct = fill_pct(value, config.min, config.max)
  let bar_class = case config.variant {
    Default -> "progress-bar"
    Success -> "progress-bar progress-bar-success"
    Destructive -> "progress-bar progress-bar-destructive"
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let label_attrs = case config.label {
    "" -> []
    l -> [a.aria_label(l)]
  }
  h.div(
    list.flatten([
      [a.class("progress")],
      extra_class_attrs,
      [
        a.role("progressbar"),
        a.attribute("aria-valuemin", int.to_string(config.min)),
        a.attribute("aria-valuemax", int.to_string(config.max)),
        a.attribute("aria-valuenow", int.to_string(value)),
        a.attribute("aria-live", "polite"),
      ],
      label_attrs,
    ]),
    [h.div([a.class(bar_class), a.style("width", pct <> "%")], [])],
  )
}

// --- Convenience shortcuts ---

/// Simple progress bar, 0–100 range.
pub fn progress_simple(value: Int) -> Element(msg) {
  new() |> view(value)
}
