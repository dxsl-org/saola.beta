//// Text input widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// input.input_text("Email", EmailChanged)                       // shortcut
//// input.new()
//// |> input.type_(input.Email)
//// |> input.placeholder("you@example.com")
//// |> input.required(True)
//// |> input.view(Some(input.SyncValue(model.email)), Some(EmailChanged))
//// ```
//// Value binding uses the `InputValue` ADT (rule 5): `InitValue` seeds a
//// default once (for `formal`), `SyncValue` is kept in sync with the model.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub const class_input = "input"

pub type InputType {
  Text
  Email
  Password
  Search
  Tel
  Url
  Number
}

pub type InputValue {
  /// One-time initial value — for use with the `formal` library.
  InitValue(String)
  /// Reactive value kept in sync with the app model.
  SyncValue(String)
}

/// Presentation options for an input. Public for record-update syntax. The
/// `value` and `on_input` handler are the required data, passed to `view`.
pub type InputConfig {
  InputConfig(
    type_: InputType,
    id: String,
    name: String,
    placeholder: String,
    disabled: Bool,
    required: Bool,
    aria_describedby: String,
    aria_invalid: Bool,
    class: String,
  )
}

/// Builder entry point. Defaults: Text, no id/name/placeholder, enabled,
/// optional, not described/invalid, no extra class.
pub fn new() -> InputConfig {
  InputConfig(
    type_: Text,
    id: "",
    name: "",
    placeholder: "",
    disabled: False,
    required: False,
    aria_describedby: "",
    aria_invalid: False,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> InputConfig {
  new()
}

/// Set the input type (Text — default, Email, Password, Search, Tel, Url, Number).
pub fn type_(config: InputConfig, type_: InputType) -> InputConfig {
  InputConfig(..config, type_: type_)
}

/// Set the `id` attribute.
pub fn id(config: InputConfig, id: String) -> InputConfig {
  InputConfig(..config, id: id)
}

/// Set the `name` attribute.
pub fn name(config: InputConfig, name: String) -> InputConfig {
  InputConfig(..config, name: name)
}

/// Set the placeholder text.
pub fn placeholder(config: InputConfig, placeholder: String) -> InputConfig {
  InputConfig(..config, placeholder: placeholder)
}

/// Set the disabled state.
pub fn disabled(config: InputConfig, disabled: Bool) -> InputConfig {
  InputConfig(..config, disabled: disabled)
}

/// Set the required state.
pub fn required(config: InputConfig, required: Bool) -> InputConfig {
  InputConfig(..config, required: required)
}

/// Set `aria-describedby` — the space-separated id(s) of the element(s) that
/// describe this input (e.g. a `field`'s `<id>-hint`/`<id>-error`).
pub fn aria_describedby(config: InputConfig, ids: String) -> InputConfig {
  InputConfig(..config, aria_describedby: ids)
}

/// Set `aria-invalid="true"` to mark the value as failing validation.
pub fn aria_invalid(config: InputConfig, invalid: Bool) -> InputConfig {
  InputConfig(..config, aria_invalid: invalid)
}

/// Append an extra CSS class after the base `input` class. Additive only.
pub fn add_class(config: InputConfig, class: String) -> InputConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  InputConfig(..config, class: merged)
}

fn type_string(t: InputType) -> String {
  case t {
    Text -> "text"
    Email -> "email"
    Password -> "password"
    Search -> "search"
    Tel -> "tel"
    Url -> "url"
    Number -> "number"
  }
}

/// Render the `<input>`. `value` binds via the `InputValue` ADT; `on_input`
/// wires the change handler.
pub fn view(
  config: InputConfig,
  value: Option(InputValue),
  on_input: Option(fn(String) -> msg),
) -> Element(msg) {
  let value_attrs = case value {
    None -> []
    Some(InitValue(v)) -> [a.default_value(v)]
    Some(SyncValue(v)) -> [a.value(v)]
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
  let disabled_attrs = case config.disabled {
    False -> []
    True -> [a.disabled(True)]
  }
  let required_attrs = case config.required {
    False -> []
    True -> [a.required(True)]
  }
  let describedby_attrs = case config.aria_describedby {
    "" -> []
    v -> [a.attribute("aria-describedby", v)]
  }
  let invalid_attrs = case config.aria_invalid {
    False -> []
    True -> [a.attribute("aria-invalid", "true")]
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.input(list.flatten([
    [a.type_(type_string(config.type_)), a.class(class_input)],
    value_attrs,
    on_input_attrs,
    id_attrs,
    name_attrs,
    placeholder_attrs,
    disabled_attrs,
    required_attrs,
    describedby_attrs,
    invalid_attrs,
    extra_class_attrs,
  ]))
}

// --- Convenience shortcuts ---

pub fn input_text(ph: String, on_input: fn(String) -> msg) -> Element(msg) {
  new() |> placeholder(ph) |> view(None, Some(on_input))
}

pub fn input_email(ph: String, on_input: fn(String) -> msg) -> Element(msg) {
  new() |> type_(Email) |> placeholder(ph) |> view(None, Some(on_input))
}

pub fn input_password(ph: String, on_input: fn(String) -> msg) -> Element(msg) {
  new() |> type_(Password) |> placeholder(ph) |> view(None, Some(on_input))
}
