import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/breadcrumb
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Breadcrumb",
    "A navigation trail showing the path to the current page.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [h.text("Default")]),
            breadcrumb.breadcrumb_simple([
              breadcrumb.BreadcrumbLink("Home", "/"),
              breadcrumb.BreadcrumbLink("Components", "/components"),
              breadcrumb.BreadcrumbPage("Breadcrumb"),
            ]),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [h.text("Custom separator")]),
            breadcrumb.breadcrumb(
              [
                breadcrumb.BreadcrumbLink("Docs", "/docs"),
                breadcrumb.BreadcrumbLink("API", "/docs/api"),
                breadcrumb.BreadcrumbPage("Breadcrumb"),
              ],
              breadcrumb.BreadcrumbAttrs(
                ..breadcrumb.default_attrs,
                separator: ">",
              ),
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/breadcrumb",
          "",
          "breadcrumb.breadcrumb_simple([",
          "  breadcrumb.BreadcrumbLink(\"Home\", \"/\"),",
          "  breadcrumb.BreadcrumbLink(\"Components\", \"/components\"),",
          "  breadcrumb.BreadcrumbPage(\"Breadcrumb\"),",
          "])",
        ]),
      ]),
    ],
  )
}
