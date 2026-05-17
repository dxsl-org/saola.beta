# Form Validation Pattern

How to display validation errors, required markers, and hint text using Saola's `field` and `form` modules.

---

## Basic error display

```gleam
import saola/field

field.field(
  field.FieldAttrs(..field.default_attrs, label: "Email", error: "Invalid email address."),
  input.input_email("", EmailChanged),
)
```

The `error` string triggers `data-invalid="true"` on the wrapper and a `<p role="alert">` below the input.

---

## Required marker

```gleam
field.field(
  field.FieldAttrs(..field.default_attrs, label: "Full name", required: True),
  input.input_text("", NameChanged),
)
```

Renders `aria-required="true"` on the wrapper and a red `*` span inside the label.

---

## Hint text

```gleam
field.field(
  field.FieldAttrs(
    ..field.default_attrs,
    label: "Password",
    hint: "At least 8 characters, one number.",
  ),
  input.input_password("", PasswordChanged),
)
```

Renders `<p class="field-hint">` between the input and any error message.

---

## Wiring `formal` library results

Add `formal` to `gleam.toml`:
```toml
formal = ">= 1.0.0 and < 2.0.0"
```

Then use the `saola/form` bridge to map validation results directly onto `FieldAttrs`:

```gleam
import formal/form as f
import saola/field
import saola/form

// In your update function:
fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    FormSubmitted -> {
      let result = f.new(model.email_raw) |> f.field("email", f.string)
      let email_attrs = form.field_attrs_from_result(result, field.default_attrs)
      #(Model(..model, email_attrs: email_attrs), effect.none())
    }
    ...
  }
}

// In your view function:
field.field(model.email_attrs, input.input_email(model.email_raw, EmailChanged))
```

`field_attrs_from_result(Ok(_), attrs)` clears any existing error.
`field_attrs_from_result(Error(msg), attrs)` sets `attrs.error` to `msg`.

---

## Default attrs shortcut

Use `field.default_attrs` as the base and override only the fields you need:

```gleam
field.FieldAttrs(..field.default_attrs, label: "Username", required: True, hint: "3-20 characters.")
```

All fields not listed inherit their defaults: `error: ""`, `description: ""`, `orientation: Vertical`.
