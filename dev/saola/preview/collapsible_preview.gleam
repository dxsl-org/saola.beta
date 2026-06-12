import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/collapsible
import saola/preview/model.{type Message, type Model, CollapsibleToggled}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Collapsible",
    "An interactive component that expands and collapses content.",
    [
      DocSection("demo", "Demo", [
        collapsible.collapsible_simple(
          model.collapsible_open,
          case model.collapsible_open {
            True -> "Hide details ▲"
            False -> "Show details ▼"
          },
          h.div([a.style("padding", "0.5rem 0")], [
            h.p([], [
              text("This content is revealed when the trigger is clicked."),
            ]),
            h.p([], [text("It can contain any element.")]),
          ]),
          fn() { CollapsibleToggled },
        ),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/collapsible",
          "",
          "collapsible.collapsible_simple(",
          "  model.collapsible_open,",
          "  case model.collapsible_open { True -> \"Hide ▲\" False -> \"Show ▼\" },",
          "  h.div([], [text(\"Hidden content\")]),",
          "  fn() { CollapsibleToggled },",
          ")",
        ]),
      ]),
    ],
  )
}
