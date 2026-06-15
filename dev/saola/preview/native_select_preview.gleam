import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/native_select
import saola/preview/model.{type Message, type Model, NativeSelectChanged}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page("Native Select", "A styled native <select> element.", [
    DocSection("default", "Default", [
      h.div([a.class("grid gap-4 mt-4")], [
        native_select.native_select_simple(
          [
            native_select.NativeSelectOption("apple", "Apple"),
            native_select.NativeSelectOption("banana", "Banana"),
            native_select.NativeSelectOption("cherry", "Cherry"),
          ],
          model.native_select_value,
          "fruit",
          fn(v) { NativeSelectChanged(v) },
        ),
      ]),
    ]),
    DocSection("opt-groups", "With opt groups", [
      h.div([a.class("grid gap-4 mt-4")], [
        native_select.native_select_simple(
          [
            native_select.NativeSelectOptGroup("Fruits", [
              native_select.NativeSelectOption("apple", "Apple"),
              native_select.NativeSelectOption("banana", "Banana"),
            ]),
            native_select.NativeSelectOptGroup("Vegetables", [
              native_select.NativeSelectOption("carrot", "Carrot"),
              native_select.NativeSelectOption("potato", "Potato"),
            ]),
          ],
          model.native_select_value,
          "food",
          fn(v) { NativeSelectChanged(v) },
        ),
      ]),
    ]),
    DocSection("small", "Small", [
      h.div([a.class("grid gap-4 mt-4")], [
        native_select.new()
        |> native_select.size(native_select.Small)
        |> native_select.view(
          [
            native_select.NativeSelectOption("xs", "Extra Small"),
            native_select.NativeSelectOption("sm", "Small"),
            native_select.NativeSelectOption("md", "Medium"),
          ],
          "sm",
          "size",
          fn(v) { NativeSelectChanged(v) },
        ),
      ]),
    ]),
    DocSection("disabled", "Disabled", [
      h.div([a.class("grid gap-4 mt-4")], [
        native_select.new()
        |> native_select.disabled(True)
        |> native_select.view(
          [
            native_select.NativeSelectOption("a", "Option A"),
            native_select.NativeSelectOption("b", "Option B"),
          ],
          "a",
          "disabled-demo",
          fn(v) { NativeSelectChanged(v) },
        ),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/native_select",
        "",
        "native_select.native_select_simple(",
        "  [native_select.NativeSelectOption(\"apple\", \"Apple\"), ...],",
        "  model.native_select_value,",
        "  \"fruit\",",
        "  fn(v) { NativeSelectChanged(v) },",
        ")",
      ]),
    ]),
  ])
}
