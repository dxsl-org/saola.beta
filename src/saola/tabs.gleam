//// Tabs widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// tabs.tabs_simple(items: my_tabs, active_id: model.tab, on_tab_change: TabChanged)  // shortcut
//// tabs.new()
//// |> tabs.add_class("my-tabs")
//// |> tabs.view(my_tabs, model.tab, TabChanged)
//// ```
////
//// NOTE: `aria-hidden` alone doesn't remove inactive panels from keyboard tab
//// order. Add `[role="tabpanel"][aria-hidden="true"] { display: none; }` to CSS.

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type Tab(msg) {
  Tab(id: String, label: String, content: Element(msg))
  TabWithIcon(
    id: String,
    icon: Element(msg),
    label: String,
    content: Element(msg),
  )
}

/// Presentation options for tabs. Public for record-update syntax. The `tabs`
/// list, `active_id`, and `on_tab_change` are the required data (`view`).
pub type TabsConfig {
  TabsConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> TabsConfig {
  TabsConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> TabsConfig {
  new()
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: TabsConfig, class: String) -> TabsConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  TabsConfig(class: merged)
}

fn tab_id(id: String) -> String {
  "tab-" <> id
}

fn panel_id(id: String) -> String {
  "panel-" <> id
}

fn tab_label(tab: Tab(msg)) -> String {
  case tab {
    Tab(label:, ..) -> label
    TabWithIcon(label:, ..) -> label
  }
}

fn tab_icon(tab: Tab(msg)) -> Element(msg) {
  case tab {
    Tab(..) -> element.none()
    TabWithIcon(icon:, ..) -> icon
  }
}

fn tab_content(tab: Tab(msg)) -> Element(msg) {
  case tab {
    Tab(content:, ..) -> content
    TabWithIcon(content:, ..) -> content
  }
}

fn tab_id_field(tab: Tab(msg)) -> String {
  case tab {
    Tab(id:, ..) -> id
    TabWithIcon(id:, ..) -> id
  }
}

fn render_trigger(
  tab: Tab(msg),
  is_active: Bool,
  on_tab_change: fn(String) -> msg,
) -> Element(msg) {
  let id = tab_id_field(tab)
  h.button(
    [
      a.type_("button"),
      a.role("tab"),
      a.id(tab_id(id)),
      a.aria_selected(is_active),
      a.aria_controls(panel_id(id)),
      e.on_click(on_tab_change(id)),
    ],
    [tab_icon(tab), h.text(tab_label(tab))],
  )
}

fn render_panel(tab: Tab(msg), is_active: Bool) -> Element(msg) {
  let id = tab_id_field(tab)
  h.div(
    [
      a.role("tabpanel"),
      a.id(panel_id(id)),
      a.aria_labelledby(tab_id(id)),
      a.aria_hidden(!is_active),
    ],
    [tab_content(tab)],
  )
}

/// Render the tab group. `active_id` is the visible tab's id; `on_tab_change`
/// receives the clicked tab's id.
pub fn view(
  config: TabsConfig,
  tabs: List(Tab(msg)),
  active_id: String,
  on_tab_change: fn(String) -> msg,
) -> Element(msg) {
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let triggers =
    tabs
    |> list.map(fn(tab) {
      render_trigger(tab, tab_id_field(tab) == active_id, on_tab_change)
    })
  let panels =
    tabs
    |> list.map(fn(tab) { render_panel(tab, tab_id_field(tab) == active_id) })
  h.div(list.flatten([[a.class("tabs")], extra_class_attrs]), [
    h.div([a.role("tablist")], triggers),
    ..panels
  ])
}

// --- Convenience shortcuts ---

pub fn tabs_simple(
  items items: List(Tab(msg)),
  active_id active_id: String,
  on_tab_change on_tab_change: fn(String) -> msg,
) -> Element(msg) {
  new() |> view(items, active_id, on_tab_change)
}
