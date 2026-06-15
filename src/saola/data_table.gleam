//// Data table widget (sortable / filterable / paginated) — dual-style `Config`:
////
//// ```gleam
//// data_table.data_table_simple(columns, rows)                       // shortcut (static)
//// data_table.new()
//// |> data_table.show_filter(False)
//// |> data_table.view(columns, rows, state, OnSort, OnFilter, OnPage, OnSelect, row_id)
//// ```
//// State (sort/filter/page/selection) is consumer-owned via `DataTableState`;
//// use the `toggle_sort`/`set_filter`/`set_page`/`toggle_row` helpers in update.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/pagination

// ── Types ─────────────────────────────────────────────────────────────────────

pub type DataTableSortDir {
  Asc
  Desc
}

pub type DataTableState {
  DataTableState(
    sort_by: Option(String),
    sort_dir: DataTableSortDir,
    filter: String,
    page: Int,
    page_size: Int,
    selected: List(String),
  )
}

pub const default_state = DataTableState(
  sort_by: None,
  sort_dir: Asc,
  filter: "",
  page: 1,
  page_size: 10,
  selected: [],
)

pub type DataTableColumn(row, msg) {
  DataTableColumn(
    header: String,
    cell: fn(row) -> Element(msg),
    sort_key: Option(String),
  )
}

/// Presentation options for a data table. Public for record-update syntax. The
/// columns/rows/state/handlers/row_id are the required data, passed to `view`.
pub type DataTableConfig {
  DataTableConfig(show_filter: Bool, show_pagination: Bool, class: String)
}

