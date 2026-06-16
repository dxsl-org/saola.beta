//// Tree view widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// tree_view.tree_view_simple(items, model.open, OnToggle)           // shortcut
//// tree_view.new()
//// |> tree_view.add_class("my-tree")
//// |> tree_view.view(items, model.open, OnToggle, Some(OnSelect))
//// ```
//// Consumer owns which node IDs are open (`open_ids`).

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// A node in the tree. A non-empty `children` list makes it an expandable
/// branch; an empty list makes it a selectable leaf. `id` must be unique —
/// it drives both `open_ids` membership and the toggle/select callbacks.
pub type TreeItem(msg) {
  TreeItem(
    id: String,
    label: String,
    icon: Option(Element(msg)),
    children: List(TreeItem(msg)),
  )
}

/// Presentation options for a tree view. Public for record-update syntax. The
/// items/open_ids/handlers are the required data, passed to `view`.
pub type TreeViewConfig {
  TreeViewConfig(class: String)
}

/// Builder entry point. Default: no extra class.
pub fn new() -> TreeViewConfig {
  TreeViewConfig(class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> TreeViewConfig {
  new()
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: TreeViewConfig, class: String) -> TreeViewConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  TreeViewConfig(class: merged)
}

/// Render the tree. `on_toggle` fires when a branch is expanded/collapsed;
/// `on_select` (optional) fires when a leaf is activated.
pub fn view(
  config: TreeViewConfig,
  items: List(TreeItem(msg)),
  open_ids: List(String),
  on_toggle: fn(String) -> msg,
  on_select: Option(fn(String) -> msg),
) -> Element(msg) {
  let root_class = case config.class {
    "" -> "tree-view"
    c -> "tree-view " <> c
  }
  h.ul(
    [a.class(root_class), a.role("tree")],
    list.map(items, fn(item) {
      render_node(item, open_ids, on_toggle, on_select, 0)
    }),
  )
}

fn render_node(
  item: TreeItem(msg),
  open_ids: List(String),
  on_toggle: fn(String) -> msg,
  on_select: Option(fn(String) -> msg),
  depth: Int,
) -> Element(msg) {
  let is_open = list.contains(open_ids, item.id)
  let has_children = !list.is_empty(item.children)
  let node_class = case has_children {
    True ->
      case is_open {
        True -> "tree-node tree-node-open"
        False -> "tree-node tree-node-closed"
      }
    False -> "tree-node tree-node-leaf"
  }
  let icon_el = case item.icon {
    None -> element.none()
    Some(icon) -> h.span([a.class("tree-node-icon")], [icon])
  }
  let expand_el = case has_children {
    False -> h.span([a.class("tree-node-spacer")], [])
    True ->
      h.span([a.class("tree-node-expand"), a.attribute("aria-hidden", "true")], [
        h.text(case is_open {
          True -> "▾"
          False -> "▸"
        }),
      ])
  }
  let row_attrs = case has_children {
    True -> [
      a.class("tree-node-row"),
      a.style("padding-left", calc_indent(depth)),
      a.attribute("aria-expanded", case is_open {
        True -> "true"
        False -> "false"
      }),
      e.on_click(on_toggle(item.id)),
    ]
    False -> {
      let on_select_attrs = case on_select {
        None -> []
        Some(f) -> [e.on_click(f(item.id))]
      }
      list.flatten([
        [a.class("tree-node-row"), a.style("padding-left", calc_indent(depth))],
        on_select_attrs,
      ])
    }
  }
  h.li([a.class(node_class), a.role("treeitem")], [
    h.div(row_attrs, [
      expand_el,
      icon_el,
      h.span([a.class("tree-node-label")], [h.text(item.label)]),
    ]),
    case has_children && is_open {
      False -> element.none()
      True ->
        h.ul(
          [a.class("tree-children"), a.role("group")],
          list.map(item.children, fn(child) {
            render_node(child, open_ids, on_toggle, on_select, depth + 1)
          }),
        )
    },
  ])
}

fn calc_indent(depth: Int) -> String {
  let px = depth * 16 + 8
  int.to_string(px) <> "px"
}

// --- Convenience shortcuts ---

/// A tree with expand/collapse only (no leaf selection). Leaves are inert
/// without an `on_select`; use `view` directly to make them selectable.
pub fn tree_view_simple(
  items: List(TreeItem(msg)),
  open_ids: List(String),
  on_toggle: fn(String) -> msg,
) -> Element(msg) {
  new() |> view(items, open_ids, on_toggle, None)
}
