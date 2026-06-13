import components/general/button/button_base.{ButtonConfig, HtmlButton, build}
import lustre/element.{type Element}

pub fn button_default(
  text text: String,
  class_names class_names: String,
) -> Element(msg) {
  build(ButtonConfig(
    button_type: HtmlButton,
    text: text,
    class_names: class_names,
  ))
}
