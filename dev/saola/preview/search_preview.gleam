import gleam/option.{None}
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, SearchQueryChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/search

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Search",
    "A search input with icon prefix and optional clear button.",
    [
      DocSection("simple", "Simple", [
        h.div([a.class("max-w-sm mt-4")], [
          search.search_simple(model.search_query, SearchQueryChanged),
        ]),
      ]),
      DocSection("clearable", "Clearable", [
        h.div([a.class("max-w-sm mt-4")], [
          search.search_clearable(
            model.search_query,
            SearchQueryChanged,
            SearchQueryChanged(""),
          ),
        ]),
      ]),
      DocSection("small", "Small size", [
        h.div([a.class("max-w-sm mt-4")], [
          search.new()
          |> search.size(search.Small)
          |> search.view(model.search_query, SearchQueryChanged, None),
        ]),
      ]),
      DocSection("disabled", "Disabled", [
        h.div([a.class("max-w-sm mt-4")], [
          search.new()
          |> search.disabled(True)
          |> search.view("", SearchQueryChanged, None),
        ]),
        h.div([a.class("mt-4")], [
          h.p([a.class("text-muted-foreground text-sm")], [
            text("Current value: \"" <> model.search_query <> "\""),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/search",
          "",
          "// Simple",
          "search.search_simple(model.search_query, SearchQueryChanged)",
          "",
          "// Clearable",
          "search.search_clearable(model.search_query, SearchQueryChanged, SearchQueryChanged(\"\"))",
          "",
          "// Disabled",
          "search.new()",
          "  |> search.disabled(True)",
          "  |> search.view(\"\", SearchQueryChanged, None)",
        ]),
      ]),
    ],
  )
}
