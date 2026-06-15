//// Toggle group widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// toggle_group.toggle_group_simple(items, model.sel, SelChanged)     // shortcut (single-select)
//// toggle_group.new()
//// |> toggle_group.group_type(toggle_group.MultiSelect)
//// |> toggle_group.view(items, model.sel, SelChanged)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type ToggleGroupItem {
  ToggleGroupItem(value: String, label: String)
  ToggleGroupItemDisabled(value: String, label: String)
}

pub type ToggleGroupType {
  SingleSelect
  MultiSelect
}

/// Presentation options for a toggle group. Public for record-update syntax.
/// The `items`/`selected`/`on_change` are the required data (`view`).
pub type ToggleGroupConfig {
  ToggleGroupConfig(group_type: ToggleGroupType, class: String)
}

/// Builder entry point. Defaults: SingleSelect, no extra class.
pub fn new() -> ToggleGroupConfig {
  ToggleGroupConfig(group_type: SingleSelect, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> ToggleGroupConfig {
  new()
}

/// Set the selection mode (SingleSelect — default, MultiSelect).
pub fn group_type(
  config: ToggleGroupConfig,
  group_type: ToggleGroupType,
) -> ToggleGroupConfig {
  ToggleGroupConfig(..config, group_type: group_type)
}

/// Append an extra CSS class. Additive only.
pub fn add_class(config: ToggleGroupConfig, class: String) -> ToggleGroupConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ToggleGroupConfig(..config, class: merged)
}

/// Render the toggle group. `selected` is consumer-owned; `on_change` receives
/// the new selection list (computed per the group's select mode).
pub fn view(
  config: ToggleGroupConfig,
  items: List(ToggleGroupItem),
  selected: List(String),
  on_change: fn(List(String)) -> msg,
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(
    list.flatten([
      [a.class("button-group")],
      extra_class_attrs,
      [a.role("group")],
    ]),
    list.map(items, fn(item) {
      let #(value, label, is_disabled) = case item {
        ToggleGroupItem(v, l) -> #(v, l, False)
        ToggleGroupItemDisabled(v, l) -> #(v, l, True)
      }
      let is_pressed = list.contains(selected, value)
      let new_selected = case config.group_type, is_pressed {
        SingleSelect, True -> []
        SingleSelect, False -> [value]
        MultiSelect, True -> list.filter(selected, fn(s) { s != value })
        MultiSelect, False -> list.append(selected, [value])
      }
      let disabled_attrs = case is_disabled {
        True -> [a.disabled(True)]
        False -> []
      }
      h.button(
        list.flatten([
          [
            a.type_("button"),
            a.class("btn btn-ghost"),
            a.attribute("aria-pressed", case is_pressed {
              True -> "true"
              False -> "false"
            }),
            a.attribute("data-value", value),
          ],
          disabled_attrs,
          [e.on_click(on_change(new_selected))],
        ]),
        [h.text(label)],
      )
    }),
  )
}

// --- Convenience shortcuts ---

pub fn toggle_group_simple(
  items: List(ToggleGroupItem),
  selected: List(String),
  on_change: fn(List(String)) -> msg,
) -> Element(msg) {
  new() |> view(items, selected, on_change)
}
