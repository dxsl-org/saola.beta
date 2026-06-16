//// Table widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// table.table(["Name", "Email"], [["Alice", "a@x.io"]])             // string-only shortcut
//// table.table_simple(headers, rows)                                  // typed-cell shortcut
//// table.new()
//// |> table.caption("Monthly data")
//// |> table.view(headers, rows)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// A table cell can hold plain text or any element (badge, button, etc.).
pub type TableCell(msg) {
  TextCell(String)
  ElementCell(Element(msg))
}

/// A table row — an ordered list of cells, one per column.
pub type TableRow(msg) {
  TableRow(cells: List(TableCell(msg)))
}

/// Presentation options for a table. Public for record-update syntax. The
/// `headers` and `rows` are the required data, passed to `view`.
pub type TableConfig {
  TableConfig(caption: String, class: String)
}

/// Builder entry point. Defaults: no caption, no extra class.
pub fn new() -> TableConfig {
  TableConfig(caption: "", class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> TableConfig {
  new()
}

/// Set the `<caption>` text (omitted when empty).
pub fn caption(config: TableConfig, caption: String) -> TableConfig {
  TableConfig(..config, caption: caption)
}

/// Append an extra CSS class on the `<table>`. Additive only.
pub fn add_class(config: TableConfig, class: String) -> TableConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  TableConfig(..config, class: merged)
}

fn render_cell(cell: TableCell(msg)) -> Element(msg) {
  case cell {
    TextCell(text) -> h.td([], [h.text(text)])
    ElementCell(el) -> h.td([], [el])
  }
}

fn render_row(row: TableRow(msg)) -> Element(msg) {
  h.tr([], row.cells |> list.map(render_cell))
}

/// Render the table from headers and typed rows.
pub fn view(
  config: TableConfig,
  headers: List(String),
  rows: List(TableRow(msg)),
) -> Element(msg) {
  let caption_el = case config.caption {
    "" -> element.none()
    c -> h.caption([], [h.text(c)])
  }
  let header_row =
    h.tr([], headers |> list.map(fn(h_) { h.th([a.scope("col")], [h.text(h_)]) }))
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.div([a.class("overflow-auto")], [
    h.table(list.flatten([[a.class("table")], extra_class_attrs]), [
      caption_el,
      h.thead([], [header_row]),
      h.tbody([], rows |> list.map(render_row)),
    ]),
  ])
}

// --- Convenience shortcuts ---

/// Typed-cell table with default styling.
pub fn table_simple(
  headers headers: List(String),
  rows rows: List(TableRow(msg)),
) -> Element(msg) {
  new() |> view(headers, rows)
}

/// Render a simple string-only table.
pub fn table(headers: List(String), rows: List(List(String))) -> Element(msg) {
  new()
  |> view(
    headers,
    rows |> list.map(fn(cells) { TableRow(cells |> list.map(TextCell)) }),
  )
}
