import gleam/string
import lustre/element
import lustre/element/html as h
import saola/field
import saola/form
import saola/theme

// --- theme ---

pub fn theme_light_has_no_class_test() {
  let html = h.div([theme.theme_attr(theme.Light)], []) |> element.to_string
  assert !string.contains(html, "class=")
}

pub fn theme_dark_has_dark_class_test() {
  let html = h.div([theme.theme_attr(theme.Dark)], []) |> element.to_string
  assert string.contains(html, "class=\"dark\"")
}

pub fn theme_system_has_no_class_test() {
  let html = h.div([theme.theme_attr(theme.System)], []) |> element.to_string
  assert !string.contains(html, "class=\"dark\"")
}

// --- field required ---

pub fn field_required_renders_label_and_asterisk_test() {
  let html =
    field.field(
      field.FieldAttrs(..field.default_attrs, label: "Name", required: True),
      h.input([]),
    )
    |> element.to_string
  assert string.contains(html, "field-required")
  assert string.contains(html, " *")
  assert string.contains(html, "aria-hidden=\"true\"")
}

pub fn field_required_renders_asterisk_test() {
  let html =
    field.field(
      field.FieldAttrs(..field.default_attrs, label: "Name", required: True),
      h.input([]),
    )
    |> element.to_string
  assert string.contains(html, "field-required")
  assert string.contains(html, " *")
}

pub fn field_not_required_omits_aria_required_test() {
  let html =
    field.field(
      field.FieldAttrs(..field.default_attrs, label: "Name", required: False),
      h.input([]),
    )
    |> element.to_string
  assert !string.contains(html, "aria-required")
}

pub fn field_hint_renders_test() {
  let html =
    field.field(
      field.FieldAttrs(
        ..field.default_attrs,
        label: "Email",
        hint: "Enter a valid email address.",
      ),
      h.input([]),
    )
    |> element.to_string
  assert string.contains(html, "field-hint")
  assert string.contains(html, "Enter a valid email address.")
}

pub fn field_hint_empty_omits_test() {
  let html =
    field.field(
      field.FieldAttrs(..field.default_attrs, label: "Email", hint: ""),
      h.input([]),
    )
    |> element.to_string
  assert !string.contains(html, "field-hint")
}

pub fn field_required_and_hint_together_test() {
  let html =
    field.field(
      field.FieldAttrs(
        ..field.default_attrs,
        label: "Phone",
        required: True,
        hint: "Include country code.",
      ),
      h.input([]),
    )
    |> element.to_string
  assert string.contains(html, "field-required")
  assert string.contains(html, "field-hint")
  assert string.contains(html, "Include country code.")
}

// --- form bridge ---

pub fn form_result_ok_clears_error_test() {
  let attrs = field.FieldAttrs(..field.default_attrs, error: "old error")
  let updated = form.field_attrs_from_result(Ok("valid"), attrs)
  assert updated.error == ""
}

pub fn form_result_error_sets_error_test() {
  let updated =
    form.field_attrs_from_result(Error("Required"), field.default_attrs)
  assert updated.error == "Required"
}

pub fn form_result_error_renders_in_html_test() {
  let attrs =
    form.field_attrs_from_result(
      Error("Too short."),
      field.FieldAttrs(..field.default_attrs, label: "Password"),
    )
  let html = field.field(attrs, h.input([])) |> element.to_string
  assert string.contains(html, "Too short.")
  assert string.contains(html, "data-invalid=\"true\"")
}
