//// Collapsible widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// collapsible.collapsible_simple(model.open, "Details", body, Toggled)   // shortcut
//// collapsible.new()
//// |> collapsible.disabled(False)
//// |> collapsible.view(model.open, trigger, body, Toggled)
//// ```

import gleam/list
import gleam/result
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import typeid

/// Presentation options for a collapsible. Public for record-update syntax.
/// The `open`/`trigger`/`content`/`on_toggle` are required data (`view`).
pub type CollapsibleConfig {
  CollapsibleConfig(disabled: Bool, class: String)
}

/// Builder entry point. Defaults: enabled, no extra class.
pub fn new() -> CollapsibleConfig {
  CollapsibleConfig(disabled: False, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> CollapsibleConfig {
  new()
}

/// Set the disabled state (the trigger becomes non-interactive).
pub fn disabled(config: CollapsibleConfig, disabled: Bool) -> CollapsibleConfig {
  CollapsibleConfig(..config, disabled: disabled)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: CollapsibleConfig, class: String) -> CollapsibleConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  CollapsibleConfig(..config, class: merged)
}

/// Render the collapsible. `open` is consumer-owned; `on_toggle` fires on the
/// trigger click.
pub fn view(
  config: CollapsibleConfig,
  open: Bool,
  trigger: Element(msg),
  content: Element(msg),
  on_toggle: fn() -> msg,
) -> Element(msg) {
  let id =
    typeid.new(prefix: "col")
    |> result.map(typeid.to_string)
    |> result.unwrap("collapsible-panel")
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  h.div(list.flatten([[a.class("collapsible")], extra_class_attrs]), [
    h.button(
      list.flatten([
        [
          a.type_("button"),
          a.class("collapsible-trigger"),
          a.attribute("aria-expanded", case open {
            True -> "true"
            False -> "false"
          }),
          a.attribute("aria-controls", id),
        ],
        disabled_attrs,
        [e.on_click(on_toggle())],
      ]),
      [trigger],
    ),
    h.div(
      [
        a.class("collapsible-content"),
        a.id(id),
        a.attribute("aria-hidden", case open {
          True -> "false"
          False -> "true"
        }),
      ],
      [content],
    ),
  ])
}

// --- Convenience shortcuts ---

pub fn collapsible_simple(
  open: Bool,
  trigger_label: String,
  content: Element(msg),
  on_toggle: fn() -> msg,
) -> Element(msg) {
  new() |> view(open, h.text(trigger_label), content, on_toggle)
}
