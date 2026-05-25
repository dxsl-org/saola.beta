import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type BreadcrumbItem(msg) {
  BreadcrumbLink(label: String, href: String)
  BreadcrumbPage(label: String)
  BreadcrumbCustom(content: Element(msg))
}

pub type BreadcrumbAttrs {
  BreadcrumbAttrs(
    separator: String,
    class: String,
  )
}

pub const default_attrs = BreadcrumbAttrs(
  separator: "/",
  class: "",
)

pub fn breadcrumb_full(
  items: List(BreadcrumbItem(msg)),
  attrs: BreadcrumbAttrs,
) -> Element(msg) {
  let extra_class = case attrs.class {
    "" -> a.none()
    c -> a.class(c)
  }
  let item_count = list.length(items)
  h.nav(
    [a.attribute("aria-label", "Breadcrumb"), extra_class],
    [
      h.ol(
        [a.class("breadcrumb")],
        list.index_map(items, fn(item, idx) {
          let is_last = idx == item_count - 1
          let content = case item {
            BreadcrumbLink(label, href) ->
              h.a([a.href(href), a.class("breadcrumb-link")], [h.text(label)])
            BreadcrumbPage(label) ->
              h.span(
                [
                  a.class("breadcrumb-page"),
                  a.attribute("aria-current", "page"),
                ],
                [h.text(label)],
              )
            BreadcrumbCustom(el) -> el
          }
          case is_last {
            True -> h.li([a.class("breadcrumb-item")], [content])
            False ->
              h.li(
                [a.class("breadcrumb-item")],
                [
                  content,
                  h.span(
                    [a.class("breadcrumb-separator"), a.attribute("aria-hidden", "true")],
                    [h.text(attrs.separator)],
                  ),
                ],
              )
          }
        }),
      ),
    ],
  )
}

pub fn breadcrumb_simple(items: List(BreadcrumbItem(msg))) -> Element(msg) {
  breadcrumb_full(items, default_attrs)
}
