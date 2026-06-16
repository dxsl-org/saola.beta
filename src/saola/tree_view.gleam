//// Tree view widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// tree_view.tree_view_simple(items, model.open, OnToggle)           // shortcut
//// tree_view.new()
//// |> tree_view.add_class("my-tree")
//// |> tree_view.view(items, model.open, OnToggle, Some(OnSelect))
//// ```
//// Consumer owns which node IDs are open (`open_ids`). Nodes are keyboard
//// reachable (`tabindex="0"`) and activate on `Enter` (toggle a branch /
//// select a leaf); `aria-expanded` sits on each `role="treeitem"`.

import gleam/dynamic/decode
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
  // `aria-expanded` belongs on the treeitem itself (the <li>), not the inner
  // row; the same <li> is the focusable, keyboard-activatable node.
  let aria_expanded_attrs = case has_children {
    True -> [
      a.attribute("aria-expanded", case is_open {
        True -> "true"
        False -> "false"
      }),
    ]
    False -> []
  }
  let li_attrs =
    list.flatten([
      [
        a.class(node_class),
        a.role("treeitem"),
        a.attribute("tabindex", "0"),
        e.on("keydown", decode_activate(item.id, has_children, on_toggle, on_select)),
      ],
      aria_expanded_attrs,
    ])
  h.li(li_attrs, [
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

/// Keyboard activation for a focused treeitem: `Enter` toggles a branch or
/// selects a leaf, mirroring the click behaviour. Other keys fall through so
/// `Tab` still moves focus. `Enter` has no default scroll, so no
/// `prevent_default` is needed; arrow-key roving navigation would require the
/// consumer to track a focused id and is left as a future enhancement.
fn decode_activate(
  id: String,
  has_children: Bool,
  on_toggle: fn(String) -> msg,
  on_select: Option(fn(String) -> msg),
) -> decode.Decoder(msg) {
  use key <- decode.field("key", decode.string)
  case key, has_children {
    "Enter", True -> decode.success(on_toggle(id))
    "Enter", False ->
      case on_select {
        Some(f) -> decode.success(f(id))
        None -> decode.failure(on_toggle(id), "no select handler")
      }
    _, _ -> decode.failure(on_toggle(id), "not an activation key")
  }
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
