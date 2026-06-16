//// Avatar widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// avatar.avatar_initials("JD")                       // shortcut (medium)
//// avatar.avatar_image("/me.jpg", "Jane")             // shortcut (medium)
//// avatar.new()
//// |> avatar.size(avatar.Large)
//// |> avatar.view(avatar.Initials("JD"))
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type AvatarSize {
  Small
  Medium
  Large
}

/// The avatar content (required — passed to `view`).
pub type AvatarSource {
  /// Render an <img> with src and alt.
  ImageSrc(src: String, alt: String)
  /// Render a <span> with fallback initials (e.g. "JD").
  Initials(text: String)
}

/// Presentation options for an avatar. Public for record-update syntax.
pub type AvatarConfig {
  AvatarConfig(size: AvatarSize, class: String)
}

/// Builder entry point. Defaults: Medium, no extra class.
pub fn new() -> AvatarConfig {
  AvatarConfig(size: Medium, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> AvatarConfig {
  new()
}

/// Set the size (Small, Medium — default, Large).
pub fn size(config: AvatarConfig, size: AvatarSize) -> AvatarConfig {
  AvatarConfig(..config, size: size)
}

/// Append an extra CSS class after the size class. Additive only.
pub fn add_class(config: AvatarConfig, class: String) -> AvatarConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  AvatarConfig(..config, class: merged)
}

fn size_class(size: AvatarSize) -> String {
  case size {
    Small -> "avatar-sm"
    Medium -> "avatar-md"
    Large -> "avatar-lg"
  }
}

/// Render the avatar from a source (image or initials).
pub fn view(config: AvatarConfig, source: AvatarSource) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let inner = case source {
    ImageSrc(src:, alt:) ->
      h.img([a.class("avatar-image"), a.src(src), a.alt(alt)])
    Initials(text:) ->
      h.span([a.class("avatar-fallback"), a.attribute("aria-hidden", "true")], [
        h.text(text),
      ])
  }
  h.span(
    list.flatten([
      [a.class("avatar " <> size_class(config.size))],
      extra_class_attrs,
    ]),
    [inner],
  )
}

// --- Convenience shortcuts ---

/// Avatar from an image URL.
pub fn avatar_image(src: String, alt: String) -> Element(msg) {
  new() |> view(ImageSrc(src, alt))
}

/// Avatar from initials text.
pub fn avatar_initials(text: String) -> Element(msg) {
  new() |> view(Initials(text))
}
