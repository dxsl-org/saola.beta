//// Textarea widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// textarea.textarea_simple("Your message", MessageChanged)      // shortcut
//// textarea.new()
//// |> textarea.rows(6)
//// |> textarea.view(Some(textarea.SyncValue(model.body)), Some(BodyChanged))
//// ```
//// Reuses the `.input` Basecoat class. Both `InitValue`/`SyncValue` set the
//// content string on every render (a `<textarea>` has no defaultValue attr).

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub const class_input = "input"

pub type TextareaValue {
  InitValue(String)
  SyncValue(String)
}

/// Presentation options for a textarea. Public for record-update syntax. The
/// `value` and `on_input` handler are the required data, passed to `view`.
pub type TextareaConfig {
  TextareaConfig(
    id: String,
    name: String,
    placeholder: String,
    rows: Option(Int),
    disabled: Bool,
    required: Bool,
    class: String,
  )
}

/// Builder entry point. Defaults: no id/name/placeholder/rows, enabled,
/// optional, no extra class.
pub fn new() -> TextareaConfig {
  TextareaConfig(
    id: "",
    name: "",
    placeholder: "",
    rows: None,
    disabled: False,
    required: False,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> TextareaConfig {
  new()
}

/// Set the `id` attribute.
pub fn id(config: TextareaConfig, id: String) -> TextareaConfig {
  TextareaConfig(..config, id: id)
}

/// Set the `name` attribute.
pub fn name(config: TextareaConfig, name: String) -> TextareaConfig {
  TextareaConfig(..config, name: name)
}

/// Set the placeholder text.
pub fn placeholder(
  config: TextareaConfig,
  placeholder: String,
) -> TextareaConfig {
  TextareaConfig(..config, placeholder: placeholder)
}

/// Set the number of visible rows.
pub fn rows(config: TextareaConfig, rows: Int) -> TextareaConfig {
  TextareaConfig(..config, rows: Some(rows))
}

/// Set the disabled state.
pub fn disabled(config: TextareaConfig, disabled: Bool) -> TextareaConfig {
  TextareaConfig(..config, disabled: disabled)
}

/// Set the required state.
pub fn required(config: TextareaConfig, required: Bool) -> TextareaConfig {
  TextareaConfig(..config, required: required)
}

/// Append an extra CSS class after the base `input` class. Additive only.
pub fn add_class(config: TextareaConfig, class: String) -> TextareaConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  TextareaConfig(..config, class: merged)
}

/// Render the `<textarea>`. `value` sets the content; `on_input` wires the
/// change handler.
pub fn view(
  config: TextareaConfig,
  value: Option(TextareaValue),
  on_input: Option(fn(String) -> msg),
) -> Element(msg) {
  let content = case value {
    None -> ""
    Some(InitValue(v)) -> v
    Some(SyncValue(v)) -> v
  }
  let on_input_attrs = case on_input {
    None -> []
    Some(handler) -> [e.on_input(handler)]
  }
  let id_attrs = case config.id {
    "" -> []
    v -> [a.id(v)]
  }
  let name_attrs = case config.name {
    "" -> []
    v -> [a.name(v)]
  }
  let placeholder_attrs = case config.placeholder {
    "" -> []
    v -> [a.placeholder(v)]
  }
  let rows_attrs = case config.rows {
    None -> []
    Some(n) -> [a.rows(n)]
  }
  let disabled_attrs = case config.disabled {
    False -> []
    True -> [a.disabled(True)]
  }
  let required_attrs = case config.required {
    False -> []
    True -> [a.required(True)]
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.textarea(
    list.flatten([
      [a.class(class_input)],
      on_input_attrs,
      id_attrs,
      name_attrs,
      placeholder_attrs,
      rows_attrs,
      disabled_attrs,
      required_attrs,
      extra_class_attrs,
    ]),
    content,
  )
}

// --- Convenience shortcuts ---

pub fn textarea_simple(
  ph: String,
  on_input: fn(String) -> msg,
) -> Element(msg) {
  new() |> placeholder(ph) |> view(None, Some(on_input))
}
