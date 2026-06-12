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

pub type InputExtraAttrs {
  InputExtraAttrs(
    id: String,
    name: String,
    placeholder: String,
    disabled: Bool,
    required: Bool,
    class: String,
  )
}

pub const default_extra_attrs = InputExtraAttrs("", "", "", False, False, "")

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

/// Fully customizable text input.
///
/// Example:
/// ```gleam
/// input(Text, None, on_input: Some(UserTyped), extra_attrs: default_extra_attrs)
/// input(Email, Some(SyncValue(model.email)), on_input: Some(EmailChanged), extra_attrs: default_extra_attrs)
/// ```
pub fn input(
  type_: InputType,
  value: Option(InputValue),
  on_input on_input: Option(fn(String) -> msg),
  extra_attrs extra_attrs: InputExtraAttrs,
) -> Element(msg) {
  let InputExtraAttrs(id:, name:, placeholder:, disabled:, required:, class:) =
    extra_attrs
  let value_attrs = case value {
    None -> []
    Some(InitValue(v)) -> [a.default_value(v)]
    Some(SyncValue(v)) -> [a.value(v)]
  }
  let on_input_attrs = case on_input {
    None -> []
    Some(handler) -> [e.on_input(handler)]
  }
  let id_attrs = case id {
    "" -> []
    v -> [a.id(v)]
  }
  let name_attrs = case name {
    "" -> []
    v -> [a.name(v)]
  }
  let placeholder_attrs = case placeholder {
    "" -> []
    v -> [a.placeholder(v)]
  }
  let disabled_attrs = case disabled {
    False -> []
    True -> [a.disabled(True)]
  }
  let required_attrs = case required {
    False -> []
    True -> [a.required(True)]
  }
  let extra_class_attrs = case class {
    "" -> []
    c -> [a.class(c)]
  }
  h.input(list.flatten([
    [a.type_(type_string(type_)), a.class(class_input)],
    value_attrs,
    on_input_attrs,
    id_attrs,
    name_attrs,
    placeholder_attrs,
    disabled_attrs,
    required_attrs,
    extra_class_attrs,
  ]))
}

pub fn input_text(
  placeholder: String,
  on_input: fn(String) -> msg,
) -> Element(msg) {
  input(
    Text,
    None,
    on_input: Some(on_input),
    extra_attrs: InputExtraAttrs(
      ..default_extra_attrs,
      placeholder: placeholder,
    ),
  )
}

pub fn input_email(
  placeholder: String,
  on_input: fn(String) -> msg,
) -> Element(msg) {
  input(
    Email,
    None,
    on_input: Some(on_input),
    extra_attrs: InputExtraAttrs(
      ..default_extra_attrs,
      placeholder: placeholder,
    ),
  )
}

pub fn input_password(
  placeholder: String,
  on_input: fn(String) -> msg,
) -> Element(msg) {
  input(
    Password,
    None,
    on_input: Some(on_input),
    extra_attrs: InputExtraAttrs(
      ..default_extra_attrs,
      placeholder: placeholder,
    ),
  )
}
