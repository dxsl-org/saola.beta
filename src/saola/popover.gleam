//// Popover widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// popover.popover_simple(model.open, trigger, content, ClosePop)     // shortcut (bottom)
//// popover.new()
//// |> popover.side(popover.Right)
//// |> popover.view(model.open, trigger, content, ClosePop)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type PopoverSide {
  Top
  Bottom
  Left
  Right
}

/// Presentation options for a popover. Public for record-update syntax. The
/// `open`/`trigger`/`content`/`on_close` are the required data (`view`).
pub type PopoverConfig {
  PopoverConfig(side: PopoverSide, class: String)
}

/// Builder entry point. Defaults: Bottom side, no extra class.
pub fn new() -> PopoverConfig {
  PopoverConfig(side: Bottom, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> PopoverConfig {
  new()
}

/// Set the side the popover opens toward (Top, Bottom — default, Left, Right).
pub fn side(config: PopoverConfig, side: PopoverSide) -> PopoverConfig {
  PopoverConfig(..config, side: side)
}

/// Append an extra CSS class on the wrapper. Additive only.
pub fn add_class(config: PopoverConfig, class: String) -> PopoverConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  PopoverConfig(..config, class: merged)
}

/// Render the popover: `trigger` is always shown; `content` (with a close
/// button) shows while `open`.
pub fn view(
  config: PopoverConfig,
  open: Bool,
  trigger: Element(msg),
  content: Element(msg),
  on_close: fn() -> msg,
) -> Element(msg) {
  let side_attr = case config.side {
    Top -> a.attribute("data-side", "top")
    Bottom -> a.attribute("data-side", "bottom")
    Left -> a.attribute("data-side", "left")
    Right -> a.attribute("data-side", "right")
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div(list.flatten([[a.class("popover-wrapper")], extra_class_attrs]), [
    trigger,
    case open {
      False -> h.text("")
      True ->
        h.div(
          [
            a.class("popover"),
            side_attr,
            a.attribute("data-popover", ""),
            a.attribute("role", "dialog"),
          ],
          [
            content,
            h.button(
              [
                a.type_("button"),
                a.class("popover-close"),
                a.attribute("aria-label", "Close"),
                e.on_click(on_close()),
              ],
              [h.text("×")],
            ),
          ],
        )
    },
  ])
}

// --- Convenience shortcuts ---

pub fn popover_simple(
  open: Bool,
  trigger: Element(msg),
  content: Element(msg),
  on_close: fn() -> msg,
) -> Element(msg) {
  new() |> view(open, trigger, content, on_close)
}
