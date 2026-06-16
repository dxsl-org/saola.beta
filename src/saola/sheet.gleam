//// Sheet (side panel) widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// sheet.sheet_simple(model.open, "Filters", body, CloseSheet)        // shortcut (right)
//// sheet.new()
//// |> sheet.side(sheet.Left)
//// |> sheet.view(model.open, "Menu", body, CloseSheet)
//// ```

import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type SheetSide {
  Top
  Bottom
  Left
  Right
}

/// Presentation options for a sheet. Public for record-update syntax. The
/// `open`/`title`/`content`/`on_close` are the required data (`view`).
pub type SheetConfig {
  SheetConfig(side: SheetSide, class: String)
}

/// Builder entry point. Defaults: Right side, no extra class.
pub fn new() -> SheetConfig {
  SheetConfig(side: Right, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SheetConfig {
  new()
}

/// Set the side the sheet slides in from (Top, Bottom, Left, Right — default).
pub fn side(config: SheetConfig, side: SheetSide) -> SheetConfig {
  SheetConfig(..config, side: side)
}

/// Append an extra CSS class on the sheet. Additive only.
pub fn add_class(config: SheetConfig, class: String) -> SheetConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SheetConfig(..config, class: merged)
}

/// Render the sheet (renders nothing while `open` is False).
pub fn view(
  config: SheetConfig,
  open: Bool,
  title: String,
  content: Element(msg),
  on_close: fn() -> msg,
) -> Element(msg) {
  case open {
    False -> h.text("")
    True -> {
      let side_class = case config.side {
        Top -> "sheet sheet-top"
        Bottom -> "sheet sheet-bottom"
        Left -> "sheet sheet-left"
        Right -> "sheet sheet-right"
      }
      let full_class = case config.class {
        "" -> side_class
        c -> side_class <> " " <> c
      }
      h.div([a.class("dialog-overlay"), a.attribute("aria-modal", "true")], [
        h.div(
          [
            a.class(full_class),
            a.role("dialog"),
            a.attribute("aria-labelledby", "sheet-title"),
          ],
          [
            h.div([a.class("sheet-header")], [
              h.h2([a.class("sheet-title"), a.id("sheet-title")], [
                h.text(title),
              ]),
              h.button(
                [
                  a.type_("button"),
                  a.class("btn btn-ghost btn-sm"),
                  a.attribute("aria-label", "Close"),
                  e.on_click(on_close()),
                ],
                [h.text("×")],
              ),
            ]),
            h.div([a.class("sheet-content")], [content]),
          ],
        ),
      ])
    }
  }
}

// --- Convenience shortcuts ---

pub fn sheet_simple(
  open: Bool,
  title: String,
  content: Element(msg),
  on_close: fn() -> msg,
) -> Element(msg) {
  new() |> view(open, title, content, on_close)
}
