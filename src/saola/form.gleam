import saola/field.{type FieldAttrs, FieldAttrs}

/// Maps a validation Result onto FieldAttrs.error.
/// Ok(_)    → clears any existing error
/// Error(e) → sets error to e
pub fn field_attrs_from_result(
  result: Result(String, String),
  attrs: FieldAttrs,
) -> FieldAttrs {
  case result {
    Ok(_) -> FieldAttrs(..attrs, error: "")
    Error(e) -> FieldAttrs(..attrs, error: e)
  }
}
