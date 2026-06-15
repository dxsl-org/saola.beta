//// Item widget (list row) — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// item.item_simple("Title", "Description", Some(action))    // shortcut
//// item.new()
//// |> item.variant(item.Outline)
//// |> item.media(icon)
//// |> item.media_variant(item.MediaIcon)
//// |> item.actions([button])
//// |> item.view("Title", "Description", "")        // empty href → <div>; href → <a>
//// ```

import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type ItemVariant {
  Default
  Outline
  Muted
}

pub type ItemSize {
  Large
  Small
}

pub type ItemMediaVariant {
  MediaDefault
  MediaIcon
  MediaImage
}

/// Presentation options for an item. Public for record-update syntax. The
/// `title`/`description` text and the `href` (render target) are required —
/// passed to `view`.
pub type ItemConfig(msg) {
  ItemConfig(
    variant: ItemVariant,
    size: ItemSize,
    media: Option(Element(msg)),
    media_variant: ItemMediaVariant,
    actions: List(Element(msg)),
    class: String,
  )
}

/// Builder entry point. Defaults: Default, Large, no media, no actions.
pub fn new() -> ItemConfig(msg) {
  ItemConfig(
    variant: Default,
    size: Large,
    media: None,
    media_variant: MediaDefault,
    actions: [],
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> ItemConfig(msg) {
  new()
}

/// Set the variant (Default, Outline, Muted).
pub fn variant(config: ItemConfig(msg), variant: ItemVariant) -> ItemConfig(msg) {
  ItemConfig(..config, variant: variant)
}

/// Set the size (Large — default, Small).
pub fn size(config: ItemConfig(msg), size: ItemSize) -> ItemConfig(msg) {
  ItemConfig(..config, size: size)
}

/// Set the leading media element (icon/image/avatar).
pub fn media(config: ItemConfig(msg), media: Element(msg)) -> ItemConfig(msg) {
  ItemConfig(..config, media: Some(media))
}

/// Set how the media is framed (MediaDefault, MediaIcon, MediaImage).
pub fn media_variant(
  config: ItemConfig(msg),
  media_variant: ItemMediaVariant,
) -> ItemConfig(msg) {
  ItemConfig(..config, media_variant: media_variant)
}

/// Set the trailing action elements.
pub fn actions(
  config: ItemConfig(msg),
  actions: List(Element(msg)),
) -> ItemConfig(msg) {
  ItemConfig(..config, actions: actions)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: ItemConfig(msg), class: String) -> ItemConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ItemConfig(..config, class: merged)
}

fn variant_class(v: ItemVariant) -> String {
  case v {
    Default -> "item-default"
    Outline -> "item-outline"
    Muted -> "item-muted"
  }
}

fn size_class(s: ItemSize) -> String {
  case s {
    Large -> "item-lg"
    Small -> "item-sm"
  }
}

fn media_class(v: ItemMediaVariant) -> String {
  case v {
    MediaDefault -> "item-media"
    MediaIcon -> "item-media item-media-icon"
    MediaImage -> "item-media item-media-image"
  }
}

fn item_body(
  config: ItemConfig(msg),
  title: String,
  description: String,
) -> List(Element(msg)) {
  let media_el = case config.media {
    None -> element.none()
    Some(m) -> h.div([a.class(media_class(config.media_variant))], [m])
  }
  let title_el = case title {
    "" -> element.none()
    t -> h.div([a.class("item-title")], [h.text(t)])
  }
  let desc_el = case description {
    "" -> element.none()
    d -> h.p([a.class("item-description")], [h.text(d)])
  }
  let content_el = case title, description {
    "", "" -> element.none()
    _, _ -> h.div([a.class("item-content")], [title_el, desc_el])
  }
  let actions_el = case config.actions {
    [] -> element.none()
    acts -> h.div([a.class("item-actions")], acts)
  }
  [media_el, content_el, actions_el]
}

/// Render the item. An empty `href` renders `<div>`; a non-empty `href`
/// renders `<a href>` (a navigable list row).
pub fn view(
  config: ItemConfig(msg),
  title: String,
  description: String,
  href: String,
) -> Element(msg) {
  let base = "item " <> variant_class(config.variant) <> " " <> size_class(config.size)
  let cls = case config.class {
    "" -> base
    c -> base <> " " <> c
  }
  let body = item_body(config, title, description)
  case href {
    "" -> h.div([a.class(cls)], body)
    url -> h.a([a.class(cls), a.href(url)], body)
  }
}

// --- Convenience shortcuts ---

pub fn item_simple(
  title: String,
  description: String,
  action: Option(Element(msg)),
) -> Element(msg) {
  let acts = case action {
    None -> []
    Some(act) -> [act]
  }
  new() |> actions(acts) |> view(title, description, "")
}

pub fn item_link(
  href href: String,
  title title: String,
  description description: String,
  action action: Option(Element(msg)),
  class class: String,
) -> Element(msg) {
  let acts = case action {
    None -> []
    Some(act) -> [act]
  }
  new() |> actions(acts) |> add_class(class) |> view(title, description, href)
}

/// A list container grouping items.
pub fn item_group(children: List(Element(msg))) -> Element(msg) {
  h.div([a.role("list"), a.class("item-group")], children)
}

/// A separator rule between items.
pub fn item_separator() -> Element(msg) {
  h.hr([a.role("separator"), a.class("item-separator")])
}
