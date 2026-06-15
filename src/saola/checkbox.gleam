//// Checkbox widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// checkbox.checkbox_basic("Accept terms")                            // shortcut
//// checkbox.new()
//// |> checkbox.form_attr(checkbox.FormAttr("tnc", checkbox.InitValue("yes")))
//// |> checkbox.help_text("Required to continue")
//// |> checkbox.view("Accept terms and conditions", checkbox.InitChecked(False))
//// ```

import gleam/result

import lustre/attribute as a
import lustre/element/html as h
import typeid

pub const class_input = "input"

pub const class_label = "label"

pub type CheckStatus {
  /// Seeds the checked state once (Lustre `default_checked`). Use with `formal`.
  InitChecked(Bool)
  /// Kept in sync with the app model (Lustre `checked`).
  SyncChecked(Bool)
}

pub type CheckboxValue {
  /// Seeds the value once (Lustre `default_value`). Use with `formal`.
  InitValue(String)
  /// Kept in sync with the app model (Lustre `value`).
  SyncValue(String)
}

/// Form binding for a checkbox (its `name` + submitted value).
pub type FormAttr {
  FormAttr(name: String, value: CheckboxValue)
}

/// Presentation/form options for a checkbox. Public for record-update syntax.
/// The `label` and `status` are required data, passed to `view`.
pub type CheckboxConfig {
  CheckboxConfig(
    form_attr: FormAttr,
    id: String,
    help_text: String,
    class: String,
  )
}

pub const default_check_status = InitChecked(False)

pub const default_value = InitValue("on")

pub const default_form_attr = FormAttr("", default_value)

/// Builder entry point. Defaults: no form binding, auto id, no help text/class.
pub fn new() -> CheckboxConfig {
  CheckboxConfig(form_attr: default_form_attr, id: "", help_text: "", class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> CheckboxConfig {
  new()
}

/// Set the form binding (name + submitted value).
pub fn form_attr(config: CheckboxConfig, form_attr: FormAttr) -> CheckboxConfig {
  CheckboxConfig(..config, form_attr: form_attr)
}

/// Set the `id` attribute (auto-generated when help text is shown and empty).
pub fn id(config: CheckboxConfig, id: String) -> CheckboxConfig {
  CheckboxConfig(..config, id: id)
}

/// Set helper text shown beneath the label.
pub fn help_text(config: CheckboxConfig, help_text: String) -> CheckboxConfig {
  CheckboxConfig(..config, help_text: help_text)
}

/// Append an extra CSS class on the label. Additive only.
pub fn add_class(config: CheckboxConfig, class: String) -> CheckboxConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  CheckboxConfig(..config, class: merged)
}

fn base_input(status: CheckStatus, form_attr: FormAttr) {
  let FormAttr(name:, value:) = form_attr
  let second_attrs = case name {
    "" -> []
    name -> [
      a.name(name),
      case value {
        InitValue(v) -> a.default_value(v)
        SyncValue(v) -> a.value(v)
      },
    ]
  }
  h.input([
    a.type_("checkbox"),
    a.class(class_input),
    case status {
      InitChecked(v) -> a.default_checked(v)
      SyncChecked(v) -> a.checked(v)
    },
    ..second_attrs
  ])
}

/// Render the checkbox with the given label and checked status.
pub fn view(config: CheckboxConfig, label: String, status: CheckStatus) {
  let label_attrs = case config.class {
    "" -> []
    class -> [a.class(class)]
  }
  case config.help_text {
    "" ->
      h.label([a.class(class_label), a.class("gap-3"), ..label_attrs], [
        base_input(status, config.form_attr),
        h.text(label),
      ])
    help -> {
      // When help text is shown the label can't wrap the input (it needs its
      // own <p>), so the input needs an id for `<label for>`. Generate one if
      // the caller didn't supply it.
      let input_id =
        case config.id {
          "" -> typeid.new(prefix: "chkbx") |> result.map(typeid.to_string)
          id -> Ok(id)
        }
        |> result.unwrap("checkbox-fallback")
      h.div([a.class("flex items-start gap-3")], [
        h.input([
          a.type_("checkbox"),
          a.class(class_input),
          a.id(input_id),
          case status {
            InitChecked(v) -> a.default_checked(v)
            SyncChecked(v) -> a.checked(v)
          },
          ..case config.form_attr {
            FormAttr("", _) -> []
            FormAttr(name, value) -> [
              a.name(name),
              case value {
                InitValue(v) -> a.default_value(v)
                SyncValue(v) -> a.value(v)
              },
            ]
          }
        ]),
        h.div([a.class("grid gap-2")], [
          h.label([a.class(class_label), a.for(input_id), ..label_attrs], [
            h.text(label),
          ]),
          h.p([a.class("text-muted-foreground text-sm")], [h.text(help)]),
        ]),
      ])
    }
  }
}

// --- Convenience shortcuts ---

/// Example: `checkbox_basic("Accept terms and conditions")`.
pub fn checkbox_basic(label: String) {
  new() |> view(label, default_check_status)
}
