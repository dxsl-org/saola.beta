import gleam/int
import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type ProgressVariant {
  Default
  Success
  Destructive
}

pub type ProgressAttrs {
  ProgressAttrs(
    min: Int,
    max: Int,
    variant: ProgressVariant,
    label: String,
    class: String,
  )
}

pub const default_attrs = ProgressAttrs(
  min: 0,
  max: 100,
  variant: Default,
  label: "",
  class: "",
)

fn fill_pct(value: Int, min: Int, max: Int) -> String {
  let range = max - min
  let pct = case range {
    0 -> 0
    r -> { value - min } * 100 / r
  }
  int.clamp(pct, min: 0, max: 100) |> int.to_string
}

/// Render a progress bar.
///
/// `value` must be within `[attrs.min, attrs.max]`.
/// The fill width is computed as a CSS custom property `--progress-value`.
///
/// Example:
/// ```gleam
/// progress_simple(65)
/// progress(3, ProgressAttrs(min: 0, max: 5, variant: Success, label: "Step 3 of 5", class: ""))
/// ```
pub fn progress(value: Int, attrs: ProgressAttrs) -> Element(msg) {
  let ProgressAttrs(min:, max:, variant:, label:, class:) = attrs
  let pct = fill_pct(value, min, max)
  let bar_class = case variant {
    Default -> "progress-bar"
    Success -> "progress-bar progress-bar-success"
    Destructive -> "progress-bar progress-bar-destructive"
  }
  let extra_class_attrs = case class {
    "" -> []
    c -> [a.class(c)]
  }
  let label_attrs = case label {
    "" -> []
    l -> [a.aria_label(l)]
  }
  h.div(
    list.flatten([
      [a.class("progress")],
      extra_class_attrs,
      [
        a.role("progressbar"),
        a.attribute("aria-valuemin", int.to_string(min)),
        a.attribute("aria-valuemax", int.to_string(max)),
        a.attribute("aria-valuenow", int.to_string(value)),
        a.attribute("aria-live", "polite"),
      ],
      label_attrs,
    ]),
    [h.div([a.class(bar_class), a.style("width", pct <> "%")], [])],
  )
}

/// Simple progress bar, 0–100 range.
pub fn progress_simple(value: Int) -> Element(msg) {
  progress(value, default_attrs)
}
