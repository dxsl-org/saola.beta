//// Card widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// card.card_simple("Settings", [body])                  // shortcut
//// card.new()
//// |> card.title("Account")
//// |> card.description("Manage your settings.")
//// |> card.footer(save_button)
//// |> card.view([body])
//// ```

import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Presentation options for a card. Public for record-update syntax. The card
/// body (`content`) is the required data, passed to `view`.
pub type CardConfig(msg) {
  CardConfig(
    title: String,
    description: String,
    footer: Option(Element(msg)),
    class: String,
  )
}

/// Builder entry point. Defaults: no title/description/footer/class.
pub fn new() -> CardConfig(msg) {
  CardConfig(title: "", description: "", footer: None, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> CardConfig(msg) {
  new()
}

/// Set the header title (omitted when empty).
pub fn title(config: CardConfig(msg), title: String) -> CardConfig(msg) {
  CardConfig(..config, title: title)
}

/// Set the header description (omitted when empty).
pub fn description(config: CardConfig(msg), description: String) -> CardConfig(msg) {
  CardConfig(..config, description: description)
}

/// Set the footer element.
pub fn footer(config: CardConfig(msg), footer: Element(msg)) -> CardConfig(msg) {
  CardConfig(..config, footer: Some(footer))
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: CardConfig(msg), class: String) -> CardConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  CardConfig(..config, class: merged)
}

/// Render the card with the given body content. Uses semantic
/// `<header>`/`<section>`/`<footer>`.
pub fn view(config: CardConfig(msg), content: List(Element(msg))) -> Element(msg) {
  let header_el = case config.title, config.description {
    "", "" -> element.none()
    _, _ -> {
      let title_el = case config.title {
        "" -> element.none()
        t -> h.h2([], [h.text(t)])
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
  let root_class = case config.class {
    "" -> "card"
    c -> "card " <> c
  }
  h.div([a.class(root_class)], [header_el, content_el, footer_el])
}

// --- Convenience shortcuts ---

/// Render a card with a title and body content only.
pub fn card_simple(card_title: String, content: List(Element(msg))) -> Element(msg) {
  new() |> title(card_title) |> view(content)
}
