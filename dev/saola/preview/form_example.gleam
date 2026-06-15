import gleam/list
import gleam/option.{Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/button
import saola/card
import saola/checkbox
import saola/input
import saola/label
import saola/preview/model.{
  type Message, type Model, FormEmailChanged, FormMessageChanged,
  FormNameChanged, FormSubmitted,
}
import saola/preview/view/doc_page.{DocSection}
import saola/textarea

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Form Example",
    "A small Saola form wired with Lustre messages.",
    [
      DocSection("demo", "Demo", [
        card.new()
        |> card.title("Contact form")
        |> card.description("A small Saola form wired with Lustre messages.")
        |> card.view([
          h.form([a.class("grid gap-4"), e.on_submit(FormSubmitted)], [
            field("name", "Name", [
              input.new()
              |> input.id("name")
              |> input.name("name")
              |> input.placeholder("Nguyen Van A")
              |> input.required(True)
              |> input.view(
                Some(input.SyncValue(model.form_name)),
                Some(FormNameChanged),
              ),
            ]),
            field("email", "Email", [
              input.new()
              |> input.type_(input.Email)
              |> input.id("email")
              |> input.name("email")
              |> input.placeholder("you@example.com")
              |> input.required(True)
              |> input.view(
                Some(input.SyncValue(model.form_email)),
                Some(FormEmailChanged),
              ),
            ]),
            field("message", "Message", [
              textarea.new()
              |> textarea.id("message")
              |> textarea.name("message")
              |> textarea.placeholder("How can we help?")
              |> textarea.rows(4)
              |> textarea.required(True)
              |> textarea.view(
                Some(textarea.SyncValue(model.form_message)),
                Some(FormMessageChanged),
              ),
            ]),
            checkbox.checkbox(
              "Send me product updates",
              checkbox.InitChecked(True),
              checkbox.ExtraAttrs(
                checkbox.FormAttr("updates", checkbox.InitValue("yes")),
                "updates",
                "",
              ),
              "This checkbox submits a normal form value.",
            ),
            button.button_submit("Send"),
          ]),
          submitted_summary(model.form_submitted_values),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/input",
          "import saola/textarea",
          "import saola/button",
          "import saola/checkbox",
          "import lustre/event as e",
          "",
          "h.form([a.class(\"grid gap-4\"), e.on_submit(FormSubmitted)], [",
          "  input.new()",
          "  |> input.id(\"name\")",
          "  |> input.name(\"name\")",
          "  |> input.placeholder(\"Nguyen Van A\")",
          "  |> input.required(True)",
          "  |> input.view(Some(input.SyncValue(model.form_name)), Some(FormNameChanged)),",
          "  button.button_submit(\"Send\"),",
          "])",
        ]),
      ]),
    ],
  )
}

fn field(
  id: String,
  title: String,
  children: List(Element(Message)),
) -> Element(Message) {
  h.div([a.class("grid gap-2")], [label.label_for(title, id), ..children])
}

fn submitted_summary(values: List(#(String, String))) -> Element(Message) {
  case values {
    [] ->
      h.p([a.class("text-muted-foreground text-sm")], [
        h.text("Submit the form to see posted values."),
      ])
    _ ->
      h.ul(
        [a.class("text-sm")],
        values
          |> list.map(fn(pair) {
            let #(name, value) = pair
            h.li([], [h.text(name <> ": " <> value)])
          }),
      )
  }
}
