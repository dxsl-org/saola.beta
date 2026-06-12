import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type InputGroupAttrs {
  InputGroupAttrs(class: String, invalid: Bool)
}

pub const default_attrs = InputGroupAttrs(class: "", invalid: False)

pub fn input_group(
  prefix: Option(Element(msg)),
  content: Element(msg),
  suffix: Option(Element(msg)),
  attrs: InputGroupAttrs,
) -> Element(msg) {
  let extra_class_attrs = case attrs.class {
    "" -> []
    c -> [a.class(c)]
  }
  let invalid_attrs = case attrs.invalid {
    True -> [a.attribute("aria-invalid", "true")]
    False -> []
  }
  h.div(
    list.flatten([[a.role("group"), a.class("input-group")], extra_class_attrs, invalid_attrs]),
    [
      case prefix {
        None -> h.text("")
        Some(p) -> h.div([a.class("input-group-addon")], [p])
      },
      content,
      case suffix {
        None -> h.text("")
        Some(s) -> h.div([a.class("input-group-addon")], [s])
      },
    ],
  )
}

pub fn input_group_simple(
  prefix: Option(Element(msg)),
  content: Element(msg),
  suffix: Option(Element(msg)),
) -> Element(msg) {
  input_group(prefix, content, suffix, default_attrs)
}
