//// Star rating widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// rating.rating_readonly(4)                                          // shortcut
//// rating.rating_interactive(model.stars, RatingChanged)              // shortcut
//// rating.new()
//// |> rating.max(10)
//// |> rating.view(model.stars, rating.Interactive, Some(RatingChanged))
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type RatingMode {
  ReadOnly
  Interactive
}

/// Presentation options for a rating. Public for record-update syntax. The
/// `value`, `mode`, and `on_change` are the required data, passed to `view`.
pub type RatingConfig {
  RatingConfig(max: Int, class: String, aria_label: String)
}

/// Builder entry point. Defaults: max 5, no class, "Rating" aria label.
pub fn new() -> RatingConfig {
  RatingConfig(max: 5, class: "", aria_label: "Rating")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> RatingConfig {
  new()
}

/// Set the maximum rating (number of stars; default 5).
pub fn max(config: RatingConfig, max: Int) -> RatingConfig {
  RatingConfig(..config, max: max)
}

/// Set the accessible label (default "Rating").
pub fn aria_label(config: RatingConfig, aria_label: String) -> RatingConfig {
  RatingConfig(..config, aria_label: aria_label)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: RatingConfig, class: String) -> RatingConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  RatingConfig(..config, class: merged)
}

/// Render the rating. `on_change` is `None` in read-only mode; `Some(fn)` makes
/// the stars interactive.
pub fn view(
  config: RatingConfig,
  value: Int,
  mode: RatingMode,
  on_change: Option(fn(Int) -> msg),
) -> Element(msg) {
  let stars = range(1, config.max)
  let root_class = case config.class {
    "" -> "rating"
    c -> "rating " <> c
  }
  case mode {
    ReadOnly ->
      h.div(
        [
          a.class(root_class <> " rating-readonly"),
          a.role("img"),
          a.attribute(
            "aria-label",
            config.aria_label
              <> ": "
              <> int.to_string(value)
              <> " out of "
              <> int.to_string(config.max),
          ),
        ],
        list.map(stars, fn(n) {
          h.span(
            [
              a.class(case n <= value {
                True -> "rating-star rating-star-filled"
                False -> "rating-star"
              }),
              a.attribute("aria-hidden", "true"),
            ],
            [h.text("★")],
          )
        }),
      )
    Interactive ->
      h.div(
        [
          a.class(root_class),
          a.role("group"),
          a.attribute("aria-label", config.aria_label),
        ],
        list.map(stars, fn(n) {
          let click_attrs = case on_change {
            None -> []
            Some(f) -> [e.on_click(f(n))]
          }
          h.button(
            list.flatten([
              [
                a.type_("button"),
                a.class(case n <= value {
                  True -> "rating-star rating-star-filled"
                  False -> "rating-star"
                }),
                a.attribute(
                  "aria-label",
                  int.to_string(n) <> " out of " <> int.to_string(config.max),
                ),
              ],
              click_attrs,
            ]),
            [h.text("★")],
          )
        }),
      )
  }
}

// --- Convenience shortcuts ---

pub fn rating_readonly(value: Int) -> Element(msg) {
  new() |> view(value, ReadOnly, None)
}

pub fn rating_interactive(
  value: Int,
  on_change: fn(Int) -> msg,
) -> Element(msg) {
  new() |> view(value, Interactive, Some(on_change))
}

fn range(from: Int, to: Int) -> List(Int) {
  case from > to {
    True -> []
    False -> [from, ..range(from + 1, to)]
  }
}
