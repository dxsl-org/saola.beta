import components/general/button/button_base.{
  type ButtonConfig, type Variant, ButtonConfig, Default,
}
import gleam/option.{None, Some}
import lustre/element.{type Element}

pub fn new() -> ButtonConfig {
  ButtonConfig(
    text: "",
    variant: Default,
    danger: False,
    disabled: False,
    href: None,
    class_names: "",
  )
}

pub fn variant(config: ButtonConfig, v: Variant) -> ButtonConfig {
  ButtonConfig(..config, variant: v)
}

pub fn text(config: ButtonConfig, t: String) -> ButtonConfig {
  ButtonConfig(..config, text: t)
}

pub fn danger(config: ButtonConfig, d: Bool) -> ButtonConfig {
  ButtonConfig(..config, danger: d)
}

pub fn disabled(config: ButtonConfig, d: Bool) -> ButtonConfig {
  ButtonConfig(..config, disabled: d)
}

pub fn href(config: ButtonConfig, h: String) -> ButtonConfig {
  ButtonConfig(..config, href: Some(h))
}

pub fn class_names(config: ButtonConfig, c: String) -> ButtonConfig {
  ButtonConfig(..config, class_names: c)
}

pub fn render(config: ButtonConfig) -> Element(msg) {
  button_base.render(config)
}
