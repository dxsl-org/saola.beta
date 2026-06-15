//// Label widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// label.label_for("Email", "email-input")          // shortcut
//// label.new() |> label.for_("email-input") |> label.view("Email")
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub const class_label = "label"

/// Presentation options for a `<label>`. Public for record-update syntax.
pub type LabelConfig {
  LabelConfig(for_: String, class: String)
}

/// Builder entry point. Defaults: no `for`, no extra class.
pub fn new() -> LabelConfig {
  LabelConfig(for_: "", class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> LabelConfig {
  new()
}

/// Associate the label with an input by id (renders `for="id"`).
pub fn for_(config: LabelConfig, id: String) -> LabelConfig {
  LabelConfig(..config, for_: id)
}

/// Append an extra CSS class after the `label` base class. Additive only.
pub fn add_class(config: LabelConfig, class: String) -> LabelConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  LabelConfig(..config, class: merged)
}

/// Render the `<label>` element with the given text.
pub fn view(config: LabelConfig, text: String) -> Element(msg) {
  let for_attrs = case config.for_ {
    "" -> []
    v -> [a.for(v)]
  }
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  h.label(
    list.flatten([[a.class(class_label)], for_attrs, extra_class_attrs]),
    [h.text(text)],
  )
}

// --- Convenience shortcuts ---

/// Full-options shortcut (positional): text, `for` id, extra class.
pub fn label(text: String, input_id: String, class: String) -> Element(msg) {
  new() |> for_(input_id) |> add_class(class) |> view(text)
}

/// Label associated with an input by id.
pub fn label_for(text: String, input_id: String) -> Element(msg) {
  new() |> for_(input_id) |> view(text)
}
