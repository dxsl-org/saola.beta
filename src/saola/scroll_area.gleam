//// Scroll area widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// scroll_area.scroll_area_simple(content, "20rem")                  // shortcut
//// scroll_area.new()
//// |> scroll_area.height("20rem")
//// |> scroll_area.width("16rem")
//// |> scroll_area.view(content)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Presentation options for a scroll area. Public for record-update syntax.
/// The `content` is the required data, passed to `view`.
pub type ScrollAreaConfig {
  ScrollAreaConfig(height: String, width: String, class: String)
}

/// Builder entry point. Defaults: auto height, 100% width, no extra class.
pub fn new() -> ScrollAreaConfig {
  ScrollAreaConfig(height: "", width: "100%", class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> ScrollAreaConfig {
  new()
}

/// Set the viewport height (any CSS length, e.g. "20rem").
pub fn height(config: ScrollAreaConfig, height: String) -> ScrollAreaConfig {
  ScrollAreaConfig(..config, height: height)
}

/// Set the viewport width (default "100%").
pub fn width(config: ScrollAreaConfig, width: String) -> ScrollAreaConfig {
  ScrollAreaConfig(..config, width: width)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: ScrollAreaConfig, class: String) -> ScrollAreaConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  ScrollAreaConfig(..config, class: merged)
}

/// Render the scroll area wrapping the given content.
pub fn view(config: ScrollAreaConfig, content: Element(msg)) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(
    list.flatten([
      [a.class("scroll-area")],
      extra_class_attrs,
      [
        a.style("height", config.height),
        a.style("width", config.width),
        a.attribute("data-radix-scroll-area-root", ""),
      ],
    ]),
    [
      h.div(
        [
          a.class("scroll-area-viewport"),
          a.attribute("role", "region"),
          a.attribute("aria-label", "Scrollable content"),
          a.attribute("tabindex", "0"),
        ],
        [content],
      ),
    ],
  )
}

// --- Convenience shortcuts ---

pub fn scroll_area_simple(content: Element(msg), ht: String) -> Element(msg) {
  new() |> height(ht) |> view(content)
}
