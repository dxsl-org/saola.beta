import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/icon/lc

pub type ComboboxOption {
  ComboboxOption(value: String, label: String)
}

pub type ComboboxAttrs {
  ComboboxAttrs(placeholder: String, search_placeholder: String, class: String)
}

pub const default_attrs = ComboboxAttrs(
  placeholder: "Select...",
  search_placeholder: "Search...",
  class: "",
)

fn selected_label(
  options: List(ComboboxOption),
  selected: Option(String),
) -> String {
  case selected {
    None -> ""
    Some(v) ->
      case list.find(options, fn(o) { o.value == v }) {
        Ok(o) -> o.label
        Error(_) -> ""
      }
  }
}

pub fn combobox_filter(
  options: List(ComboboxOption),
  query: String,
) -> List(ComboboxOption) {
  case query {
    "" -> options
    q -> {
      let q_low = string.lowercase(q)
      list.filter(options, fn(o) {
        string.contains(string.lowercase(o.label), q_low)
      })
    }
  }
}

fn render_option(
  opt: ComboboxOption,
  selected: Option(String),
  on_select: fn(String) -> msg,
) -> Element(msg) {
  let is_sel = case selected {
    Some(v) -> v == opt.value
    None -> False
  }
  let cls = case is_sel {
    True -> "combobox-option combobox-option-selected"
    False -> "combobox-option"
  }
  let check_icon = case is_sel {
    True -> lc.check([a.class("combobox-check")])
    False -> h.span([a.class("combobox-check-spacer")], [])
  }
  h.button(
    [
      a.type_("button"),
      a.class(cls),
      a.attribute("role", "option"),
      a.attribute("aria-selected", case is_sel {
        True -> "true"
        False -> "false"
      }),
      e.on_click(on_select(opt.value)),
    ],
    [check_icon, h.span([], [h.text(opt.label)])],
  )
}

pub fn combobox_full(
  options: List(ComboboxOption),
  selected: Option(String),
  query: String,
  open: Bool,
  on_open_change: fn(Bool) -> msg,
  on_query_change: fn(String) -> msg,
  on_select: fn(String) -> msg,
  attrs: ComboboxAttrs,
) -> Element(msg) {
  let extra_class = case attrs.class {
    "" -> a.none()
    c -> a.class(c)
  }
  let label = case selected_label(options, selected) {
    "" -> attrs.placeholder
    s -> s
  }
  let panel = case open {
    False -> element.none()
    True ->
      h.div(
        [a.class("combobox-panel"), a.attribute("role", "listbox")],
        [
          h.div([a.class("combobox-search")], [
            h.input([
              a.type_("text"),
              a.class("combobox-search-input"),
              a.value(query),
              a.placeholder(attrs.search_placeholder),
              a.attribute("aria-autocomplete", "list"),
              e.on_input(on_query_change),
            ]),
          ]),
          h.div(
            [a.class("combobox-options")],
            case options {
              [] -> [
                h.div([a.class("combobox-empty")], [h.text("No results.")]),
              ]
              _ ->
                list.map(options, fn(o) { render_option(o, selected, on_select) })
            },
          ),
        ],
      )
  }
  h.div(
    [a.class("combobox-wrapper"), extra_class],
    [
      h.button(
        [
          a.type_("button"),
          a.class("combobox-trigger"),
          a.attribute("role", "combobox"),
          a.attribute("aria-expanded", case open {
            True -> "true"
            False -> "false"
          }),
          e.on_click(on_open_change(!open)),
        ],
        [
          h.span([a.class("combobox-value")], [h.text(label)]),
          lc.chevron_down([a.class("combobox-chevron")]),
        ],
      ),
      panel,
    ],
  )
}

pub fn combobox_simple(
  options: List(ComboboxOption),
  selected: Option(String),
  open: Bool,
  on_open_change: fn(Bool) -> msg,
  on_select: fn(String) -> msg,
) -> Element(msg) {
  combobox_full(
    options,
    selected,
    "",
    open,
    on_open_change,
    fn(_) { on_open_change(open) },
    on_select,
    default_attrs,
  )
}
