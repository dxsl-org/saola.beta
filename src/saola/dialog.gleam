//// Dialog (modal) widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// dialog.dialog_simple(model.open, "Delete?", [body], CloseDialog)   // shortcut
//// dialog.new()
//// |> dialog.description("This cannot be undone.")
//// |> dialog.footer(confirm_row)
//// |> dialog.view(model.open, "Are you sure?", [], CloseDialog)
//// ```
//// Uses the native `<dialog open>` element; the consumer owns `is_open`.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/button
import typeid

/// Presentation options for a dialog. Public for record-update syntax. The
/// `is_open`/`title`/`content`/`on_close` are the required data (`view`).
pub type DialogConfig(msg) {
  DialogConfig(
    description: String,
    footer: Option(Element(msg)),
    show_close_button: Bool,
    class: String,
  )
}

/// Builder entry point. Defaults: no description/footer, close button shown.
pub fn new() -> DialogConfig(msg) {
  DialogConfig(
    description: "",
    footer: None,
    show_close_button: True,
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> DialogConfig(msg) {
  new()
}

/// Set the header description (omitted when empty).
pub fn description(config: DialogConfig(msg), description: String) -> DialogConfig(msg) {
  DialogConfig(..config, description: description)
}

/// Set the footer element.
pub fn footer(config: DialogConfig(msg), footer: Element(msg)) -> DialogConfig(msg) {
  DialogConfig(..config, footer: Some(footer))
}

/// Toggle the top-right close button (default shown).
pub fn show_close_button(config: DialogConfig(msg), show: Bool) -> DialogConfig(msg) {
  DialogConfig(..config, show_close_button: show)
}

/// Append an extra CSS class on the dialog. Additive only.
pub fn add_class(config: DialogConfig(msg), class: String) -> DialogConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  DialogConfig(..config, class: merged)
}

/// Render the dialog. `is_open` controls visibility (consumer-owned); the close
/// button (when shown) dispatches `on_close`.
pub fn view(
  config: DialogConfig(msg),
  is_open: Bool,
  title: String,
  content: List(Element(msg)),
  on_close: msg,
) -> Element(msg) {
  let title_id =
    typeid.new(prefix: "dlg")
    |> result.map(typeid.to_string)
    |> result.unwrap("dlg-title")
  let open_attrs = case is_open {
    True -> [a.attribute("open", "")]
    False -> []
  }
  let labelledby_attrs = case title {
    "" -> []
    _ -> [a.aria_labelledby(title_id)]
  }
  let class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let close_btn = case config.show_close_button {
    False -> element.none()
    True -> button.button_close(on_close)
  }
  let header_el = case title, config.description {
    "", "" -> element.none()
    _, _ -> {
      let title_el = case title {
        "" -> element.none()
        t -> h.h2([a.id(title_id)], [h.text(t)])
      }
      let desc_el = case config.description {
        "" -> element.none()
        d -> h.p([], [h.text(d)])
      }
      h.header([], [title_el, desc_el])
    }
  }
  let content_el = case content {
    [] -> element.none()
    children -> h.section([], children)
  }
  let footer_el = case config.footer {
    None -> element.none()
    Some(f) -> h.footer([], [f])
  }
  h.dialog(
    list.flatten([
      [a.class("dialog")],
      class_attrs,
      open_attrs,
      [a.aria_modal(True)],
      labelledby_attrs,
    ]),
    [h.div([], [close_btn, header_el, content_el, footer_el])],
  )
}

// --- Convenience shortcuts ---

/// Simple dialog with title, content, and a close button.
pub fn dialog_simple(
  is_open is_open: Bool,
  title title: String,
  content content: List(Element(msg)),
  on_close on_close: msg,
) -> Element(msg) {
  new() |> view(is_open, title, content, on_close)
}
