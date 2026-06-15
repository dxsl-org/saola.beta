import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message, SelectChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/select

const fruit_options = [
  select.SelectOption("apple", "Apple"),
  select.SelectOption("banana", "Banana"),
  select.SelectOption("cherry", "Cherry"),
  select.SelectOption("durian", "Durian"),
  select.SelectOptionDisabled("elderberry", "Elderberry (unavailable)"),
]

const timezone_options = [
  select.SelectOption("utc", "UTC"),
  select.SelectOption("asia/ho_chi_minh", "Asia/Ho Chi Minh (UTC+7)"),
  select.SelectOption("asia/tokyo", "Asia/Tokyo (UTC+9)"),
  select.SelectOption("europe/london", "Europe/London (UTC+0)"),
  select.SelectOption("america/new_york", "America/New York (UTC-5)"),
]

pub fn view(fruit: String, timezone: String) -> Element(Message) {
  doc_page.doc_page(
    "Select",
    "A native select dropdown with styled appearance.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("mt-4 grid gap-6")], [
          h.div([a.class("grid gap-2")], [
            h.label([a.class("label")], [
              text("Favourite fruit: " <> fruit),
            ]),
            select.new()
            |> select.name("fruit")
            |> select.view(fruit_options, select.SyncValue(fruit), fn(v) {
              SelectChanged("fruit", v)
            }),
          ]),
          h.div([a.class("grid gap-2")], [
            h.label([a.class("label")], [text("Timezone")]),
            select.new()
            |> select.name("timezone")
            |> select.view(timezone_options, select.SyncValue(timezone), fn(v) {
              SelectChanged("timezone", v)
            }),
          ]),
          h.div([a.class("grid gap-2")], [
            h.label([a.class("label")], [text("Disabled")]),
            select.new()
            |> select.disabled(True)
            |> select.view(fruit_options, select.InitValue("banana"), fn(v) {
              SelectChanged("disabled", v)
            }),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/select",
          "",
          "select.new()",
          "|> select.name(\"fruit\")",
          "|> select.view(",
          "  [select.SelectOption(\"apple\", \"Apple\"), ...],",
          "  select.SyncValue(model.fruit),",
          "  fn(v) { SelectChanged(\"fruit\", v) },",
          ")",
          "",
          "// Disabled option",
          "select.SelectOptionDisabled(\"elderberry\", \"Elderberry (unavailable)\")",
        ]),
      ]),
    ],
  )
}
