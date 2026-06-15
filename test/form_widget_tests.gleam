import gleam/option.{None, Some}
import gleam/string
import lustre/element
import saola/checkbox
import saola/field
import saola/input
import saola/select
import saola/slider
import saola/switch
import saola/textarea

// --- input ---

pub fn input_text_type_renders_test() {
  let html =
    input.new()
    |> input.view(None, None)
    |> element.to_string
  assert string.contains(html, "type=\"text\"")
  assert string.contains(html, "class=\"input")
}

pub fn input_email_type_renders_test() {
  let html =
    input.input_email("you@example.com", fn(_) { Nil }) |> element.to_string
  assert string.contains(html, "type=\"email\"")
  assert string.contains(html, "placeholder=\"you@example.com\"")
}

pub fn input_password_type_renders_test() {
  let html = input.input_password("••••••", fn(_) { Nil }) |> element.to_string
  assert string.contains(html, "type=\"password\"")
}

pub fn input_with_id_and_name_renders_test() {
  let html =
    input.new()
    |> input.id("username")
    |> input.name("username")
    |> input.placeholder("Enter name")
    |> input.required(True)
    |> input.view(None, None)
    |> element.to_string
  assert string.contains(html, "id=\"username\"")
  assert string.contains(html, "name=\"username\"")
  assert string.contains(html, "placeholder=\"Enter name\"")
  assert string.contains(html, "required")
}

pub fn input_disabled_renders_test() {
  let html =
    input.new()
    |> input.disabled(True)
    |> input.view(None, None)
    |> element.to_string
  assert string.contains(html, "disabled")
}

pub fn input_no_id_omitted_test() {
  let html =
    input.new()
    |> input.view(None, None)
    |> element.to_string
  assert !string.contains(html, "id=")
  assert !string.contains(html, "name=")
}

// --- textarea ---

pub fn textarea_renders_test() {
  let html =
    textarea.new()
    |> textarea.id("msg")
    |> textarea.name("message")
    |> textarea.placeholder("Type here")
    |> textarea.rows(4)
    |> textarea.view(Some(textarea.SyncValue("Hello")), None)
    |> element.to_string
  assert string.contains(html, "<textarea")
  assert string.contains(html, "class=\"input")
  assert string.contains(html, "id=\"msg\"")
  assert string.contains(html, "name=\"message\"")
  assert string.contains(html, "placeholder=\"Type here\"")
  assert string.contains(html, "rows=\"4\"")
  assert string.contains(html, "Hello")
}

pub fn textarea_simple_renders_test() {
  let html =
    textarea.textarea_simple("Write here", fn(_) { Nil }) |> element.to_string
  assert string.contains(html, "<textarea")
  assert string.contains(html, "placeholder=\"Write here\"")
}

// --- checkbox ---

pub fn checkbox_basic_renders_test() {
  let html = checkbox.checkbox_basic("Accept terms") |> element.to_string
  assert string.contains(html, "type=\"checkbox\"")
  assert string.contains(html, "Accept terms")
}

pub fn checkbox_full_with_help_renders_test() {
  let html =
    checkbox.new()
    |> checkbox.form_attr(
      checkbox.FormAttr("newsletter", checkbox.InitValue("yes")),
    )
    |> checkbox.id("newsletter-chk")
    |> checkbox.help_text("Receive weekly updates.")
    |> checkbox.view("Subscribe", checkbox.InitChecked(True))
    |> element.to_string
  assert string.contains(html, "type=\"checkbox\"")
  assert string.contains(html, "id=\"newsletter-chk\"")
  assert string.contains(html, "Subscribe")
  assert string.contains(html, "Receive weekly updates.")
}

// --- select ---

pub fn select_simple_renders_test() {
  let html =
    select.select_simple(
      [
        select.SelectOption("a", "Option A"),
        select.SelectOption("b", "Option B"),
      ],
      fn(_) { Nil },
    )
    |> element.to_string
  assert string.contains(html, "<select")
  assert string.contains(html, "class=\"select")
  assert string.contains(html, "value=\"a\"")
  assert string.contains(html, "Option A")
  assert string.contains(html, "Option B")
}

