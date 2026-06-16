//// Aspect-ratio box — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// aspect_ratio.aspect_ratio(16.0 /. 9.0, content)                   // shortcut
//// aspect_ratio.new() |> aspect_ratio.add_class("rounded") |> aspect_ratio.view(16.0 /. 9.0, content)
//// ```

import gleam/float
import gleam/int
import gleam/list
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Presentation options for an aspect-ratio box. Public for record-update
/// syntax. The `ratio` and `content` are required data, passed to `view`.
pub type AspectRatioConfig {
  AspectRatioConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> AspectRatioConfig {
  AspectRatioConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> AspectRatioConfig {
  new()
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: AspectRatioConfig, class: String) -> AspectRatioConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  AspectRatioConfig(class: merged)
}

/// Render content inside a box that maintains the given aspect ratio.
/// `ratio` is width/height, e.g. `16.0 /. 9.0` for widescreen.
pub fn view(config: AspectRatioConfig, ratio: Float, content: Element(msg)) -> Element(msg) {
  let pct = 1.0 /. ratio *. 100.0
  let pct_str = format_pct(pct)
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(list.flatten([[a.class("aspect-ratio")], extra_class_attrs]), [
    h.div(
      [a.class("aspect-ratio-inner"), a.style("padding-bottom", pct_str <> "%")],
      [h.div([a.class("aspect-ratio-content")], [content])],
    ),
  ])
}

fn format_pct(f: Float) -> String {
  let whole = float.truncate(f)
  let frac = f -. int.to_float(whole)
  let frac2 = float.truncate(frac *. 100.0)
  case frac2 {
    0 -> int.to_string(whole)
    n ->
      int.to_string(whole)
      <> "."
      <> string.pad_start(int.to_string(int.absolute_value(n)), 2, "0")
  }
}

// --- Convenience shortcuts ---

/// Constrain `content` to the given width/height `ratio` (e.g. `16.0 /. 9.0`).
pub fn aspect_ratio(ratio: Float, content: Element(msg)) -> Element(msg) {
  new() |> view(ratio, content)
}
