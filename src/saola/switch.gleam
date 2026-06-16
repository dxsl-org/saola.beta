//// Switch (toggle) widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// switch.switch_simple("Notifications", model.on, Toggled)              // shortcut
//// switch.new()
//// |> switch.name("notify")
//// |> switch.view("Notifications", switch.SyncChecked(model.on), Toggled)
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

pub type SwitchStatus {
  /// Seeds the checked state once. Use with the `formal` library.
  InitChecked(Bool)
  /// Kept in sync with the app model. Use for controlled inputs.
  SyncChecked(Bool)
}

/// Presentation options for a switch. Public for record-update syntax. The
/// `label`, `status`, and `on_change` handler are the required data (`view`).
pub type SwitchConfig {
  SwitchConfig(id: String, name: String, disabled: Bool, class: String)
}

/// Builder entry point. Defaults: auto id, no name, enabled, no extra class.
pub fn new() -> SwitchConfig {
  SwitchConfig(id: "", name: "", disabled: False, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SwitchConfig {
  new()
}

/// Set the `id` attribute (auto-generated when empty).
pub fn id(config: SwitchConfig, id: String) -> SwitchConfig {
  SwitchConfig(..config, id: id)
}

/// Set the `name` attribute.
pub fn name(config: SwitchConfig, name: String) -> SwitchConfig {
  SwitchConfig(..config, name: name)
}

/// Set the disabled state.
pub fn disabled(config: SwitchConfig, disabled: Bool) -> SwitchConfig {
  SwitchConfig(..config, disabled: disabled)
}

/// Append an extra CSS class on the label. Additive only.
pub fn add_class(config: SwitchConfig, class: String) -> SwitchConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SwitchConfig(..config, class: merged)
}

/// Render the switch. `on_change` receives the new checked Bool.
pub fn view(
  config: SwitchConfig,
  label: String,
  status: SwitchStatus,
  on_change: fn(Bool) -> msg,
) -> Element(msg) {
  let input_id =
    case config.id {
      "" -> typeid.new(prefix: "sw") |> result.map(typeid.to_string)
      v -> Ok(v)
    }
    |> result.unwrap("switch-fallback")
  let label_class = case config.class {
    "" -> class_label
    c -> class_label <> " " <> c
  }
  let name_attrs = case config.name {
    "" -> []
    n -> [a.name(n)]
  }
  let status_attr = case status {
    InitChecked(v) -> a.default_checked(v)
    SyncChecked(v) -> a.checked(v)
  }
  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  h.label([a.class(label_class <> " gap-3 cursor-pointer")], [
    h.input(
      list.flatten([
        [
          a.type_("checkbox"),
          a.role("switch"),
          a.class(class_input),
          a.id(input_id),
        ],
        name_attrs,
        [status_attr],
        disabled_attrs,
        [e.on_check(on_change)],
      ]),
    ),
    h.text(label),
  ])
}

// --- Convenience shortcuts ---

pub fn switch_simple(
  label: String,
  checked: Bool,
  on_change: fn(Bool) -> msg,
) -> Element(msg) {
  new() |> view(label, SyncChecked(checked), on_change)
}
