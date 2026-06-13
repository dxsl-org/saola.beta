import components/general/button/button_default
import components/general/button/button_link
import lustre/element.{type Element}

pub fn button_default(
  text text: String,
  class_names class_names: String,
) -> Element(msg) {
  button_default.button_default(text: text, class_names: class_names)
}

pub fn button_link(
  text text: String,
  href href: String,
  class_names class_names: String,
) -> Element(msg) {
  button_link.button_link(text: text, href: href, class_names: class_names)
}
