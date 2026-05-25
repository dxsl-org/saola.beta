import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type ButtonGroupOrientation {
  Horizontal
  Vertical
}

pub type ButtonGroupAttrs {
  ButtonGroupAttrs(orientation: ButtonGroupOrientation, class: String)
}

pub const default_attrs = ButtonGroupAttrs(orientation: Horizontal, class: "")

pub fn button_group_full(
  children: List(Element(msg)),
  attrs: ButtonGroupAttrs,
) -> Element(msg) {
  let orientation_class = case attrs.orientation {
    Horizontal -> "button-group"
    Vertical -> "button-group button-group-vertical"
  }
  let full_class = case attrs.class {
    "" -> orientation_class
    c -> orientation_class <> " " <> c
  }
  h.div([a.role("group"), a.class(full_class)], children)
}

pub fn button_group_simple(children: List(Element(msg))) -> Element(msg) {
  button_group_full(children, default_attrs)
}
