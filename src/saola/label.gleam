import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub const class_label = "label"

/// Render a styled label element.
///
/// Example:
/// ```gleam
/// label("Email address", "", "")
/// label("Username", "username-input", "")
/// ```
pub fn label(text: String, for_: String, class: String) -> Element(msg) {
  let for_attrs = case for_ {
    "" -> []
    v -> [a.for(v)]
  }
  let extra_class_attrs = case class {
    "" -> []
    c -> [a.class(c)]
  }
  h.label(
    list.flatten([[a.class(class_label)], for_attrs, extra_class_attrs]),
    [h.text(text)],
  )
}

/// Shortcut for a label associated with an input by ID.
pub fn label_for(text: String, input_id: String) -> Element(msg) {
  label(text, input_id, "")
}
