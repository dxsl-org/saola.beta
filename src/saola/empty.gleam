//// Empty-state widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// empty.empty_simple(Some(icon), "No results", "Try another search", Some(action))  // shortcut
//// empty.new()
//// |> empty.media(icon)
//// |> empty.media_variant(empty.Icon)
//// |> empty.view("No results", [element.text("Try another search.")], [action])
//// ```

import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type EmptyMediaVariant {
  Default
  Icon
}

/// Presentation options for an empty state. Public for record-update syntax.
/// The `title`, `description`, and `content` are required — passed to `view`.
pub type EmptyConfig(msg) {
  EmptyConfig(
    media: Option(Element(msg)),
    media_variant: EmptyMediaVariant,
    class: String,
  )
}

/// Builder entry point. Defaults: no media, Default media frame, no class.
pub fn new() -> EmptyConfig(msg) {
  EmptyConfig(media: None, media_variant: Default, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> EmptyConfig(msg) {
  new()
}

/// Set the leading media element (illustration/icon).
pub fn media(config: EmptyConfig(msg), media: Element(msg)) -> EmptyConfig(msg) {
  EmptyConfig(..config, media: Some(media))
}

/// Set how the media is framed (Default, Icon).
pub fn media_variant(
  config: EmptyConfig(msg),
  media_variant: EmptyMediaVariant,
) -> EmptyConfig(msg) {
  EmptyConfig(..config, media_variant: media_variant)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: EmptyConfig(msg), class: String) -> EmptyConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  EmptyConfig(..config, class: merged)
}

/// Render the empty state. `description` and `content` (e.g. action buttons)
/// are element lists.
pub fn view(
  config: EmptyConfig(msg),
  title: String,
  description: List(Element(msg)),
  content: List(Element(msg)),
) -> Element(msg) {
  let root_class = case config.class {
    "" -> "empty"
    c -> "empty " <> c
  }
  let media_el = case config.media {
    None -> element.none()
    Some(m) -> {
      let mc = case config.media_variant {
        Default -> "empty-media"
        Icon -> "empty-media empty-media-icon"
      }
      h.div([a.class(mc)], [m])
    }
  }
  let title_el = case title {
    "" -> element.none()
    t -> h.h2([a.class("empty-title")], [h.text(t)])
  }
  let desc_el = case description {
    [] -> element.none()
    children -> h.p([a.class("empty-description")], children)
  }
  let header_el = case config.media, title, description {
    None, "", [] -> element.none()
    _, _, _ -> h.div([a.class("empty-header")], [media_el, title_el, desc_el])
  }
  let content_el = case content {
    [] -> element.none()
    children -> h.div([a.class("empty-content")], children)
  }
  h.div([a.class(root_class)], [header_el, content_el])
}

// --- Convenience shortcuts ---

pub fn empty_simple(
  icon: Option(Element(msg)),
  title: String,
  description: String,
  action: Option(Element(msg)),
) -> Element(msg) {
  let config = case icon {
    None -> new()
    Some(i) -> new() |> media(i) |> media_variant(Icon)
  }
  let desc_children = case description {
    "" -> []
    t -> [h.text(t)]
  }
  let content_children = case action {
    None -> []
    Some(act) -> [act]
  }
  config |> view(title, desc_children, content_children)
}
