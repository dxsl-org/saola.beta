import gleam/int
import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type PaginationAttrs {
  PaginationAttrs(
    show_prev_next: Bool,
    prev_label: String,
    next_label: String,
    class: String,
  )
}

pub const default_attrs = PaginationAttrs(
  show_prev_next: True,
  prev_label: "Previous",
  next_label: "Next",
  class: "",
)

fn pages_list(from: Int, to: Int) -> List(Int) {
  case from > to {
    True -> []
    False -> [from, ..pages_list(from + 1, to)]
  }
}

pub fn pagination(
  current_page: Int,
  total_pages: Int,
  on_change: fn(Int) -> msg,
  attrs: PaginationAttrs,
) -> Element(msg) {
  let extra_class_attrs = case attrs.class {
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
  let prev_btn = case attrs.show_prev_next {
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
              a.attribute("aria-label", attrs.prev_label),
            ],
            disabled_attrs,
            [e.on_click(on_change(current_page - 1))],
          ])
        },
        [h.text(attrs.prev_label)],
      ),
    ]
  }
  let next_btn = case attrs.show_prev_next {
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
              a.attribute("aria-label", attrs.next_label),
            ],
            disabled_attrs,
            [e.on_click(on_change(current_page + 1))],
          ])
        },
        [h.text(attrs.next_label)],
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

pub fn pagination_simple(
  current_page: Int,
  total_pages: Int,
  on_change: fn(Int) -> msg,
) -> Element(msg) {
  pagination(current_page, total_pages, on_change, default_attrs)
}
