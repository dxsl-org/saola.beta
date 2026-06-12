import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/context_menu
import saola/preview/model.{
  type Message, type Model, ContextMenuClosed, ContextMenuOpened,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page("Context Menu", "A menu shown on right-click.", [
    DocSection("demo", "Demo", [
      h.div([a.class("grid gap-8")], [
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("Basic")]),
          context_menu.context_menu_simple(
            h.div(
              [
                a.class(
                  "border rounded p-8 text-center text-sm text-muted select-none",
                ),
              ],
              [text("Right-click here")],
            ),
            [
              context_menu.ContextMenuAction("Copy", model.ContextMenuClosed),
              context_menu.ContextMenuAction("Paste", model.ContextMenuClosed),
              context_menu.ContextMenuSeparator,
              context_menu.ContextMenuDestructive(
                "Delete",
                model.ContextMenuClosed,
              ),
            ],
            model.context_menu_open,
            model.context_menu_x,
            model.context_menu_y,
            fn(x, y) { ContextMenuOpened(x, y) },
            fn() { ContextMenuClosed },
          ),
        ]),
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("With shortcuts and groups")]),
          context_menu.context_menu_simple(
            h.div(
              [
                a.class(
                  "border rounded p-8 text-center text-sm text-muted select-none",
                ),
              ],
              [text("Right-click here")],
            ),
            [
              context_menu.ContextMenuActionShortcut(
                "Undo",
                "Ctrl+Z",
                model.ContextMenuClosed,
              ),
              context_menu.ContextMenuActionShortcut(
                "Redo",
                "Ctrl+Y",
                model.ContextMenuClosed,
              ),
              context_menu.ContextMenuSeparator,
              context_menu.ContextMenuGroup("Edit", [
                context_menu.ContextMenuAction("Cut", model.ContextMenuClosed),
                context_menu.ContextMenuAction("Copy", model.ContextMenuClosed),
                context_menu.ContextMenuAction("Paste", model.ContextMenuClosed),
              ]),
              context_menu.ContextMenuSeparator,
              context_menu.ContextMenuDisabled("Select All"),
            ],
            model.context_menu_open,
            model.context_menu_x,
            model.context_menu_y,
            fn(x, y) { ContextMenuOpened(x, y) },
            fn() { ContextMenuClosed },
          ),
        ]),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/context_menu",
        "",
        "context_menu.context_menu_simple(",
        "  trigger_element,",
        "  [",
        "    context_menu.ContextMenuAction(\"Copy\", OnCopy),",
        "    context_menu.ContextMenuSeparator,",
        "    context_menu.ContextMenuDestructive(\"Delete\", OnDelete),",
        "  ],",
        "  model.context_menu_open,",
        "  model.context_menu_x,",
        "  model.context_menu_y,",
        "  fn(x, y) { ContextMenuOpened(x, y) },",
        "  fn() { ContextMenuClosed },",
        ")",
      ]),
    ]),
  ])
}
