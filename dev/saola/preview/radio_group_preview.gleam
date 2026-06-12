import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, ToggleBoldChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/radio_group

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Radio Group",
    "A set of checkable buttons where only one can be checked at a time.",
    [
      DocSection("vertical", "Vertical (default)", [
        h.div([a.class("grid gap-4 mt-4")], [
          radio_group.radio_group_simple(
            options: [
              radio_group.RadioOption("light", "Light"),
              radio_group.RadioOption("dark", "Dark"),
              radio_group.RadioOption("system", "System"),
            ],
            value: model.toggle_bold
              |> fn(b) {
                case b {
                  True -> "dark"
                  False -> "light"
                }
              },
            name: "theme",
            on_change: fn(v) { ToggleBoldChanged(v == "dark") },
          ),
        ]),
      ]),
      DocSection("horizontal", "Horizontal", [
        h.div([a.class("grid gap-4 mt-4")], [
          radio_group.radio_group(
            [
              radio_group.RadioOption("xs", "XS"),
              radio_group.RadioOption("sm", "SM"),
              radio_group.RadioOption("md", "MD"),
              radio_group.RadioOption("lg", "LG"),
              radio_group.RadioOptionDisabled("xl", "XL"),
            ],
            "md",
            fn(_) { ToggleBoldChanged(model.toggle_bold) },
            radio_group.RadioGroupAttrs(
              ..radio_group.default_attrs,
              orientation: radio_group.Horizontal,
              name: "size",
            ),
          ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/radio_group",
          "",
          "radio_group.radio_group_simple(",
          "  options: [",
          "    radio_group.RadioOption(\"light\", \"Light\"),",
          "    radio_group.RadioOption(\"dark\", \"Dark\"),",
          "  ],",
          "  value: model.theme,",
          "  name: \"theme\",",
          "  on_change: fn(v) { ThemeChanged(v) },",
          ")",
        ]),
      ]),
    ],
  )
}
