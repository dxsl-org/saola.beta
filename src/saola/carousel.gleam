//// Carousel widget (custom element wrapper) — dual-style `Config` (uniform pattern):
////
//// ```gleam
//// carousel.carousel_simple(slides, model.idx, SlideChanged)         // shortcut
//// carousel.new()
//// |> carousel.loop(True)
//// |> carousel.orientation(carousel.Vertical)
//// |> carousel.view(slides, model.idx, model.can_prev, model.can_next, SlideChanged)
//// ```

import gleam/dynamic/decode
import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

@external(javascript, "./carousel.ffi.mjs", "ensure_registered")
fn ensure_registered() -> Nil

pub type CarouselOrientation {
  Horizontal
  Vertical
}

/// Presentation options for a carousel. Public for record-update syntax. The
/// slides/index/scroll-flags/on_change are the required data, passed to `view`.
pub type CarouselConfig {
  CarouselConfig(orientation: CarouselOrientation, loop: Bool, class: String)
}

/// Builder entry point. Defaults: Horizontal, no loop, no extra class.
pub fn new() -> CarouselConfig {
  CarouselConfig(orientation: Horizontal, loop: False, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> CarouselConfig {
  new()
}

/// Set the orientation (Horizontal — default, Vertical).
pub fn orientation(
  config: CarouselConfig,
  orientation: CarouselOrientation,
) -> CarouselConfig {
  CarouselConfig(..config, orientation: orientation)
}

/// Enable looping (default off).
pub fn loop(config: CarouselConfig, loop: Bool) -> CarouselConfig {
  CarouselConfig(..config, loop: loop)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: CarouselConfig, class: String) -> CarouselConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  CarouselConfig(..config, class: merged)
}

fn decode_change(callback: fn(Int, Bool, Bool) -> msg) -> decode.Decoder(msg) {
  use idx <- decode.subfield(["detail", "index"], decode.int)
  use can_prev <- decode.subfield(["detail", "canScrollPrev"], decode.bool)
  use can_next <- decode.subfield(["detail", "canScrollNext"], decode.bool)
  decode.success(callback(idx, can_prev, can_next))
}

fn orientation_str(o: CarouselOrientation) -> String {
  case o {
    Horizontal -> "horizontal"
    Vertical -> "vertical"
  }
}

/// Render the carousel. `current_index`/`can_scroll_prev`/`can_scroll_next` are
/// consumer-owned; `on_change` fires on the custom element's slide-change event.
pub fn view(
  config: CarouselConfig,
  slides: List(Element(msg)),
  current_index: Int,
  can_scroll_prev: Bool,
  can_scroll_next: Bool,
  on_change: fn(Int, Bool, Bool) -> msg,
) -> Element(msg) {
  ensure_registered()
  let _ = current_index
  let _ = can_scroll_prev
  let _ = can_scroll_next
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let loop_attrs = case config.loop {
    True -> [a.attribute("loop", "")]
    False -> []
  }
  let slide_wrappers =
    list.map(slides, fn(s) { h.div([a.attribute("data-slot", "slide")], [s]) })
  element.element(
    "saola-carousel",
    list.flatten([
      [
        a.class("carousel-root"),
        a.attribute("role", "region"),
        a.attribute("aria-roledescription", "carousel"),
        a.attribute("aria-label", "Carousel"),
        a.attribute("orientation", orientation_str(config.orientation)),
      ],
      loop_attrs,
      [e.on("slide-change", decode_change(on_change))],
      extra_class_attrs,
    ]),
    slide_wrappers,
  )
}

// --- Convenience shortcuts ---

pub fn carousel_simple(
  slides: List(Element(msg)),
  current_index: Int,
  on_change: fn(Int, Bool, Bool) -> msg,
) -> Element(msg) {
  new() |> view(slides, current_index, True, True, on_change)
}
