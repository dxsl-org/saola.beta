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
        toggle.new()
        |> toggle.variant(toggle.Outline)
        |> toggle.view(model.toggle_bold, "Bold", ToggleBoldChanged),
        toggle.new()
        |> toggle.variant(toggle.Outline)
        |> toggle.view(model.toggle_italic, "Italic", ToggleItalicChanged),
      ]),
    ]),
    DocSection("sizes", "Sizes", [
      h.div([a.class("flex gap-2 items-center mt-4")], [
        toggle.new()
        |> toggle.size(toggle.Small)
        |> toggle.view(False, "Small", fn(_) { ToggleBoldChanged(model.toggle_bold) }),
        toggle.new()
        |> toggle.view(True, "Medium", fn(_) { ToggleBoldChanged(model.toggle_bold) }),
        toggle.new()
        |> toggle.size(toggle.Large)
        |> toggle.view(False, "Large", fn(_) { ToggleBoldChanged(model.toggle_bold) }),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/toggle",
        "",
        "// Simple",
        "toggle.toggle_simple(model.toggle_bold, \"Bold\", ToggleBoldChanged)",
        "",
        "// With variant",
        "toggle.new()",
        "|> toggle.variant(toggle.Outline)",
        "|> toggle.view(model.toggle_bold, \"Bold\", ToggleBoldChanged)",
        "",
        "// With size",
        "toggle.new()",
        "|> toggle.size(toggle.Small)",
        "|> toggle.view(model.toggle_bold, \"Bold\", ToggleBoldChanged)",
      ]),
    ]),
  ])
}
