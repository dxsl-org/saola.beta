import gleam/list
import gleam/option.{Some}
import lustre/attribute as a
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/button
import saola/card
import saola/checkbox
import saola/input
import saola/label
import saola/textarea

pub type Model {
  Model(
    name: String,
    email: String,
    message: String,
    submitted_values: List(#(String, String)),
  )
}

pub type Msg {
  NameChanged(String)
  EmailChanged(String)
  MessageChanged(String)
  Submitted(List(#(String, String)))
}

pub fn init(_args) {
  #(
    Model(name: "", email: "", message: "", submitted_values: []),
    effect.none(),
  )
}

pub fn update(model: Model, msg: Msg) {
  case msg {
    NameChanged(name) -> #(Model(..model, name: name), effect.none())
    EmailChanged(email) -> #(Model(..model, email: email), effect.none())
    MessageChanged(message) -> #(
      Model(..model, message: message),
      effect.none(),
    )
    Submitted(values) -> #(
      Model(..model, submitted_values: values),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  card.new()
  |> card.title("Contact form")
  |> card.description("A small Saola form wired with Lustre messages.")
  |> card.view([
    h.form([a.class("grid gap-4"), e.on_submit(Submitted)], [
      field("name", "Name", [
        input.new()
        |> input.id("name")
        |> input.name("name")
        |> input.placeholder("Nguyen Van A")
        |> input.required(True)
        |> input.view(Some(input.SyncValue(model.name)), Some(NameChanged)),
      ]),
      field("email", "Email", [
        input.new()
        |> input.type_(input.Email)
        |> input.id("email")
        |> input.name("email")
        |> input.placeholder("you@example.com")
        |> input.required(True)
        |> input.view(Some(input.SyncValue(model.email)), Some(EmailChanged)),
      ]),
      field("message", "Message", [
        textarea.new()
        |> textarea.id("message")
        |> textarea.name("message")
        |> textarea.placeholder("How can we help?")
        |> textarea.rows(4)
        |> textarea.required(True)
        |> textarea.view(
          Some(textarea.SyncValue(model.message)),
          Some(MessageChanged),
        ),
      ]),
      checkbox.new()
        |> checkbox.form_attr(checkbox.FormAttr(
          "updates",
          checkbox.InitValue("yes"),
        ))
        |> checkbox.id("updates")
        |> checkbox.help_text("This checkbox submits a normal form value.")
        |> checkbox.view("Send me product updates", checkbox.InitChecked(True)),
      button.button_submit("Send"),
    ]),
    submitted_summary(model.submitted_values),
  ])
}

fn field(
  id: String,
  title: String,
  children: List(Element(Msg)),
) -> Element(Msg) {
  h.div([a.class("grid gap-2")], [label.label_for(title, id), ..children])
}

fn submitted_summary(values: List(#(String, String))) -> Element(Msg) {
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
