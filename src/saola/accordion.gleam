import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// A single accordion item.
pub type AccordionItem(msg) {
  AccordionItem(id: String, title: String, content: Element(msg))
}

pub type AccordionAttrs {
  AccordionAttrs(class: String)
}

pub const default_attrs = AccordionAttrs(class: "")

fn render_item(
  item: AccordionItem(msg),
  is_open: Bool,
  on_toggle: fn(String) -> msg,
) -> Element(msg) {
  let panel_id = "accordion-panel-" <> item.id
  let btn_id = "accordion-btn-" <> item.id
  h.div([a.class("accordion-item")], [
    h.button(
      [
        a.type_("button"),
        a.class("accordion-trigger"),
        a.id(btn_id),
        a.aria_expanded(is_open),
        a.aria_controls(panel_id),
        e.on_click(on_toggle(item.id)),
      ],
      [h.text(item.title)],
    ),
    h.div(
      [
        a.class("accordion-panel"),
        a.id(panel_id),
        a.role("region"),
        a.aria_labelledby(btn_id),
        a.aria_hidden(!is_open),
      ],
      [item.content],
    ),
  ])
}

/// Render an accordion. `open_ids` is the list of currently open item IDs.
/// `on_toggle` is called with the item ID when a trigger is clicked.
///
/// Example:
/// ```gleam
/// accordion_simple(
///   items: [
///     AccordionItem("q1", "What is Saola?", h.p([], [h.text("A UI library.")])),
///     AccordionItem("q2", "How to install?", h.p([], [h.text("gleam add saola")])),
///   ],
///   open_ids: model.open_sections,
///   on_toggle: ToggleSection,
/// )
/// ```
pub fn accordion(
  items items: List(AccordionItem(msg)),
  open_ids open_ids: List(String),
  on_toggle on_toggle: fn(String) -> msg,
  attrs attrs: AccordionAttrs,
) -> Element(msg) {
  let extra_class_attrs = case attrs.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(
    list.flatten([[a.class("accordion")], extra_class_attrs]),
    list.map(items, fn(item) {
      render_item(item, list.contains(open_ids, item.id), on_toggle)
    }),
  )
}

/// Simple accordion with default styling.
pub fn accordion_simple(
  items items: List(AccordionItem(msg)),
  open_ids open_ids: List(String),
  on_toggle on_toggle: fn(String) -> msg,
) -> Element(msg) {
  accordion(
    items: items,
    open_ids: open_ids,
    on_toggle: on_toggle,
    attrs: default_attrs,
  )
}
