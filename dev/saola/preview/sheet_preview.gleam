import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import lustre/event as e
import saola/preview/model.{type Message, type Model, SheetClosed, SheetOpened}
import saola/preview/view/doc_page.{DocSection}
import saola/sheet

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Sheet",
    "A panel that slides in from the edge of the screen.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Right sheet (default)")]),
            h.button(
              [
                a.type_("button"),
                a.class("btn btn-outline"),
                e.on_click(SheetOpened),
              ],
              [text("Open sheet")],
            ),
            sheet.sheet_simple(
              model.sheet_open,
              "Sheet title",
              h.div([], [
                h.p([], [text("Sheet content goes here.")]),
                h.p([], [text("It slides in from the right edge.")]),
              ]),
              fn() { SheetClosed },
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/sheet",
          "",
          "// model.sheet_open : Bool",
          "sheet.sheet_simple(",
          "  model.sheet_open,",
          "  \"Sheet title\",",
          "  h.div([], [text(\"Content\")]),",
          "  fn() { SheetClosed },",
          ")",
        ]),
      ]),
    ],
  )
}
