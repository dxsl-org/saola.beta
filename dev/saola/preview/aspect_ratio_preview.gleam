import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/aspect_ratio
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Aspect Ratio",
    "Constrains content to a specific aspect ratio.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("16:9 video")]),
            h.div([a.style("max-width", "400px")], [
              aspect_ratio.aspect_ratio(
                16.0 /. 9.0,
                h.div(
                  [
                    a.style("width", "100%"),
                    a.style("height", "100%"),
                    a.style("background", "var(--color-muted, #e9ecef)"),
                    a.style("display", "flex"),
                    a.style("align-items", "center"),
                    a.style("justify-content", "center"),
                    a.style("border-radius", "0.5rem"),
                  ],
                  [text("16 / 9")],
                ),
              ),
            ]),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("1:1 square")]),
            h.div([a.style("max-width", "200px")], [
              aspect_ratio.aspect_ratio(
                1.0,
                h.div(
                  [
                    a.style("width", "100%"),
                    a.style("height", "100%"),
                    a.style("background", "var(--color-muted, #e9ecef)"),
                    a.style("display", "flex"),
                    a.style("align-items", "center"),
                    a.style("justify-content", "center"),
                    a.style("border-radius", "0.5rem"),
                  ],
                  [text("1 / 1")],
                ),
              ),
            ]),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/aspect_ratio",
          "",
          "aspect_ratio.aspect_ratio(",
          "  16.0 /. 9.0,",
          "  h.div([a.style(\"width\", \"100%\"), a.style(\"height\", \"100%\")], [",
          "    text(\"16 / 9\"),",
          "  ]),",
          ")",
        ]),
      ]),
    ],
  )
}
