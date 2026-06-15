//// Tooltip — a CSS-only tooltip. Two forms:
////
//// 1. **Attribute helpers** (`attr`/`side_attr`) — add a tooltip to ANY element
////    directly. These return `Attribute(msg)`, so they sit outside the
////    element-rendering `Config` pattern by nature.
//// 2. **Wrapper** (dual-style `Config`) — wrap a child in a `<span>` carrying
////    the tooltip, for when you can't add attributes to the child.
////
//// ```gleam
//// h.button([tooltip.attr("Save file")], [text("Save")])              // attribute
//// tooltip.tooltip("Copy link", icon)                                 // wrapper shortcut
//// tooltip.new() |> tooltip.side(tooltip.Left) |> tooltip.view("Edit", icon)
//// ```

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute} as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type TooltipSide {
  Top
  Bottom
  Left
  Right
}

fn side_string(side: TooltipSide) -> String {
  case side {
    Top -> "top"
    Bottom -> "bottom"
    Left -> "left"
    Right -> "right"
  }
}

// --- Attribute helpers (decorate any element) ---

/// Add a CSS-only tooltip to any element via the `data-tooltip` attribute.
pub fn attr(text: String) -> Attribute(msg) {
  a.attribute("data-tooltip", text)
}

/// Add explicit tooltip positioning via `data-side`.
pub fn side_attr(side: TooltipSide) -> Attribute(msg) {
  a.attribute("data-side", side_string(side))
}

// --- Wrapper (dual-style Config) ---

/// Presentation options for the tooltip wrapper. Public for record-update
/// syntax. The `text` and wrapped `child` are the required data (`view`).
pub type TooltipConfig {
  TooltipConfig(side: Option(TooltipSide), class: String)
}

/// Builder entry point. Defaults: no explicit side, no extra class.
pub fn new() -> TooltipConfig {
  TooltipConfig(side: None, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> TooltipConfig {
  new()
}

/// Set the tooltip side (Top, Bottom, Left, Right).
pub fn side(config: TooltipConfig, side: TooltipSide) -> TooltipConfig {
  TooltipConfig(..config, side: Some(side))
}

/// Append an extra CSS class on the wrapper span. Additive only.
pub fn add_class(config: TooltipConfig, class: String) -> TooltipConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  TooltipConfig(..config, class: merged)
}

/// Wrap a child element in a `<span>` carrying the tooltip.
pub fn view(config: TooltipConfig, text: String, child: Element(msg)) -> Element(msg) {
  let side_attrs = case config.side {
    None -> []
    Some(s) -> [a.attribute("data-side", side_string(s))]
  }
  let class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.span(
    [a.attribute("data-tooltip", text), ..list.flatten([side_attrs, class_attrs])],
    [child],
  )
}

// --- Convenience shortcuts ---

/// Wrap a child element in a span with a tooltip.
pub fn tooltip(text: String, child: Element(msg)) -> Element(msg) {
  new() |> view(text, child)
}

/// Wrap with explicit tooltip side.
pub fn tooltip_side(
  text: String,
  tip_side: TooltipSide,
  child: Element(msg),
) -> Element(msg) {
  new() |> side(tip_side) |> view(text, child)
}
