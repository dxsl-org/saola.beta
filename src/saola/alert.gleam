//// Alert widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// alert.alert_default("A simple informational message.")          // shortcut
//// alert.alert_destructive("Error", "Something went wrong.")        // shortcut
//// // Builder
//// alert.new()
//// |> alert.variant(alert.Destructive)
//// |> alert.icon(lt.triangle_alert([]))
//// |> alert.view("Error", "Your session expired.")
//// ```

import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type AlertVariant {
  Default
  Destructive
}

/// Presentation options for an alert. Public (not opaque) for record-update.
/// `icon` appears as an SVG in the left column; required text (title,
/// description) lives in the `view` terminal.
pub type AlertConfig(msg) {
  AlertConfig(variant: AlertVariant, icon: Option(Element(msg)), class: String)
}

/// Builder entry point. Defaults: `Default` variant, no icon, no extra class.
pub fn new() -> AlertConfig(msg) {
  AlertConfig(variant: Default, icon: None, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> AlertConfig(msg) {
  new()
}

/// Set the variant (Default, Destructive).
pub fn variant(config: AlertConfig(msg), variant: AlertVariant) -> AlertConfig(msg) {
  AlertConfig(..config, variant: variant)
}

/// Set the leading icon (rendered as an SVG in the left column).
pub fn icon(config: AlertConfig(msg), icon: Element(msg)) -> AlertConfig(msg) {
  AlertConfig(..config, icon: Some(icon))
}

/// Append an extra CSS class after the variant class. Additive only.
pub fn add_class(config: AlertConfig(msg), class: String) -> AlertConfig(msg) {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  AlertConfig(..config, class: merged)
}

/// Render the alert. `title` maps to `<h2>` (omitted when empty);
/// `description` maps to `<section><p>` (omitted when empty).
pub fn view(
  config: AlertConfig(msg),
  title: String,
  description: String,
) -> Element(msg) {
  let base = case config.variant {
    Default -> "alert"
    Destructive -> "alert-destructive"
  }
  let css = case config.class {
    "" -> base
    extra -> base <> " " <> extra
  }
  let icon_el = case config.icon {
    None -> element.none()
    Some(i) -> i
  }
  let title_el = case title {
    "" -> element.none()
    t -> h.h2([], [h.text(t)])
  }
  let desc_el = case description {
    "" -> element.none()
    d -> h.section([], [h.p([], [h.text(d)])])
  }
  h.div([a.class(css), a.role("alert")], [icon_el, title_el, desc_el])
}

// --- Convenience shortcuts ---

pub fn alert_default(description: String) -> Element(msg) {
  new() |> view("", description)
}

pub fn alert_destructive(title: String, description: String) -> Element(msg) {
  new() |> variant(Destructive) |> view(title, description)
}
