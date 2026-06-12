import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}
import saola/separator

pub fn view() -> Element(Message) {
  doc_page.doc_page("Separator", "A visual divider between sections or items.", [
    DocSection("demo", "Demo", [
      h.div([a.class("mt-4 grid gap-6")], [
        h.div([], [
          h.p([], [text("Above the separator")]),
          separator.separator(),
          h.p([], [text("Below the separator")]),
        ]),
        h.div([a.class("flex items-center gap-4 h-8")], [
          h.span([], [text("Left")]),
          separator.separator_vertical(),
          h.span([], [text("Right")]),
        ]),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/separator",
        "",
        "// Horizontal",
        "separator.separator()",
        "",
        "// Vertical",
        "separator.separator_vertical()",
      ]),
    ]),
  ])
}