pub fn select_disabled_option_renders_test() {
  let html =
    select.select_simple(
      [
        select.SelectOptionDisabled("none", "Choose..."),
        select.SelectOption("x", "X"),
      ],
      fn(_) { Nil },
    )
    |> element.to_string
  assert string.contains(html, "Choose...")
  assert string.contains(html, "disabled")
}

pub fn select_with_name_and_required_renders_test() {
  let html =
    select.new()
    |> select.id("colour")
    |> select.name("colour")
    |> select.required(True)
    |> select.view([select.SelectOption("red", "Red")], select.SyncValue("red"), fn(_) { Nil })
    |> element.to_string
  assert string.contains(html, "id=\"colour\"")
  assert string.contains(html, "name=\"colour\"")
  assert string.contains(html, "required")
}

// --- switch ---

pub fn switch_simple_renders_test() {
  let html =
    switch.switch_simple("Dark mode", True, fn(_) { Nil }) |> element.to_string
  assert string.contains(html, "type=\"checkbox\"")
  assert string.contains(html, "role=\"switch\"")
  assert string.contains(html, "Dark mode")
}

pub fn switch_full_with_name_renders_test() {
  let html =
    switch.new()
    |> switch.id("notif")
    |> switch.name("notifications")
    |> switch.view("Notifications", switch.InitChecked(False), fn(_) { Nil })
    |> element.to_string
  assert string.contains(html, "name=\"notifications\"")
  assert string.contains(html, "role=\"switch\"")
}

pub fn switch_disabled_renders_test() {
  let html =
    switch.new()
    |> switch.disabled(True)
    |> switch.view("Feature", switch.SyncChecked(False), fn(_) { Nil })
    |> element.to_string
  assert string.contains(html, "disabled")
}

// --- slider ---

pub fn slider_simple_renders_test() {
  let html = slider.slider_simple(50, fn(_) { Nil }) |> element.to_string
  assert string.contains(html, "type=\"range\"")
  assert string.contains(html, "class=\"input")
  assert string.contains(html, "min=\"0\"")
  assert string.contains(html, "max=\"100\"")
  assert string.contains(html, "step=\"1\"")
}

pub fn slider_custom_range_renders_test() {
  let html =
    slider.slider(
      slider.SyncValue(30),
      on_input: fn(_) { Nil },
      attrs: slider.SliderAttrs(
        min: 10,
        max: 60,
        step: 5,
        disabled: False,
        name: "volume",
        class: "",
        aria_label: "Volume",
      ),
    )
    |> element.to_string
  assert string.contains(html, "min=\"10\"")
  assert string.contains(html, "max=\"60\"")
  assert string.contains(html, "step=\"5\"")
  assert string.contains(html, "name=\"volume\"")
  assert string.contains(html, "aria-label=\"Volume\"")
}

// --- field ---

pub fn field_simple_renders_test() {
  let html =
    field.field_simple("Name", input.input_text("Enter name", fn(_) { Nil }))
    |> element.to_string
  assert string.contains(html, "class=\"field")
  assert string.contains(html, "Name")
  assert !string.contains(html, "data-invalid")
}

pub fn field_with_error_renders_test() {
  let html =
    field.field(
      field.FieldAttrs(
        label: "Email",
        description: "",
        error: "Invalid email address.",
        orientation: field.Vertical,
        required: False,
        hint: "",
      ),
      input.input_email("you@example.com", fn(_) { Nil }),
    )
    |> element.to_string
  assert string.contains(html, "data-invalid=\"true\"")
  assert string.contains(html, "Invalid email address.")
  assert string.contains(html, "role=\"alert\"")
}

pub fn field_with_description_renders_test() {
  let html =
    field.field(
      field.FieldAttrs(
        label: "Bio",
        description: "Write a short description.",
        error: "",
        orientation: field.Vertical,
        required: False,
        hint: "",
      ),
      textarea.textarea_simple("About you", fn(_) { Nil }),
    )
    |> element.to_string
  assert string.contains(html, "Write a short description.")
  assert !string.contains(html, "data-invalid")
}

pub fn field_horizontal_renders_test() {
  let html =
    field.field(
      field.FieldAttrs(
        label: "Active",
        description: "",
        error: "",
        orientation: field.Horizontal,
        required: False,
        hint: "",
      ),
      switch.switch_simple("Active", True, fn(_) { Nil }),
    )
    |> element.to_string
  assert string.contains(html, "data-orientation=\"horizontal\"")
}
