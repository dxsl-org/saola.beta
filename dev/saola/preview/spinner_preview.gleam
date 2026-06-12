import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}
import saola/spinner

pub fn view() -> Element(Message) {
  doc_page.doc_page("Spinner", "A loading indicator.", [
    DocSection("demo", "Demo", [
      h.div([a.class("grid gap-8")], [
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("Sizes")]),
          h.div([a.class("flex items-center gap-4")], [
            spinner.spinner(spinner.Small, ""),
            spinner.spinner(spinner.Medium, ""),
            spinner.spinner(spinner.Large, ""),
          ]),
        ]),
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("Default (medium)")]),
          spinner.spinner_simple(),
        ]),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/spinner",
        "",
        "spinner.spinner_simple()",
        "spinner.spinner(spinner.Small, \"\")",
        "spinner.spinner(spinner.Large, \"extra-class\")",
      ]),
    ]),
  ])
}
