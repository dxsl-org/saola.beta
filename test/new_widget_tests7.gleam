import gleam/string
import lustre/element
import lustre/element/html as h
import saola/field
import saola/theme

// --- field required ---

pub fn field_required_renders_label_and_asterisk_test() {
  let html =
    field.new()
    |> field.label("Name")
    |> field.required(True)
    |> field.view(h.input([]))
    |> element.to_string
  assert string.contains(html, "field-required")
  assert string.contains(html, " *")
  assert string.contains(html, "aria-hidden=\"true\"")
}

pub fn field_required_renders_asterisk_test() {
  let html =
    field.new()
    |> field.label("Name")
    |> field.required(True)
    |> field.view(h.input([]))
    |> element.to_string
  assert string.contains(html, "field-required")
  assert string.contains(html, " *")
}

pub fn field_not_required_omits_aria_required_test() {
  let html =
    field.new()
    |> field.label("Name")
    |> field.required(False)
    |> field.view(h.input([]))
    |> element.to_string
  assert !string.contains(html, "aria-required")
}

pub fn field_hint_renders_test() {
  let html =
    field.new()
    |> field.label("Email")
    |> field.hint("Enter a valid email address.")
    |> field.view(h.input([]))
    |> element.to_string
  assert string.contains(html, "field-hint")
  assert string.contains(html, "Enter a valid email address.")
}

pub fn field_hint_empty_omits_test() {
  let html =
    field.new()
    |> field.label("Email")
    |> field.hint("")
    |> field.view(h.input([]))
    |> element.to_string
  assert !string.contains(html, "field-hint")
}

pub fn field_required_and_hint_together_test() {
  let html =
    field.new()
    |> field.label("Phone")
    |> field.required(True)
    |> field.hint("Include country code.")
    |> field.view(h.input([]))
    |> element.to_string
  assert string.contains(html, "field-required")
  assert string.contains(html, "field-hint")
  assert string.contains(html, "Include country code.")
}

// --- field accessibility wiring (field_id) ---

pub fn field_id_wires_label_for_test() {
  let html =
    field.new()
    |> field.label("Email")
    |> field.field_id("email-1")
    |> field.view(h.input([]))
    |> element.to_string
  assert string.contains(html, "for=\"email-1\"")
}

pub fn field_id_sets_hint_and_error_ids_test() {
  let html =
    field.new()
    |> field.label("Email")
    |> field.hint("We won't spam.")
    |> field.error("Required.")
    |> field.field_id("email-1")
    |> field.view(h.input([]))
    |> element.to_string
  assert string.contains(html, "id=\"email-1-hint\"")
  assert string.contains(html, "id=\"email-1-error\"")
}

pub fn field_without_id_omits_for_test() {
  let html =
    field.new()
    |> field.label("Email")
    |> field.view(h.input([]))
    |> element.to_string
  assert !string.contains(html, "for=")
}

// --- watch_system_dark ---

pub fn watch_system_dark_creates_effect_test() {
  // Returns an Effect wrapping the listener setup.
  // effect.from defers the callback — watchMediaQuery is NOT called during construction.
  let _ = theme.watch_system_dark(fn(_) { Nil })
}

pub fn is_system_dark_returns_bool_test() {
  // In test env (Node.js, no window), the FFI guard returns False.
  let _dark = theme.is_system_dark()
}
