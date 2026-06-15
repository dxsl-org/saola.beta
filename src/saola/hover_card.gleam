//// Hover card widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// hover_card.hover_card_simple(model.open, trigger, content)         // shortcut (bottom)
//// hover_card.new()
//// |> hover_card.side(hover_card.Right)
//// |> hover_card.view(model.open, trigger, content)
//// ```
//// `open` is consumer-owned — wire mouseenter/mouseleave on the trigger.

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type HoverCardSide {
  Top
  Bottom
  Left
  Right
}

/// Presentation options for a hover card. Public for record-update syntax. The
/// `open`/`trigger`/`content` are the required data, passed to `view`.
pub type HoverCardConfig {
  HoverCardConfig(side: HoverCardSide, class: String)
}

/// Builder entry point. Defaults: Bottom side, no extra class.
pub fn new() -> HoverCardConfig {
  HoverCardConfig(side: Bottom, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> HoverCardConfig {
  new()
}

/// Set the side the card opens toward (Top, Bottom — default, Left, Right).
pub fn side(config: HoverCardConfig, side: HoverCardSide) -> HoverCardConfig {
  HoverCardConfig(..config, side: side)
}

/// Append an extra CSS class on the wrapper. Additive only.
pub fn add_class(config: HoverCardConfig, class: String) -> HoverCardConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  HoverCardConfig(..config, class: merged)
}

/// Render the hover card: `trigger` always shown; `content` shows while `open`.
pub fn view(
  config: HoverCardConfig,
  open: Bool,
  trigger: Element(msg),
  content: Element(msg),
) -> Element(msg) {
  let side_attr = case config.side {
    Top -> a.attribute("data-side", "top")
    Bottom -> a.attribute("data-side", "bottom")
    Left -> a.attribute("data-side", "left")
    Right -> a.attribute("data-side", "right")
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(list.flatten([[a.class("hover-card-wrapper")], extra_class_attrs]), [
    trigger,
    case open {
      False -> h.text("")
      True ->
        h.div([a.class("hover-card"), side_attr, a.role("tooltip")], [content])
    },
  ])
}

// --- Convenience shortcuts ---

pub fn hover_card_simple(
  open: Bool,
  trigger: Element(msg),
  content: Element(msg),
) -> Element(msg) {
  new() |> view(open, trigger, content)
}
