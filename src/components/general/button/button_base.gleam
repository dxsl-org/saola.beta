import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub type Variant {
  Primary
  Default
  Dashed
  Text
  Link
}

pub type ButtonConfig {
  ButtonConfig(
    variant: Variant,
    text: String,
    danger: Bool,
    disabled: Bool,
    href: Option(String),
    class_names: String,
  )
}

fn build_class(config: ButtonConfig) -> String {
  let variant_class = case config.variant {
    Primary -> "btn-variant-primary"
    Default -> "btn-variant-default"
    Dashed -> "btn-variant-dashed"
    Text -> "btn-variant-text"
    Link -> "btn-variant-link"
  }

  let danger_class = case config.danger {
    True -> " btn-danger"
    False -> ""
  }

  let disabled_class = case config.disabled {
    True -> " btn-disabled"
    False -> ""
  }

  variant_class <> danger_class <> disabled_class <> " " <> config.class_names
}

pub fn render(config: ButtonConfig) -> Element(msg) {
  let final_class = build_class(config)

  case config.href {
    Some(href) ->
      html.a([attribute.class(final_class), attribute.href(href)], [
        element.text(config.text),
      ])

    None ->
      html.button(
        [attribute.class(final_class), attribute.disabled(config.disabled)],
        [element.text(config.text)],
      )
  }
}