/// Builder entry point. Defaults: filter + pagination shown, no extra class.
pub fn new() -> DataTableConfig {
  DataTableConfig(show_filter: True, show_pagination: True, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> DataTableConfig {
  new()
}

/// Toggle the filter toolbar (default shown).
pub fn show_filter(config: DataTableConfig, show: Bool) -> DataTableConfig {
  DataTableConfig(..config, show_filter: show)
}

/// Toggle the pagination footer (default shown).
pub fn show_pagination(config: DataTableConfig, show: Bool) -> DataTableConfig {
  DataTableConfig(..config, show_pagination: show)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: DataTableConfig, class: String) -> DataTableConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  DataTableConfig(..config, class: merged)
}

// ── State helpers (for consumer use) ─────────────────────────────────────────

pub fn toggle_sort(state: DataTableState, key: String) -> DataTableState {
  case state.sort_by {
    Some(k) if k == key ->
      DataTableState(..state, sort_dir: case state.sort_dir {
        Asc -> Desc
        Desc -> Asc
      })
    _ -> DataTableState(..state, sort_by: Some(key), sort_dir: Asc)
  }
}

pub fn set_filter(state: DataTableState, query: String) -> DataTableState {
  DataTableState(..state, filter: query, page: 1)
}

pub fn set_page(state: DataTableState, page: Int) -> DataTableState {
  DataTableState(..state, page: page)
}

pub fn toggle_row(state: DataTableState, id: String) -> DataTableState {
  let selected = case list.contains(state.selected, id) {
    True -> list.filter(state.selected, fn(s) { s != id })
    False -> [id, ..state.selected]
  }
  DataTableState(..state, selected: selected)
}

pub fn total_pages(total_rows: Int, page_size: Int) -> Int {
  case page_size {
    0 -> 1
    _ -> {
      let pages = total_rows / page_size
      let rem = total_rows - pages * page_size
      case rem {
        0 -> int.max(1, pages)
        _ -> pages + 1
      }
    }
  }
}

// ── Render helpers ────────────────────────────────────────────────────────────

fn render_sort_btn(
  header: String,
  sort_key: String,
  state: DataTableState,
  on_sort: fn(String) -> msg,
) -> Element(msg) {
  let arrow = case state.sort_by {
    Some(k) if k == sort_key ->
      case state.sort_dir {
        Asc -> " ↑"
        Desc -> " ↓"
      }
    _ -> ""
  }
  let active_class = case state.sort_by {
    Some(k) if k == sort_key -> " data-table-sort-active"
    _ -> ""
  }
  h.button(
    [
      a.type_("button"),
      a.class("data-table-sort-btn" <> active_class),
      e.on_click(on_sort(sort_key)),
    ],
    [h.text(header <> arrow)],
  )
}

fn render_header_row(
  columns: List(DataTableColumn(row, msg)),
  state: DataTableState,
  on_sort: fn(String) -> msg,
) -> Element(msg) {
  h.tr(
    [],
    list.map(columns, fn(col) {
      h.th([a.class("data-table-th")], [
        case col.sort_key {
          None -> h.text(col.header)
          Some(key) -> render_sort_btn(col.header, key, state, on_sort)
        },
      ])
    }),
  )
}

fn render_data_row(
  row: row,
  row_id: String,
  columns: List(DataTableColumn(row, msg)),
  selected: List(String),
  on_select: fn(List(String)) -> msg,
) -> Element(msg) {
  let is_selected = list.contains(selected, row_id)
  let row_class = case is_selected {
    True -> "data-table-row data-table-row-selected"
    False -> "data-table-row"
  }
  let new_selected = case is_selected {
    True -> list.filter(selected, fn(s) { s != row_id })
    False -> [row_id, ..selected]
  }
  h.tr(
    [a.class(row_class), e.on_click(on_select(new_selected))],
    list.map(columns, fn(col) {
      h.td([a.class("data-table-td")], [col.cell(row)])
    }),
  )
}

fn render_toolbar(filter: String, on_filter: fn(String) -> msg) -> Element(msg) {
  h.div([a.class("data-table-toolbar")], [
    h.input([
      a.type_("text"),
      a.class("input data-table-filter"),
      a.placeholder("Filter..."),
      a.value(filter),
      e.on_input(on_filter),
    ]),
  ])
}

fn render_footer(
  total_rows: Int,
  state: DataTableState,
  on_page: fn(Int) -> msg,
) -> Element(msg) {
  let pages = total_pages(total_rows, state.page_size)
  let start = { state.page - 1 } * state.page_size + 1
  let end_row = int.min(state.page * state.page_size, total_rows)
  let count_text =
    "Rows "
    <> int.to_string(start)
    <> "–"
    <> int.to_string(end_row)
    <> " of "
    <> int.to_string(total_rows)
  h.div([a.class("data-table-footer")], [
    h.span([a.class("data-table-row-count")], [h.text(count_text)]),
    pagination.pagination_simple(state.page, pages, on_page),
  ])
}

// ── Public API ────────────────────────────────────────────────────────────────

/// Render the data table. `state` is consumer-owned; the handlers fire on
/// sort/filter/page/row-select; `row_id` derives a stable id per row.
pub fn view(
  config: DataTableConfig,
  columns: List(DataTableColumn(row, msg)),
  rows: List(row),
  state: DataTableState,
  on_sort: fn(String) -> msg,
  on_filter: fn(String) -> msg,
  on_page: fn(Int) -> msg,
  on_select: fn(List(String)) -> msg,
  row_id: fn(row) -> String,
) -> Element(msg) {
  let total = list.length(rows)
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let paged_rows = case config.show_pagination {
    False -> rows
    True ->
      rows
      |> list.drop({ state.page - 1 } * state.page_size)
      |> list.take(state.page_size)
  }
  h.div(list.flatten([[a.class("data-table-root")], extra_class_attrs]), [
    case config.show_filter {
      False -> h.text("")
      True -> render_toolbar(state.filter, on_filter)
    },
    h.div([a.class("data-table-container")], [
      h.table([a.class("table data-table")], [
        h.thead([], [render_header_row(columns, state, on_sort)]),
        h.tbody(
          [],
          list.map(paged_rows, fn(row) {
            render_data_row(row, row_id(row), columns, state.selected, on_select)
          }),
        ),
      ]),
    ]),
    case config.show_pagination {
      False -> h.text("")
      True -> render_footer(total, state, on_page)
    },
  ])
}

// --- Convenience shortcuts ---

/// A static (non-interactive) table: headers + cells, no sort/filter/paginate.
pub fn data_table_simple(
  columns: List(DataTableColumn(row, msg)),
  rows: List(row),
) -> Element(msg) {
  h.div([a.class("data-table-root")], [
    h.div([a.class("data-table-container")], [
      h.table([a.class("table data-table")], [
        h.thead([], [
          h.tr(
            [],
            list.map(columns, fn(col) {
              h.th([a.class("data-table-th")], [h.text(col.header)])
            }),
          ),
        ]),
        h.tbody(
          [],
          list.map(rows, fn(row) {
            h.tr(
              [a.class("data-table-row")],
              list.map(columns, fn(col) {
                h.td([a.class("data-table-td")], [col.cell(row)])
              }),
            )
          }),
        ),
      ]),
    ]),
  ])
}
