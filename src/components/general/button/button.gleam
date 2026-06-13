import lustre/element.{type Element}
import lustre/attribute
import lustre/element/html

pub type ButtonType {
  HtmlButton
  HtmlLink(href: String) // Link thì cần có thêm thuộc tính href
}

pub type ButtonConfig {
  ButtonConfig(
    button_type: ButtonType,
    text: String,
    class_names: String,
  )
}

pub fn render_button(config: ButtonConfig) -> Element(msg) {
  case config.button_type {
    HtmlButton ->
      html.button(
        [attribute.class(config.class_names)], 
        [element.text(config.text)]
      )

    HtmlLink(href) ->
      html.a(
        [
          attribute.class(config.class_names),
          attribute.href(href)
        ],
        [element.text(config.text)]
      )
  }
}

pub fn render(config: ButtonConfig) -> Element(msg) {
  render_button(ButtonConfig(
    button_type: config.button_type,
    text: config.text,
    class_names: config.class_names,
  ))
}