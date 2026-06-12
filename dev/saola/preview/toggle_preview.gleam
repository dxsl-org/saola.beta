import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/preview/model.{
  type Message, type Model, ToggleBoldChanged, ToggleItalicChanged,
}
import saola/preview/view/doc_page.{DocSection}
import saola/toggle

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page("Toggle", "A two-state button that can be on or off.", [
    DocSection("default", "Default", [
      h.div([a.class("flex gap-2 mt-4")], [
        toggle.toggle_simple(model.toggle_bold, "Bold", ToggleBoldChanged),
        toggle.toggle_simple(model.toggle_italic, "Italic", ToggleItalicChanged),
      ]),
    ]),
    DocSection("outline", "Outline variant", [
      h.div([a.class("flex gap-2 mt-4")], [
        toggle.toggle(
          model.toggle_bold,
          "Bold",
          ToggleBoldChanged,
          toggle.ToggleAttrs(..toggle.default_attrs, variant: toggle.Outline),
        ),
        toggle.toggle(
          model.toggle_italic,
          "Italic",
          ToggleItalicChanged,
          toggle.ToggleAttrs(..toggle.default_attrs, variant: toggle.Outline),
        ),
      ]),
    ]),
    DocSection("sizes", "Sizes", [
      h.div([a.class("flex gap-2 items-center mt-4")], [
        toggle.toggle(
          False,
          "Small",
          fn(_) { ToggleBoldChanged(model.toggle_bold) },
          toggle.ToggleAttrs(..toggle.default_attrs, size: toggle.Small),
        ),
        toggle.toggle(
          True,
          "Medium",
          fn(_) { ToggleBoldChanged(model.toggle_bold) },
          toggle.default_attrs,
        ),
        toggle.toggle(
          False,
          "Large",
          fn(_) { ToggleBoldChanged(model.toggle_bold) },
          toggle.ToggleAttrs(..toggle.default_attrs, size: toggle.Large),
        ),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/toggle",
        "",
        "// Simple",
        "toggle.toggle_simple(model.toggle_bold, \"Bold\", ToggleBoldChanged)",
        "",
        "// With variant/size",
        "toggle.toggle(",
        "  model.toggle_bold, \"Bold\", ToggleBoldChanged,",
        "  toggle.ToggleAttrs(..toggle.default_attrs, variant: toggle.Outline),",
        ")",
      ]),
    ]),
  ])
}
