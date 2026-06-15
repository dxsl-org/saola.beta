//// Badge widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// // Builder
//// badge.new() |> badge.variant(badge.Secondary) |> badge.view("Beta")
//// // Config (record update)
//// badge.view(
////   badge.BadgeConfig(..badge.default_config(), variant: badge.Outline),
////   "Draft",
//// )
//// // Shortcut
//// badge.badge_secondary("Beta")
//// ```

import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type BadgeVariant {
  Default
  Secondary
  Destructive
  Outline
}

/// Presentation options for a badge. Public (not opaque) so record-update
/// syntax works: `BadgeConfig(..default_config(), variant: Outline)`.
pub type BadgeConfig {
  BadgeConfig(variant: BadgeVariant, class: String)
}

/// Builder entry point. Defaults: `Default` variant, no extra class.
pub fn new() -> BadgeConfig {
  BadgeConfig(variant: Default, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> BadgeConfig {
  new()
}

/// Set the visual variant (Default, Secondary, Destructive, Outline).
pub fn variant(config: BadgeConfig, variant: BadgeVariant) -> BadgeConfig {
  BadgeConfig(..config, variant: variant)
}

/// Append an extra CSS class after the Basecoat variant class. Additive only.
pub fn add_class(config: BadgeConfig, class: String) -> BadgeConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  BadgeConfig(..config, class: merged)
}

/// Render the badge as a `<span>` with the given label.
pub fn view(config: BadgeConfig, label: String) -> Element(msg) {
  let base = case config.variant {
    Default -> "badge"
    Secondary -> "badge-secondary"
    Destructive -> "badge-destructive"
    Outline -> "badge-outline"
  }
  let css = case config.class {
    "" -> base
    extra -> base <> " " <> extra
  }
  h.span([a.class(css)], [h.text(label)])
}

// --- Convenience shortcuts ---

pub fn badge_default(label: String) -> Element(msg) {
  new() |> view(label)
}

pub fn badge_secondary(label: String) -> Element(msg) {
  new() |> variant(Secondary) |> view(label)
}

pub fn badge_destructive(label: String) -> Element(msg) {
  new() |> variant(Destructive) |> view(label)
}

pub fn badge_outline(label: String) -> Element(msg) {
  new() |> variant(Outline) |> view(label)
}
