import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type TimelineItemVariant {
  Default
  Success
  Warning
  Error
}

pub type TimelineItem(msg) {
  TimelineItem(
    time: String,
    title: String,
    description: String,
    icon: Option(Element(msg)),
    variant: TimelineItemVariant,
  )
}

pub type TimelineAttrs {
  TimelineAttrs(class: String)
}

pub const default_attrs = TimelineAttrs(class: "")

/// Vertical timeline of events.
///
/// - `items`: list of timeline entries, rendered top-to-bottom
pub fn timeline_full(
  items: List(TimelineItem(msg)),
  attrs: TimelineAttrs,
) -> Element(msg) {
  let root_class = case attrs.class {
    "" -> "timeline"
    c -> "timeline " <> c
  }
  h.ol([a.class(root_class)], list.map(items, render_item))
}

pub fn timeline_simple(items: List(TimelineItem(msg))) -> Element(msg) {
  timeline_full(items, default_attrs)
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
