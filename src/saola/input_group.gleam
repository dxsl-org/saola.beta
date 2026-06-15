//// Input group widget (prefix/suffix addons around an input) — dual-style
//// `Config` (uniform Saola pattern):
////
//// ```gleam
//// input_group.input_group_simple(Some(at), the_input, None)         // shortcut
//// input_group.new()
//// |> input_group.invalid(True)
//// |> input_group.view(Some(at), the_input, None)
//// ```

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Presentation options for an input group. Public for record-update syntax.
/// The `prefix`, `content`, and `suffix` are the required data (`view`).
pub type InputGroupConfig {
  InputGroupConfig(class: String, invalid: Bool)
}

/// Builder entry point. Defaults: no class, valid.
pub fn new() -> InputGroupConfig {
  InputGroupConfig(class: "", invalid: False)
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> InputGroupConfig {
  new()
}

/// Set `aria-invalid="true"` for validation styling.
pub fn invalid(config: InputGroupConfig, invalid: Bool) -> InputGroupConfig {
  InputGroupConfig(..config, invalid: invalid)
}

/// Append an extra CSS class. Additive only.
pub fn add_class(config: InputGroupConfig, class: String) -> InputGroupConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  InputGroupConfig(..config, class: merged)
}

/// Render the group: optional prefix addon, the content element, optional
/// suffix addon.
pub fn view(
  config: InputGroupConfig,
  prefix: Option(Element(msg)),
  content: Element(msg),
  suffix: Option(Element(msg)),
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let invalid_attrs = case config.invalid {
    True -> [a.attribute("aria-invalid", "true")]
    False -> []
  }
  h.div(
    list.flatten([
      [a.role("group"), a.class("input-group")],
      extra_class_attrs,
      invalid_attrs,
    ]),
    [
      case prefix {
        None -> h.text("")
        Some(p) -> h.div([a.class("input-group-addon")], [p])
      },
      content,
      case suffix {
        None -> h.text("")
        Some(s) -> h.div([a.class("input-group-addon")], [s])
      },
    ],
  )
}

// --- Convenience shortcuts ---

pub fn input_group_simple(
  prefix: Option(Element(msg)),
  content: Element(msg),
  suffix: Option(Element(msg)),
) -> Element(msg) {
  new() |> view(prefix, content, suffix)
}
