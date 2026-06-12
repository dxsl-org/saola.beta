import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/button_group
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Button Group",
    "Groups related buttons together with fused borders.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Horizontal (default)")]),
            button_group.button_group_simple([
              h.button([a.type_("button"), a.class("btn btn-outline")], [
                text("Left"),
              ]),
              h.button([a.type_("button"), a.class("btn btn-outline")], [
                text("Center"),
              ]),
              h.button([a.type_("button"), a.class("btn btn-outline")], [
                text("Right"),
              ]),
            ]),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Vertical")]),
            button_group.button_group(
              [
                h.button([a.type_("button"), a.class("btn btn-outline")], [
                  text("Top"),
                ]),
                h.button([a.type_("button"), a.class("btn btn-outline")], [
                  text("Middle"),
                ]),
                h.button([a.type_("button"), a.class("btn btn-outline")], [
                  text("Bottom"),
                ]),
              ],
              button_group.ButtonGroupAttrs(
                orientation: button_group.Vertical,
                class: "",
              ),
            ),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("With primary button")]),
            button_group.button_group_simple([
              h.button([a.type_("button"), a.class("btn btn-outline")], [
                text("Cancel"),
              ]),
              h.button([a.type_("button"), a.class("btn btn-primary")], [
                text("Save"),
              ]),
            ]),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/button_group",
          "",
          "button_group.button_group_simple([",
          "  h.button([a.type_(\"button\"), a.class(\"btn btn-outline\")], [text(\"Left\")]),",
          "  h.button([a.type_(\"button\"), a.class(\"btn btn-outline\")], [text(\"Right\")]),",
          "])",
        ]),
      ]),
    ],
  )
}
