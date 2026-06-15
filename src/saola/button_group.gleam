//// Button group widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// button_group.button_group_simple([btn_a, btn_b])                  // shortcut
//// button_group.new()
//// |> button_group.orientation(button_group.Vertical)
//// |> button_group.view([btn_a, btn_b])
//// ```

import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type ButtonGroupOrientation {
  Horizontal
  Vertical
}

/// Presentation options for a button group. Public for record-update syntax.
/// The `children` are the required data, passed to `view`.
pub type ButtonGroupConfig {
  ButtonGroupConfig(orientation: ButtonGroupOrientation, class: String)
}

/// Builder entry point. Defaults: Horizontal, no extra class.
pub fn new() -> ButtonGroupConfig {
  ButtonGroupConfig(orientation: Horizontal, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> ButtonGroupConfig {
  new()
}

/// Set the orientation (Horizontal — default, Vertical).
pub fn orientation(
  config: ButtonGroupConfig,
  orientation: ButtonGroupOrientation,
) -> ButtonGroupConfig {
  ButtonGroupConfig(..config, orientation: orientation)
}

/// Append an extra CSS class. Additive only.
pub fn add_class(config: ButtonGroupConfig, class: String) -> ButtonGroupConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ButtonGroupConfig(..config, class: merged)
}

/// Render the group wrapping the given child elements.
pub fn view(config: ButtonGroupConfig, children: List(Element(msg))) -> Element(msg) {
  let orientation_class = case config.orientation {
    Horizontal -> "button-group"
    Vertical -> "button-group button-group-vertical"
  }
  let full_class = case config.class {
    "" -> orientation_class
    c -> orientation_class <> " " <> c
  }
  h.div([a.role("group"), a.class(full_class)], children)
}

// --- Convenience shortcuts ---

pub fn button_group_simple(children: List(Element(msg))) -> Element(msg) {
  new() |> view(children)
}
