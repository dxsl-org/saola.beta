//// Form field wrapper — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// field.field_simple("Email", the_input)                            // shortcut
//// field.new()
//// |> field.label("Email")
//// |> field.description("We won't spam.")
//// |> field.required(True)
//// |> field.view(the_input)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub const class_field = "field"

/// Label/input layout: stacked (`Vertical`) or side-by-side (`Horizontal`).
pub type FieldOrientation {
  Vertical
  Horizontal
}

/// Presentation options for a field. Public for record-update syntax. The
/// wrapped `input` element is the required data, passed to `view`.
///
/// `field_id` wires accessibility: set it to the same `id` you put on the
/// input. The `<label>` then targets the input via `for`, and the hint/error
/// get ids `<field_id>-hint` / `<field_id>-error` so the consumer can point
/// the input's `aria-describedby` at them. Left empty, none of these are
/// emitted (the widget cannot inject attributes into the pre-built input).
pub type FieldConfig {
  FieldConfig(
    label: String,
    description: String,
    error: String,
    orientation: FieldOrientation,
    required: Bool,
    hint: String,
    field_id: String,
  )
}

/// Builder entry point. Defaults: no label/description/error/hint/id,
/// Vertical, not required.
pub fn new() -> FieldConfig {
  FieldConfig(
    label: "",
    description: "",
    error: "",
    orientation: Vertical,
    required: False,
    hint: "",
    field_id: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> FieldConfig {
  new()
}

/// Set the field label (omitted when empty).
pub fn label(config: FieldConfig, label: String) -> FieldConfig {
  FieldConfig(..config, label: label)
}

/// Set the helper description (below the input).
pub fn description(config: FieldConfig, description: String) -> FieldConfig {
  FieldConfig(..config, description: description)
}

/// Set the error message (presence marks the field invalid).
pub fn error(config: FieldConfig, error: String) -> FieldConfig {
  FieldConfig(..config, error: error)
}

/// Set the orientation (Vertical — default, Horizontal).
pub fn orientation(config: FieldConfig, orientation: FieldOrientation) -> FieldConfig {
  FieldConfig(..config, orientation: orientation)
}

/// Mark the field required (renders a `*` indicator).
pub fn required(config: FieldConfig, required: Bool) -> FieldConfig {
  FieldConfig(..config, required: required)
}

/// Set the hint text (between input and description).
pub fn hint(config: FieldConfig, hint: String) -> FieldConfig {
  FieldConfig(..config, hint: hint)
}

/// Set the field's accessible id — must match the `id` on the wrapped input.
/// Enables `<label for>` and `<field_id>-hint`/`<field_id>-error` description
/// ids (see `FieldConfig` docs).
pub fn field_id(config: FieldConfig, field_id: String) -> FieldConfig {
  FieldConfig(..config, field_id: field_id)
}

/// Render the field wrapping the given `input` element.
pub fn view(config: FieldConfig, input: Element(msg)) -> Element(msg) {
  let is_invalid = config.error != ""
  let invalid_attrs = case is_invalid {
    True -> [a.attribute("data-invalid", "true")]
    False -> []
  }
  let orientation_attrs = case config.orientation {
    Vertical -> []
    Horizontal -> [a.attribute("data-orientation", "horizontal")]
  }
  let label_for_attrs = case config.field_id {
    "" -> []
    id -> [a.for(id)]
  }
  let hint_id_attrs = case config.field_id {
    "" -> []
    id -> [a.id(id <> "-hint")]
  }
  let error_id_attrs = case config.field_id {
    "" -> []
    id -> [a.id(id <> "-error")]
  }
  h.div(
    list.flatten([[a.class(class_field)], invalid_attrs, orientation_attrs]),
    [
      case config.label {
        "" -> element.none()
        l ->
          h.label(list.flatten([[a.class("label")], label_for_attrs]), [
            h.text(l),
            case config.required {
              True ->
                h.span(
                  [a.class("field-required"), a.attribute("aria-hidden", "true")],
                  [h.text(" *")],
                )
              False -> element.none()
            },
          ])
      },
      input,
      case config.hint {
        "" -> element.none()
        h_ ->
          h.p(list.flatten([[a.class("field-hint")], hint_id_attrs]), [
            h.text(h_),
          ])
      },
      case config.description {
        "" -> element.none()
        d -> h.p([a.class("text-muted-foreground text-sm")], [h.text(d)])
      },
      case config.error {
        "" -> element.none()
        err ->
          h.p(list.flatten([[a.role("alert")], error_id_attrs]), [h.text(err)])
      },
    ],
  )
}

// --- Convenience shortcuts ---

/// A labelled field wrapping `input`, using all other defaults.
pub fn field_simple(label: String, input: Element(msg)) -> Element(msg) {
  FieldConfig(..new(), label: label) |> view(input)
}
