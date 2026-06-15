//// Breadcrumb widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// breadcrumb.breadcrumb_simple(items)                // shortcut
//// breadcrumb.new()
//// |> breadcrumb.separator("›")
//// |> breadcrumb.view(items)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type BreadcrumbItem(msg) {
  BreadcrumbLink(label: String, href: String)
  BreadcrumbPage(label: String)
  BreadcrumbCustom(content: Element(msg))
}

/// Presentation options for a breadcrumb. Public for record-update syntax.
pub type BreadcrumbConfig {
  BreadcrumbConfig(separator: String, class: String)
}

/// Builder entry point. Defaults: `/` separator, no extra class.
pub fn new() -> BreadcrumbConfig {
  BreadcrumbConfig(separator: "/", class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> BreadcrumbConfig {
  new()
}

/// Set the separator glyph between items.
pub fn separator(config: BreadcrumbConfig, separator: String) -> BreadcrumbConfig {
  BreadcrumbConfig(..config, separator: separator)
}

/// Append an extra CSS class on the `<nav>`. Additive only.
pub fn add_class(config: BreadcrumbConfig, class: String) -> BreadcrumbConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  BreadcrumbConfig(..config, class: merged)
}

/// Render the breadcrumb trail from a list of items.
pub fn view(
  config: BreadcrumbConfig,
  items: List(BreadcrumbItem(msg)),
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let item_count = list.length(items)
  h.nav(
    list.flatten([[a.attribute("aria-label", "Breadcrumb")], extra_class_attrs]),
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
                [a.class("breadcrumb-page"), a.attribute("aria-current", "page")],
                [h.text(label)],
              )
            BreadcrumbCustom(el) -> el
          }
          case is_last {
            True -> h.li([a.class("breadcrumb-item")], [content])
            False ->
              h.li([a.class("breadcrumb-item")], [
                content,
                h.span(
                  [
                    a.class("breadcrumb-separator"),
                    a.attribute("aria-hidden", "true"),
                  ],
                  [h.text(config.separator)],
                ),
              ])
          }
        }),
      ),
    ],
  )
}

// --- Convenience shortcuts ---

/// Breadcrumb with default separator and styling.
pub fn breadcrumb_simple(items: List(BreadcrumbItem(msg))) -> Element(msg) {
  new() |> view(items)
}
