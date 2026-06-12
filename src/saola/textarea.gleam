import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// Reuses the same Basecoat CSS class as `<input>` — both elements share the
/// `.input` design token.
pub const class_input = "input"

/// NOTE: Unlike `<input>` which has `defaultValue`/`value` HTML attributes,
/// `<textarea>` only accepts text content. Both `InitValue` and `SyncValue`
/// set the content string on every render — callers using `formal` for
/// uncontrolled forms should pass `InitValue` as a signal of intent, but
/// Lustre will apply the value on each render regardless of which variant is used.
pub type TextareaValue {
  InitValue(String)
  SyncValue(String)
}

pub type TextareaExtraAttrs {
  TextareaExtraAttrs(
    id: String,
    name: String,
    placeholder: String,
    rows: Option(Int),
    disabled: Bool,
    required: Bool,
    class: String,
  )
}

pub const default_extra_attrs = TextareaExtraAttrs(
  "",
  "",
  "",
  None,
  False,
  False,
  "",
)

/// Fully customizable textarea.
///
/// Example:
/// ```gleam
/// textarea(None, on_input: Some(UserTyped), extra_attrs: default_extra_attrs)
/// ```
pub fn textarea(
  value: Option(TextareaValue),
  on_input on_input: Option(fn(String) -> msg),
  extra_attrs extra_attrs: TextareaExtraAttrs,
) -> Element(msg) {
  let TextareaExtraAttrs(
    id:,
    name:,
    placeholder:,
    rows:,
    disabled:,
    required:,
    class:,
  ) = extra_attrs
  let content = case value {
    None -> ""
    Some(InitValue(v)) -> v
    Some(SyncValue(v)) -> v
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
  let rows_attrs = case rows {
    None -> []
    Some(n) -> [a.rows(n)]
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

pub fn textarea_simple(
  placeholder: String,
  on_input: fn(String) -> msg,
) -> Element(msg) {
  textarea(
    None,
    on_input: Some(on_input),
    extra_attrs: TextareaExtraAttrs("", "", placeholder, None, False, False, ""),
  )
}
