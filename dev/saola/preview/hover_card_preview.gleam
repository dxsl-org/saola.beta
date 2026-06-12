import gleam/dynamic/decode
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import lustre/event as e
import saola/hover_card
import saola/preview/model.{
  type Message, type Model, HoverCardClosed, HoverCardOpened,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Hover Card",
    "A card revealed when hovering a trigger element.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Default")]),
            hover_card.hover_card_simple(
              model.hover_card_open,
              h.a(
                [
                  a.href("#"),
                  a.class("breadcrumb-link"),
                  e.on("mouseenter", decode.success(HoverCardOpened)),
                  e.on("mouseleave", decode.success(HoverCardClosed)),
                ],
                [text("@saola")],
              ),
              h.div([], [
                h.p([a.style("font-weight", "600")], [text("Saola UI")]),
                h.p([a.style("font-size", "0.875rem")], [
                  text("A typed, stateless Lustre component library."),
                ]),
              ]),
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/hover_card",
          "",
          "// model.hover_card_open : Bool",
          "hover_card.hover_card_simple(",
          "  model.hover_card_open,",
          "  trigger_element,",
          "  card_content_element,",
          ")",
        ]),
      ]),
    ],
  )
}
