import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub type ButtonType {
  HtmlButton
  HtmlLink(href: String)
}

pub type ButtonConfig {
  ButtonConfig(button_type: ButtonType, text: String, class_names: String)
}

pub fn build(config: ButtonConfig) -> Element(msg) {
  case config.button_type {
    HtmlButton ->
      html.button([attribute.class(config.class_names)], [
        element.text(config.text),
      ])

    HtmlLink(href) ->
      html.a([attribute.class(config.class_names), attribute.href(href)], [
        element.text(config.text),
      ])
  }
}
