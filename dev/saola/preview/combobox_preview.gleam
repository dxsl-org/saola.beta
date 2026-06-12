import gleam/int
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/component/combobox as cb
import saola/preview/model.{
  type Message, type Model, ComboboxQueryChanged, ComboboxSelected,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  let cb_items = [
    cb.Item(value: "apple", name: "Apple"),
    cb.Item(value: "banana", name: "Banana"),
    cb.Item(value: "cherry", name: "Cherry"),
    cb.Item(value: "durian", name: "Durian"),
    cb.Item(value: "elderberry", name: "Elderberry"),
  ]
  let selected_label = case model.combobox_value {
    None -> "None"
    Some(v) -> v
  }
  let filtered_count =
    list.filter(cb_items, fn(item) {
      case model.combobox_query {
        "" -> True
        query ->
          item.name
          |> string.lowercase
          |> string.contains(string.lowercase(query))
      }
    })
    |> list.length
  doc_page.doc_page(
    "Combobox",
    "Searchable select powered by the combo-box web component.",
    [
      DocSection("web-component", "Web Component (<combo-box>)", [
        h.div([a.class("grid gap-4 mt-4")], [
          h.p([a.class("text-muted-foreground text-sm")], [
            text(
              "Self-contained Lustre component. Selection and search state live inside the widget.",
            ),
          ]),
          cb.element([
            a.property("choices", json.array(cb_items, cb.encode_item)),
            cb.on_selected(ComboboxSelected),
            cb.on_text_input(ComboboxQueryChanged),
          ]),
          h.p([a.class("text-muted-foreground text-sm")], [
            text("Selected value: " <> selected_label),
          ]),
          h.p([a.class("text-muted-foreground text-sm")], [
            text(
              "Search query: "
              <> case model.combobox_query {
                "" -> "None"
                query -> query
              },
            ),
          ]),
          h.p([a.class("text-muted-foreground text-sm")], [
            text("Matching choices: " <> int.to_string(filtered_count)),
          ]),
        ]),
      ]),
      DocSection("preselected", "Preselected", [
        h.div([a.class("grid gap-4 mt-4")], [
          cb.element([
            a.property("choices", json.array(cb_items, cb.encode_item)),
            cb.preselect_value("cherry"),
            cb.on_selected(ComboboxSelected),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/component/combobox as cb",
          "import gleam/json",
          "",
          "let items = [cb.Item(value: \"apple\", name: \"Apple\"), ...]",
          "",
          "cb.element([",
          "  a.property(\"choices\", json.array(items, cb.encode_item)),",
          "  cb.on_selected(ComboboxSelected),",
          "  cb.on_text_input(ComboboxQueryChanged),",
          "])",
        ]),
      ]),
    ],
  )
}
