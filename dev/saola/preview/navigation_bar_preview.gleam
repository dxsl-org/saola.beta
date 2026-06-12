import gleam/option.{None, Some}
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/button
import saola/navigation_bar as nav_bar
import saola/preview/model.{type Message, StartedTrial}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Navigation Bar",
    "A responsive horizontal navigation bar with logo, links, and actions.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Default")]),
            h.div([a.class("border rounded-lg overflow-hidden")], [
              nav_bar.nav_bar_simple(
                Some(h.span([a.class("font-bold text-lg")], [text("Saola")])),
                [
                  nav_bar.nav_bar_link("/", "Home", True),
                  nav_bar.nav_bar_link("/docs", "Docs", False),
                  nav_bar.nav_bar_link("/blog", "Blog", False),
                ],
              ),
            ]),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("With actions")]),
            h.div([a.class("border rounded-lg overflow-hidden")], [
              nav_bar.nav_bar(
                nav_bar.Default,
                Some(h.span([a.class("font-bold text-lg")], [text("Saola")])),
                [
                  nav_bar.nav_bar_link("/", "Home", False),
                  nav_bar.nav_bar_link("/about", "About", False),
                ],
                [
                  button.button_outline("Sign in", StartedTrial),
                  button.button_primary("Get started", StartedTrial),
                ],
                nav_bar.default_attrs,
              ),
            ]),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("No logo")]),
            h.div([a.class("border rounded-lg overflow-hidden")], [
              nav_bar.nav_bar(
                nav_bar.Default,
                None,
                [
                  nav_bar.nav_bar_link("/", "Home", False),
                  nav_bar.nav_bar_link("/pricing", "Pricing", False),
                  nav_bar.nav_bar_link("/contact", "Contact", True),
                ],
                [],
                nav_bar.default_attrs,
              ),
            ]),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/navigation_bar as nav_bar",
          "import gleam/option.{Some, None}",
          "",
          "nav_bar.nav_bar_simple(",
          "  Some(logo_element),",
          "  [nav_bar.nav_bar_link(\"/\", \"Home\", True)]",
          ")",
        ]),
      ]),
    ],
  )
}
