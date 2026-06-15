//// Separator widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// separator.separator()            // shortcut (horizontal)
//// separator.separator_vertical()   // shortcut (vertical)
//// separator.new() |> separator.orientation(separator.Vertical) |> separator.view()
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type SeparatorOrientation {
  Horizontal
  Vertical
}

/// Presentation options for a separator. Public for record-update syntax.
pub type SeparatorConfig {
  SeparatorConfig(orientation: SeparatorOrientation, class: String)
}

/// Builder entry point. Defaults: horizontal, no extra class.
pub fn new() -> SeparatorConfig {
  SeparatorConfig(orientation: Horizontal, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SeparatorConfig {
  new()
}

/// Set the orientation (Horizontal — default, Vertical).
pub fn orientation(
  config: SeparatorConfig,
  orientation: SeparatorOrientation,
) -> SeparatorConfig {
  SeparatorConfig(..config, orientation: orientation)
}

/// Append an extra CSS class. Additive only.
pub fn add_class(config: SeparatorConfig, class: String) -> SeparatorConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SeparatorConfig(..config, class: merged)
}

/// Render the `<hr>` separator.
pub fn view(config: SeparatorConfig) -> Element(msg) {
  let orientation_attrs = case config.orientation {
    Horizontal -> []
    Vertical -> [a.attribute("aria-orientation", "vertical")]
  }
  let class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.hr(list.flatten([[a.role("separator")], orientation_attrs, class_attrs]))
}

// --- Convenience shortcuts ---

/// A horizontal rule used as a visual divider.
pub fn separator() -> Element(msg) {
  new() |> view()
}

/// A vertical rule. Use inside flex rows.
pub fn separator_vertical() -> Element(msg) {
  new() |> orientation(Vertical) |> view()
}
