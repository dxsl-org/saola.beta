import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type SpinnerSize {
  Small
  Medium
  Large
}

pub type SpinnerAttrs {
  SpinnerAttrs(size: SpinnerSize, class: String)
}

pub const default_attrs = SpinnerAttrs(size: Medium, class: "")

pub fn spinner_full(attrs: SpinnerAttrs) -> Element(msg) {
  let size_class = case attrs.size {
    Small -> "spinner spinner-sm"
    Medium -> "spinner spinner-md"
    Large -> "spinner spinner-lg"
  }
  let full_class = case attrs.class {
    "" -> size_class
    c -> size_class <> " " <> c
  }
  h.span(
    [
      a.class(full_class),
      a.role("status"),
      a.attribute("aria-label", "Loading"),
    ],
    [],
  )
}

pub fn spinner_simple() -> Element(msg) {
  spinner_full(default_attrs)
}
