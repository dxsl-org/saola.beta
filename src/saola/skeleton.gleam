//// Skeleton loading-placeholder widget — dual-style `Config`:
////
//// ```gleam
//// skeleton.skeleton_text()                          // shortcut
//// skeleton.skeleton("w-48 h-4")                      // shortcut with shape class
//// skeleton.new() |> skeleton.add_class("skeleton-circle") |> skeleton.view()
//// ```
//// `class` controls shape/size — add `skeleton-text`, `skeleton-circle`, or any
//// sizing utility.

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Presentation options for a skeleton. Public for record-update syntax.
pub type SkeletonConfig {
  SkeletonConfig(class: String)
}

/// Builder entry point. Default: block skeleton, no shape class.
pub fn new() -> SkeletonConfig {
  SkeletonConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SkeletonConfig {
  new()
}

/// Append a shape/size class after the `skeleton` base class. Additive only.
pub fn add_class(config: SkeletonConfig, class: String) -> SkeletonConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SkeletonConfig(class: merged)
}

/// Render the skeleton placeholder.
pub fn view(config: SkeletonConfig) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(
    list.flatten([
      [
        a.class("skeleton"),
        a.role("status"),
        a.attribute("aria-busy", "true"),
        a.attribute("aria-live", "polite"),
      ],
      extra_class_attrs,
    ]),
    [h.span([a.attribute("aria-hidden", "true")], [])],
  )
}

// --- Convenience shortcuts ---

/// Skeleton with a shape/size class (e.g. `"w-48 h-4"`).
pub fn skeleton(class: String) -> Element(msg) {
  new() |> add_class(class) |> view()
}

/// A full-width skeleton line (for text placeholders).
pub fn skeleton_text() -> Element(msg) {
  new() |> add_class("skeleton-text") |> view()
}

/// A circular skeleton (for avatar placeholders).
pub fn skeleton_circle() -> Element(msg) {
  new() |> add_class("skeleton-circle") |> view()
}
