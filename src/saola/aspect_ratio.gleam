import gleam/float
import gleam/int
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Render content inside a box that maintains the given aspect ratio.
/// `ratio` is width/height, e.g. 16.0 /. 9.0 for widescreen.
pub fn aspect_ratio(ratio: Float, content: Element(msg)) -> Element(msg) {
  let pct = 1.0 /. ratio *. 100.0
  let pct_str = format_pct(pct)
  h.div(
    [a.class("aspect-ratio")],
    [
      h.div(
        [
          a.class("aspect-ratio-inner"),
          a.style("padding-bottom", pct_str <> "%"),
        ],
        [h.div([a.class("aspect-ratio-content")], [content])],
      ),
    ],
  )
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
