//// Spinner widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// spinner.spinner_simple()                              // shortcut (medium)
//// spinner.spinner(spinner.Small, "")                    // shortcut (sized)
//// spinner.new() |> spinner.size(spinner.Large) |> spinner.view()
//// ```

import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type SpinnerSize {
  Small
  Medium
  Large
}

/// Presentation options for a spinner. Public for record-update syntax.
pub type SpinnerConfig {
  SpinnerConfig(size: SpinnerSize, class: String)
}

/// Builder entry point. Defaults: Medium, no extra class.
pub fn new() -> SpinnerConfig {
  SpinnerConfig(size: Medium, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SpinnerConfig {
  new()
}

/// Set the size (Small, Medium — default, Large).
pub fn size(config: SpinnerConfig, size: SpinnerSize) -> SpinnerConfig {
  SpinnerConfig(..config, size: size)
}

/// Append an extra CSS class after the size class. Additive only.
pub fn add_class(config: SpinnerConfig, class: String) -> SpinnerConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SpinnerConfig(..config, class: merged)
}

/// Render the spinner `<span role="status">`.
pub fn view(config: SpinnerConfig) -> Element(msg) {
  let size_class = case config.size {
    Small -> "spinner spinner-sm"
    Medium -> "spinner spinner-md"
    Large -> "spinner spinner-lg"
  }
  let full_class = case config.class {
    "" -> size_class
    c -> size_class <> " " <> c
  }
  h.span(
    [
      a.class(full_class),
      a.role("status"),
      a.attribute("aria-label", "Loading"),
    ],
    [],
  )
}

// --- Convenience shortcuts ---

/// Sized spinner with optional extra class.
pub fn spinner(sz: SpinnerSize, class: String) -> Element(msg) {
  new() |> size(sz) |> add_class(class) |> view()
}

/// Default (medium) spinner.
pub fn spinner_simple() -> Element(msg) {
  new() |> view()
}
