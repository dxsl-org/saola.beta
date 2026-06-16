//// Timeline widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// timeline.timeline_simple(items)                                   // shortcut
//// timeline.new() |> timeline.add_class("my-timeline") |> timeline.view(items)
//// ```

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Status colour for a timeline entry's dot/connector.
pub type TimelineItemVariant {
  Default
  Success
  Warning
  Error
}

/// One event on the timeline. `time`/`description` are omitted when empty; an
/// absent `icon` renders a plain dot.
pub type TimelineItem(msg) {
  TimelineItem(
    time: String,
    title: String,
    description: String,
    icon: Option(Element(msg)),
    variant: TimelineItemVariant,
  )
}

/// Presentation options for a timeline. Public for record-update syntax. The
/// `items` list is the required data, passed to `view`.
pub type TimelineConfig {
  TimelineConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> TimelineConfig {
  TimelineConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> TimelineConfig {
  new()
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: TimelineConfig, class: String) -> TimelineConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  TimelineConfig(class: merged)
}

/// Render the vertical timeline of events (top-to-bottom).
pub fn view(
  config: TimelineConfig,
  items: List(TimelineItem(msg)),
) -> Element(msg) {
  let root_class = case config.class {
    "" -> "timeline"
    c -> "timeline " <> c
  }
  h.ol([a.class(root_class)], list.map(items, render_item))
}

fn render_item(item: TimelineItem(msg)) -> Element(msg) {
  let variant_class = case item.variant {
    Default -> "timeline-item"
    Success -> "timeline-item timeline-item-success"
    Warning -> "timeline-item timeline-item-warning"
    Error -> "timeline-item timeline-item-error"
  }
  let dot_el = case item.icon {
    None -> h.span([a.class("timeline-dot")], [])
    Some(icon) -> h.span([a.class("timeline-dot timeline-dot-icon")], [icon])
  }
  h.li([a.class(variant_class)], [
    h.div([a.class("timeline-connector")], [dot_el]),
    h.div([a.class("timeline-content")], [
      h.div([a.class("timeline-header")], [
        h.span([a.class("timeline-title")], [h.text(item.title)]),
        case item.time {
          "" -> element.none()
          t -> h.span([a.class("timeline-time")], [h.text(t)])
        },
      ]),
      case item.description {
        "" -> element.none()
        d -> h.p([a.class("timeline-description")], [h.text(d)])
      },
    ]),
  ])
}

// --- Convenience shortcuts ---

/// A timeline of the given items with default styling.
pub fn timeline_simple(items: List(TimelineItem(msg))) -> Element(msg) {
  new() |> view(items)
}
