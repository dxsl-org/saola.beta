//// Search input widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// search.search_simple(model.q, QueryChanged)                       // shortcut
//// search.search_clearable(model.q, QueryChanged, QueryCleared)      // shortcut + X
//// search.new()
//// |> search.size(search.Small)
//// |> search.view(model.q, QueryChanged, Some(QueryCleared))
//// ```

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type SearchSize {
  Small
  Large
}

/// Presentation options for a search input. Public for record-update syntax.
/// The `value`, `on_input`, and `on_clear` are required data, passed to `view`.
pub type SearchConfig {
  SearchConfig(
    size: SearchSize,
    placeholder: String,
    disabled: Bool,
    name: String,
    class: String,
  )
}

/// Builder entry point. Defaults: Large, "Search…" placeholder, enabled.
pub fn new() -> SearchConfig {
  SearchConfig(
    size: Large,
    placeholder: "Search…",
    disabled: False,
    name: "",
    class: "",
  )
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> SearchConfig {
  new()
}

/// Set the size (Large — default, Small).
pub fn size(config: SearchConfig, size: SearchSize) -> SearchConfig {
  SearchConfig(..config, size: size)
}

/// Set the placeholder text.
pub fn placeholder(config: SearchConfig, placeholder: String) -> SearchConfig {
  SearchConfig(..config, placeholder: placeholder)
}

/// Set the disabled state.
pub fn disabled(config: SearchConfig, disabled: Bool) -> SearchConfig {
  SearchConfig(..config, disabled: disabled)
}

/// Set the `name` attribute.
pub fn name(config: SearchConfig, name: String) -> SearchConfig {
  SearchConfig(..config, name: name)
}

/// Append an extra CSS class on the wrapper. Additive only.
pub fn add_class(config: SearchConfig, class: String) -> SearchConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  SearchConfig(..config, class: merged)
}

/// Render the search input. When `on_clear` is `Some(msg)`, an X button appears
/// and dispatches `msg` on click.
pub fn view(
  config: SearchConfig,
  value: String,
  on_input: fn(String) -> msg,
  on_clear: Option(msg),
) -> Element(msg) {
  let size_class = case config.size {
    Small -> " input-sm"
    Large -> ""
  }
  let extra_class = case config.class {
    "" -> ""
    c -> " " <> c
  }
  let clear_btn = case on_clear {
    None -> element.none()
    Some(msg) ->
      h.button(
        [
          a.type_("button"),
          a.class("btn-icon btn-ghost search-clear"),
          a.attribute("aria-label", "Clear search"),
          e.on_click(msg),
        ],
        [h.text("✕")],
      )
  }
  h.div(
    [a.class("input-wrapper" <> size_class <> extra_class), a.role("search")],
    [
      h.span([a.class("input-icon input-icon-left")], [h.text("🔍")]),
      h.input(
        list.flatten([
          [
            a.type_("search"),
            a.class(
              "input has-icon-left"
              <> case on_clear {
                None -> ""
                Some(_) -> " has-icon-right"
              },
            ),
            a.value(value),
          ],
          case config.placeholder {
            "" -> []
            p -> [a.placeholder(p)]
          },
          case config.name {
            "" -> []
            n -> [a.name(n)]
          },
          case config.disabled {
            True -> [a.disabled(True)]
            False -> []
          },
          [e.on_input(on_input)],
        ]),
      ),
      clear_btn,
    ],
  )
}

// --- Convenience shortcuts ---

pub fn search_simple(
  value: String,
  on_input: fn(String) -> msg,
) -> Element(msg) {
  new() |> view(value, on_input, None)
}

pub fn search_clearable(
  value: String,
  on_input: fn(String) -> msg,
  on_clear: msg,
) -> Element(msg) {
  new() |> view(value, on_input, Some(on_clear))
}
