import gleam/option.{None, Some}
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/input_group
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Input Group",
    "Attach addons (icons, labels, buttons) to inputs.",
    [
      DocSection("prefix-text", "Prefix text", [
        h.div([a.class("grid gap-4 mt-4")], [
          input_group.input_group_simple(
            Some(h.span([], [text("https://")])),
            h.input([
              a.type_("text"),
              a.class("input input-group-control"),
              a.placeholder("example.com"),
            ]),
            None,
          ),
        ]),
      ]),
      DocSection("suffix-text", "Suffix text", [
        h.div([a.class("grid gap-4 mt-4")], [
          input_group.input_group_simple(
            None,
            h.input([
              a.type_("text"),
              a.class("input input-group-control"),
              a.placeholder("username"),
            ]),
            Some(h.span([], [text("@example.com")])),
          ),
        ]),
      ]),
      DocSection("prefix-icon", "Prefix icon", [
        h.div([a.class("grid gap-4 mt-4")], [
          input_group.input_group_simple(
            Some(h.span([a.attribute("aria-hidden", "true")], [text("$")])),
            h.input([
              a.type_("number"),
              a.class("input input-group-control"),
              a.placeholder("0.00"),
            ]),
            Some(h.span([a.attribute("aria-hidden", "true")], [text("USD")])),
          ),
        ]),
      ]),
      DocSection("invalid-state", "Invalid state", [
        h.div([a.class("grid gap-4 mt-4")], [
          input_group.input_group(
            Some(h.span([], [text("@")])),
            h.input([
              a.type_("text"),
              a.class("input input-group-control"),
              a.value("bad value"),
            ]),
            None,
            input_group.InputGroupAttrs(class: "", invalid: True),
          ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/input_group",
          "import gleam/option.{None, Some}",
          "",
          "input_group.input_group_simple(",
          "  Some(h.span([], [text(\"https://\")])),",
          "  h.input([a.type_(\"text\"), a.class(\"input input-group-control\")]),",
          "  None,",
          ")",
        ]),
      ]),
    ],
  )
}
