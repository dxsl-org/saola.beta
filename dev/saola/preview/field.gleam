import gleam/option
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/field
import saola/input
import saola/preview/model.{type Message, FormEmailChanged, FormNameChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/select
import saola/switch

pub fn view(name: String, email: String) -> Element(Message) {
  doc_page.doc_page(
    "Field",
    "A form field wrapper combining label, input, description, and error.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("mt-4 grid gap-6 max-w-md")], [
          field.field_simple(
            "Full name",
            input.input_text("Jane Doe", FormNameChanged),
          ),
          field.new()
            |> field.label("Email address")
            |> field.description("We'll never share your email.")
            |> field.view(
              input.new()
              |> input.type_(input.Email)
              |> input.placeholder("you@example.com")
              |> input.name("email")
              |> input.view(
                option.Some(input.SyncValue(email)),
                option.Some(fn(v) { FormEmailChanged(v) }),
              ),
            ),
          field.new()
            |> field.label("Username")
            |> field.error("Username is already taken.")
            |> field.view(
              input.new()
              |> input.placeholder("choose a username")
              |> input.name("username")
              |> input.view(
                option.Some(input.SyncValue(name)),
                option.Some(FormNameChanged),
              ),
            ),
          field.new()
            |> field.label("Country")
            |> field.description("Used to calculate shipping.")
            |> field.view(
              select.select_simple(
                [
                  select.SelectOption("vn", "Vietnam"),
                  select.SelectOption("jp", "Japan"),
                  select.SelectOption("us", "United States"),
                ],
                fn(_) { FormNameChanged("") },
              ),
            ),
          field.new()
            |> field.label("Marketing emails")
            |> field.description("Receive product updates and offers.")
            |> field.orientation(field.Horizontal)
            |> field.view(
              switch.switch_simple("", False, fn(_) { FormNameChanged("") }),
            ),
          field.new()
            |> field.label("Required field")
            |> field.required(True)
            |> field.hint("This field is mandatory.")
            |> field.view(input.input_text("", FormNameChanged)),
          field.new()
            |> field.label("With validation error")
            |> field.required(True)
            |> field.error("This value is invalid.")
            |> field.view(input.input_text("bad value", FormNameChanged)),
          // Fully accessible: field_id wires <label for>, the hint/error ids,
          // and the input's aria-describedby + aria-invalid all to one id.
          field.new()
            |> field.label("Accessible email")
            |> field.field_id("acc-email")
            |> field.hint("We'll send a confirmation link.")
            |> field.error("Enter a valid email.")
            |> field.view(
              input.new()
              |> input.type_(input.Email)
              |> input.id("acc-email")
              |> input.placeholder("you@example.com")
              |> input.aria_describedby("acc-email-hint acc-email-error")
              |> input.aria_invalid(True)
              |> input.view(
                option.Some(input.SyncValue(email)),
                option.Some(fn(v) { FormEmailChanged(v) }),
              ),
            ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/field",
          "import saola/input",
          "",
          "// Simple — label + input",
          "field.field_simple(\"Full name\", input.input_text(\"Jane Doe\", on_msg))",
          "",
          "// Full — with description, error, orientation",
          "field.new()",
          "|> field.label(\"Email\")",
          "|> field.description(\"We'll never share your email.\")",
          "|> field.view(input.new() |> input.type_(input.Email) |> input.view(value, on_msg))",
          "",
          "// Accessible — share one id so label/hint/error and the input link up",
          "field.new()",
          "|> field.label(\"Email\")",
          "|> field.field_id(\"email\")            // -> <label for>, #email-hint, #email-error",
          "|> field.hint(\"We'll send a link.\")",
          "|> field.error(\"Enter a valid email.\")",
          "|> field.view(",
          "  input.new()",
          "  |> input.id(\"email\")",
          "  |> input.aria_describedby(\"email-hint email-error\")",
          "  |> input.aria_invalid(True)",
          "  |> input.view(value, on_msg),",
          ")",
        ]),
      ]),
    ],
  )
}
