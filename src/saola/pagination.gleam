//// Pagination widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// pagination.pagination_simple(page, total, PageChanged)            // shortcut
//// pagination.new()
//// |> pagination.show_prev_next(False)
//// |> pagination.view(page, total, PageChanged)
//// ```

import gleam/int
import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// Presentation options for pagination. Public for record-update syntax.
/// `current_page`, `total_pages`, and `on_change` are required — passed to `view`.
pub type PaginationConfig {
  PaginationConfig(
    show_prev_next: Bool,
    prev_label: String,
    next_label: String,
    class: String,
  )
}

/// Builder entry point. Defaults: prev/next shown, "Previous"/"Next", no class.
pub fn new() -> PaginationConfig {
  PaginationConfig(
    show_prev_next: True,
    prev_label: "Previous",
    next_label: "Next",
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> PaginationConfig {
  new()
}

/// Toggle the previous/next buttons (default True).
pub fn show_prev_next(
  config: PaginationConfig,
  show: Bool,
) -> PaginationConfig {
  PaginationConfig(..config, show_prev_next: show)
}

/// Set the "previous" button label.
pub fn prev_label(config: PaginationConfig, label: String) -> PaginationConfig {
  PaginationConfig(..config, prev_label: label)
}

/// Set the "next" button label.
pub fn next_label(config: PaginationConfig, label: String) -> PaginationConfig {
  PaginationConfig(..config, next_label: label)
}

/// Append an extra CSS class on the `<nav>`. Additive only.
pub fn add_class(config: PaginationConfig, class: String) -> PaginationConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  PaginationConfig(..config, class: merged)
}

fn pages_list(from: Int, to: Int) -> List(Int) {
  case from > to {
    True -> []
    False -> [from, ..pages_list(from + 1, to)]
  }
}

/// Render the pagination nav. `on_change` receives the target page number.
pub fn view(
  config: PaginationConfig,
  current_page: Int,
  total_pages: Int,
  on_change: fn(Int) -> msg,
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let page_buttons =
    pages_list(1, total_pages)
    |> list.map(fn(page) {
      let is_current = page == current_page
      let aria_current_attrs = case is_current {
        True -> [a.attribute("aria-current", "page")]
        False -> []
      }
      h.button(
        list.flatten([
          [
            a.type_("button"),
            a.class(case is_current {
              True -> "btn btn-sm btn-primary"
              False -> "btn btn-sm btn-ghost"
            }),
            a.attribute("aria-label", "Page " <> int.to_string(page)),
          ],
          aria_current_attrs,
          [e.on_click(on_change(page))],
        ]),
        [h.text(int.to_string(page))],
      )
    })
  let prev_btn = case config.show_prev_next {
    False -> []
    True -> [
      h.button(
        {
          let disabled_attrs = case current_page <= 1 {
            True -> [a.disabled(True)]
            False -> []
          }
          list.flatten([
            [
              a.type_("button"),
              a.class("btn btn-sm btn-ghost"),
              a.attribute("aria-label", config.prev_label),
            ],
            disabled_attrs,
            [e.on_click(on_change(current_page - 1))],
          ])
        },
        [h.text(config.prev_label)],
      ),
    ]
  }
  let next_btn = case config.show_prev_next {
    False -> []
    True -> [
      h.button(
        {
          let disabled_attrs = case current_page >= total_pages {
            True -> [a.disabled(True)]
            False -> []
          }
          list.flatten([
            [
              a.type_("button"),
              a.class("btn btn-sm btn-ghost"),
              a.attribute("aria-label", config.next_label),
            ],
            disabled_attrs,
            [e.on_click(on_change(current_page + 1))],
          ])
        },
        [h.text(config.next_label)],
      ),
    ]
  }
  h.nav(
    list.flatten([
      [a.class("pagination")],
      extra_class_attrs,
      [a.attribute("aria-label", "Pagination"), a.role("navigation")],
    ]),
    list.flatten([prev_btn, page_buttons, next_btn]),
  )
}

// --- Convenience shortcuts ---

/// Pagination with default prev/next labels and styling.
pub fn pagination_simple(
  current_page: Int,
  total_pages: Int,
  on_change: fn(Int) -> msg,
) -> Element(msg) {
  new() |> view(current_page, total_pages, on_change)
}
