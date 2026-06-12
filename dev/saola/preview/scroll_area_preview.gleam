import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}
import saola/scroll_area

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Scroll Area",
    "A scrollable container with custom scrollbar styling.",
    [
      DocSection("demo", "Demo", [
        scroll_area.scroll_area_simple(
          h.div([], [
            h.p([], [text("Line 1 — Scroll down to see more")]),
            h.p([], [text("Line 2")]),
            h.p([], [text("Line 3")]),
            h.p([], [text("Line 4")]),
            h.p([], [text("Line 5")]),
            h.p([], [text("Line 6")]),
            h.p([], [text("Line 7")]),
            h.p([], [text("Line 8")]),
            h.p([], [text("Line 9")]),
            h.p([], [text("Line 10")]),
          ]),
          "120px",
        ),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/scroll_area",
          "",
          "scroll_area.scroll_area_simple(",
          "  h.div([], [h.p([], [text(\"Content here\")])]),",
          "  \"200px\",",
          ")",
        ]),
      ]),
    ],
  )
}
