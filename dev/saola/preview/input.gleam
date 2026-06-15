import gleam/option
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/checkbox
import saola/input
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}
import saola/textarea

fn checkbox_examples() -> List(Element(Message)) {
  [
    checkbox.checkbox_basic("Basic Checkbox"),
    checkbox.new()
      |> checkbox.help_text("This is a help text for the checkbox.")
      |> checkbox.view("Checkbox with help text", checkbox.default_check_status),
    checkbox.new()
      |> checkbox.add_class("custom-class")
      |> checkbox.help_text(
        "This checkbox uses composed attributes from default constants.",
      )
      |> checkbox.view(
        "Checkbox with composed attributes",
        checkbox.default_check_status,
      ),
    checkbox.new()
      |> checkbox.help_text(
        "This checkbox is initially checked using InitChecked(True).",
      )
      |> checkbox.view("Checkbox with InitChecked(True)", checkbox.InitChecked(True)),
    checkbox.new()
      |> checkbox.form_attr(checkbox.FormAttr("agree", checkbox.InitValue("yes")))
      |> checkbox.help_text("This checkbox uses InitValue for form submission.")
      |> checkbox.view("Checkbox with InitValue", checkbox.default_check_status),
  ]
}

fn input_examples() -> List(Element(Message)) {
  [
    input.input_text("Enter text...", fn(_) {
      model.OnRouteChange(model.Inputs)
    }),
    input.input_email("you@example.com", fn(_) {
      model.OnRouteChange(model.Inputs)
    }),
    input.input_password("Password", fn(_) { model.OnRouteChange(model.Inputs) }),
    input.new()
    |> input.type_(input.Number)
    |> input.id("qty")
    |> input.name("quantity")
    |> input.placeholder("0")
    |> input.view(option.None, option.None),
  ]
}

fn textarea_examples() -> List(Element(Message)) {
  [
    textarea.textarea_simple("Write something...", fn(_) {
      model.OnRouteChange(model.Inputs)
    }),
    textarea.new()
    |> textarea.name("bio")
    |> textarea.placeholder("Tell us about yourself")
    |> textarea.rows(4)
    |> textarea.view(option.None, option.None),
  ]
}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Inputs",
    "Showcase of text inputs, checkboxes, and textareas.",
    [
      DocSection("text-inputs", "Text Inputs", [
        h.div([a.class("grid gap-4 mt-4")], input_examples()),
      ]),
      DocSection("textareas", "Textareas", [
        h.div([a.class("grid gap-4 mt-4")], textarea_examples()),
      ]),
      DocSection("checkboxes", "Checkboxes", [
        h.div([a.class("grid gap-4 mt-4")], checkbox_examples()),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/input",
          "import saola/textarea",
          "import saola/checkbox",
          "",
          "input.input_text(\"Enter text...\", on_input_msg)",
          "input.input_email(\"you@example.com\", on_input_msg)",
          "input.input_password(\"Password\", on_input_msg)",
          "textarea.textarea_simple(\"Write something...\", on_input_msg)",
          "checkbox.checkbox_basic(\"Basic Checkbox\")",
        ]),
      ]),
    ],
  )
}
