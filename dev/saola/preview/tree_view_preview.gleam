import gleam/option.{None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, TreeNodeToggled}
import saola/preview/view/doc_page.{DocSection}
import saola/tree_view

pub fn view(model: Model) -> Element(Message) {
  let items = [
    tree_view.TreeItem(id: "src", label: "src", icon: None, children: [
      tree_view.TreeItem(id: "src-saola", label: "saola", icon: None, children: [
        tree_view.TreeItem(
          id: "button-gleam",
          label: "button.gleam",
          icon: None,
          children: [],
        ),
        tree_view.TreeItem(
          id: "input-gleam",
          label: "input.gleam",
          icon: None,
          children: [],
        ),
      ]),
      tree_view.TreeItem(
        id: "main-gleam",
        label: "main.gleam",
        icon: None,
        children: [],
      ),
    ]),
    tree_view.TreeItem(id: "test", label: "test", icon: None, children: [
      tree_view.TreeItem(
        id: "widget-tests",
        label: "widget_tests.gleam",
        icon: None,
        children: [],
      ),
    ]),
    tree_view.TreeItem(
      id: "gleam-toml",
      label: "gleam.toml",
      icon: None,
      children: [],
    ),
  ]

  doc_page.doc_page(
    "Tree View",
    "A collapsible tree for hierarchical data. Click folders to expand/collapse; "
      <> "nodes are also keyboard reachable (Tab) and activate on Enter.",
    [
      DocSection("file-tree", "File Tree", [
        h.div([a.class("max-w-xs border rounded-md p-2")], [
          tree_view.tree_view_simple(
            items,
            model.tree_open_ids,
            TreeNodeToggled,
          ),
        ]),
      ]),
      DocSection("with-select", "With Select Callback", [
        h.div([a.class("max-w-xs border rounded-md p-2")], [
          tree_view.new()
          |> tree_view.view(
            items,
            model.tree_open_ids,
            TreeNodeToggled,
            Some(fn(_id) { TreeNodeToggled("") }),
          ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/tree_view",
          "",
          "tree_view.tree_view_simple(",
          "  items,",
          "  model.tree_open_ids,        // consumer owns which ids are open",
          "  TreeNodeToggled,",
          ")",
          "",
          "// Accessibility: each node is role=treeitem, tabindex=0 (Tab-reachable),",
          "// with aria-expanded on branches. Enter toggles a branch / selects a leaf.",
          "// Pass an on_select (full view) to make leaves selectable:",
          "tree_view.new()",
          "|> tree_view.view(items, open_ids, TreeNodeToggled, Some(NodeSelected))",
        ]),
      ]),
    ],
  )
}
