import gleam/list
import gleam/result
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import typeid

pub type CollapsibleAttrs {
  CollapsibleAttrs(disabled: Bool, class: String)
}

pub const default_attrs = CollapsibleAttrs(disabled: False, class: "")

pub fn collapsible(
  open: Bool,
  trigger: Element(msg),
  content: Element(msg),
  on_toggle: fn() -> msg,
  attrs: CollapsibleAttrs,
) -> Element(msg) {
  let id =
    typeid.new(prefix: "col")
    |> result.map(typeid.to_string)
    |> result.unwrap("collapsible-panel")
  let extra_class_attrs = case attrs.class {
    "" -> []
    c -> [a.class(c)]
  }
  let disabled_attrs = case attrs.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  h.div(list.flatten([[a.class("collapsible")], extra_class_attrs]), [
    h.button(
      list.flatten([
        [
          a.type_("button"),
          a.class("collapsible-trigger"),
          a.attribute("aria-expanded", case open {
            True -> "true"
            False -> "false"
          }),
          a.attribute("aria-controls", id),
        ],
        disabled_attrs,
        [e.on_click(on_toggle())],
      ]),
      [trigger],
    ),
    h.div(
      [
        a.class("collapsible-content"),
        a.id(id),
        a.attribute("aria-hidden", case open {
          True -> "false"
          False -> "true"
        }),
      ],
      [content],
    ),
  ])
}

pub fn collapsible_simple(
  open: Bool,
  trigger_label: String,
  content: Element(msg),
  on_toggle: fn() -> msg,
) -> Element(msg) {
  collapsible(open, h.text(trigger_label), content, on_toggle, default_attrs)
}
