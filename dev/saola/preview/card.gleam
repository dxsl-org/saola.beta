import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/button
import saola/card
import saola/preview/model.{type Message, Home, OnRouteChange}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Cards",
    "Content containers with optional header and footer.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-6 mt-4")], [
          card.card_simple("Simple Card", [
            h.p([], [text("This is a card with just a title and some content.")]),
          ]),
          card.new()
            |> card.title("Card with Description")
            |> card.description(
              "A short description of what this card contains.",
            )
            |> card.view([h.p([], [text("Main content area goes here.")])]),
          card.new()
            |> card.title("Card with Footer")
            |> card.description("This card has a footer with an action button.")
            |> card.footer(button.button_primary(
              "Save changes",
              OnRouteChange(Home),
            ))
            |> card.view([h.p([], [text("Card body content.")])]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/card",
          "",
          "card.card_simple(\"Simple Card\", [",
          "  h.p([], [text(\"Content here.\")]),",
          "])",
          "",
          "card.new()",
          "|> card.title(\"Title\")",
          "|> card.description(\"Description.\")",
          "|> card.view([h.p([], [text(\"Body.\")])])",
        ]),
      ]),
    ],
  )
}
