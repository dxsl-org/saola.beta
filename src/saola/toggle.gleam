import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type ToggleVariant {
  Default
  Outline
}

pub type ToggleSize {
  Small
  Medium
  Large
}

pub type ToggleAttrs {
  ToggleAttrs(
    variant: ToggleVariant,
    size: ToggleSize,
    disabled: Bool,
    class: String,
  )
}

pub const default_attrs = ToggleAttrs(
  variant: Default,
  size: Medium,
  disabled: False,
  class: "",
)

pub fn toggle(
  pressed: Bool,
  label: String,
  on_change: fn(Bool) -> msg,
  attrs: ToggleAttrs,
) -> Element(msg) {
  let base_class = case attrs.variant, attrs.size {
    Default, Small -> "btn btn-sm btn-ghost"
    Default, Medium -> "btn btn-ghost"
    Default, Large -> "btn btn-lg btn-ghost"
    Outline, Small -> "btn btn-sm btn-outline"
    Outline, Medium -> "btn btn-outline"
    Outline, Large -> "btn btn-lg btn-outline"
  }
  let full_class = case attrs.class {
    "" -> base_class
    c -> base_class <> " " <> c
  }
  let disabled_attrs = case attrs.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  h.button(
    list.flatten([
      [
        a.type_("button"),
        a.class(full_class),
        a.attribute("aria-pressed", case pressed {
          True -> "true"
          False -> "false"
        }),
        e.on_click(on_change(!pressed)),
      ],
      disabled_attrs,
    ]),
    [h.text(label)],
  )
}

pub fn toggle_simple(
  pressed: Bool,
  label: String,
  on_change: fn(Bool) -> msg,
) -> Element(msg) {
  toggle(pressed, label, on_change, default_attrs)
}
