import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/pagination
import saola/preview/model.{type Message, type Model, PaginationChanged}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Pagination",
    "Navigation for splitting content across multiple pages.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [h.text("Default")]),
            pagination.pagination_simple(
              model.pagination_page,
              5,
              PaginationChanged,
            ),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [h.text("Without prev/next")]),
            pagination.pagination(
              model.pagination_page,
              5,
              PaginationChanged,
              pagination.PaginationAttrs(
                ..pagination.default_attrs,
                show_prev_next: False,
              ),
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/pagination",
          "",
          "// model.pagination_page : Int",
          "pagination.pagination_simple(",
          "  model.pagination_page,",
          "  5,",
          "  PaginationChanged,",
          ")",
        ]),
      ]),
    ],
  )
}
