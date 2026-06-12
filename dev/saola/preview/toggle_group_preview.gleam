import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, ToggleGroupChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/toggle_group

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Toggle Group",
    "A group of toggle buttons where one or more can be active.",
    [
      DocSection("single-select", "Single select", [
        h.div([a.class("grid gap-4 mt-4")], [
          toggle_group.toggle_group_simple(
            [
              toggle_group.ToggleGroupItem("left", "Left"),
              toggle_group.ToggleGroupItem("center", "Center"),
              toggle_group.ToggleGroupItem("right", "Right"),
            ],
            model.toggle_group_selected,
            ToggleGroupChanged,
          ),
        ]),
      ]),
      DocSection("multi-select", "Multi select", [
        h.div([a.class("grid gap-4 mt-4")], [
          toggle_group.toggle_group(
            [
              toggle_group.ToggleGroupItem("bold", "B"),
              toggle_group.ToggleGroupItem("italic", "I"),
              toggle_group.ToggleGroupItem("underline", "U"),
              toggle_group.ToggleGroupItemDisabled("strike", "S"),
            ],
            model.toggle_group_selected,
            ToggleGroupChanged,
            toggle_group.MultiSelect,
            "",
          ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/toggle_group",
          "",
          "// Single select",
          "toggle_group.toggle_group_simple(",
          "  [toggle_group.ToggleGroupItem(\"left\", \"Left\"), ...],",
          "  model.toggle_group_selected,",
          "  ToggleGroupChanged,",
          ")",
          "",
          "// Multi select",
          "toggle_group.toggle_group([...], model.selected, ToggleGroupChanged, toggle_group.MultiSelect, \"\")",
        ]),
      ]),
    ],
  )
}
