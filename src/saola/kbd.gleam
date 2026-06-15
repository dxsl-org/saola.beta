//// Keyboard key widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// kbd.kbd("⌘K")                                   // shortcut
//// kbd.new() |> kbd.add_class("ml-1") |> kbd.view("Ctrl+S")
//// ```

import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Presentation options for a `<kbd>`. Public for record-update syntax.
pub type KbdConfig {
  KbdConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> KbdConfig {
  KbdConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> KbdConfig {
  new()
}

/// Append an extra CSS class after the `kbd` base class. Additive only.
pub fn add_class(config: KbdConfig, class: String) -> KbdConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  KbdConfig(class: merged)
}

/// Render the `<kbd>` element with the given key text.
pub fn view(config: KbdConfig, key: String) -> Element(msg) {
  let css = case config.class {
    "" -> "kbd"
    extra -> "kbd " <> extra
  }
  h.kbd([a.class(css)], [h.text(key)])
}

/// Shortcut — a keyboard key with default styling.
pub fn kbd(key: String) -> Element(msg) {
  new() |> view(key)
}
