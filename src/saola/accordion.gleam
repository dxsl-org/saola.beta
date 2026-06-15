//// Accordion widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// accordion.accordion_simple(items: items, open_ids: open, on_toggle: Toggle)  // shortcut
//// accordion.new()
//// |> accordion.add_class("my-accordion")
//// |> accordion.view(items, model.open_sections, ToggleSection)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// A single accordion item.
pub type AccordionItem(msg) {
  AccordionItem(id: String, title: String, content: Element(msg))
}

/// Presentation options for an accordion. Public for record-update syntax. The
/// `items`, `open_ids`, and `on_toggle` are the required data (`view`).
pub type AccordionConfig {
  AccordionConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> AccordionConfig {
  AccordionConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> AccordionConfig {
  new()
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: AccordionConfig, class: String) -> AccordionConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  AccordionConfig(class: merged)
}

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

/// Render the accordion. `open_ids` are the currently-open item IDs;
/// `on_toggle` receives the clicked item's ID.
pub fn view(
  config: AccordionConfig,
  items: List(AccordionItem(msg)),
  open_ids: List(String),
  on_toggle: fn(String) -> msg,
) -> Element(msg) {
  let extra_class_attrs = case config.class {
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

// --- Convenience shortcuts ---

pub fn accordion_simple(
  items items: List(AccordionItem(msg)),
  open_ids open_ids: List(String),
  on_toggle on_toggle: fn(String) -> msg,
) -> Element(msg) {
  new() |> view(items, open_ids, on_toggle)
}
