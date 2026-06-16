import gleam/dict
import gleam/option.{Some}
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import lustre/event as e
import saola/button
import saola/field
import saola/input
import saola/preview/model.{
  type Message, type Model, SignupConfirmChanged, SignupEmailChanged,
  SignupNameChanged, SignupPasswordChanged, SignupReset, SignupSubmitted,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Form Validation",
    "Real-time signup form powered by the formal library and saola/form bridge.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("mt-6 max-w-md")], [
          case model.signup_success {
            True -> success_banner(model)
            False -> signup_form(model)
          },
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/field",
          "import saola/input",
          "",
          "field.new()",
          "|> field.label(\"Full name\")",
          "|> field.required(True)",
          "|> field.error(err(\"name\"))",
          "|> field.view(",
          "  input.new()",
          "  |> input.name(\"name\")",
          "  |> input.placeholder(\"Nguyen Van A\")",
          "  |> input.view(Some(input.SyncValue(model.signup_name)), Some(SignupNameChanged)),",
          ")",
        ]),
      ]),
    ],
  )
}

fn signup_form(model: Model) -> Element(Message) {
  let err = fn(name) {
    dict.get(model.signup_errors, name) |> result_unwrap("")
  }

  h.form([a.class("grid gap-4"), e.on_submit(fn(_) { SignupSubmitted })], [
    field.new()
      |> field.label("Full name")
      |> field.required(True)
      |> field.error(err("name"))
      |> field.view(
        input.new()
        |> input.name("name")
        |> input.placeholder("Nguyen Van A")
        |> input.view(
          Some(input.SyncValue(model.signup_name)),
          Some(SignupNameChanged),
        ),
      ),
    field.new()
      |> field.label("Email address")
      |> field.required(True)
      |> field.error(err("email"))
      |> field.view(
        input.new()
        |> input.type_(input.Email)
        |> input.name("email")
        |> input.placeholder("you@example.com")
        |> input.view(
          Some(input.SyncValue(model.signup_email)),
          Some(SignupEmailChanged),
        ),
      ),
    field.new()
      |> field.label("Password")
      |> field.required(True)
      |> field.hint("At least 8 characters.")
      |> field.error(err("password"))
      |> field.view(
        input.new()
        |> input.type_(input.Password)
        |> input.name("password")
        |> input.view(
          Some(input.SyncValue(model.signup_password)),
          Some(SignupPasswordChanged),
        ),
      ),
    field.new()
      |> field.label("Confirm password")
      |> field.required(True)
      |> field.error(err("confirm"))
      |> field.view(
        input.new()
        |> input.type_(input.Password)
        |> input.name("confirm")
        |> input.view(
          Some(input.SyncValue(model.signup_confirm)),
          Some(SignupConfirmChanged),
        ),
      ),
    h.div([a.class("flex gap-2 pt-2")], [
      button.button_submit("Create account"),
    ]),
    case dict.size(model.signup_errors) > 0 {
      True ->
        h.p([a.class("text-destructive text-sm")], [
          text("Please fix the errors above and try again."),
        ])
      False -> element.none()
    },
  ])
}

fn success_banner(model: Model) -> Element(Message) {
  h.div([a.class("grid gap-4")], [
    h.div([a.class("alert")], [
      h.p([a.class("alert-title")], [text("Account created!")]),
      h.p([a.class("alert-description")], [
        text("Welcome, " <> model.signup_name <> ". You can now sign in."),
      ]),
    ]),
    button.button_outline("Start over", SignupReset),
  ])
}

fn result_unwrap(r: Result(a, e), default: a) -> a {
  case r {
    Ok(v) -> v
    Error(_) -> default
  }
}
