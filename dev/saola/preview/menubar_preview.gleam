import lustre/element.{type Element}
import saola/menubar
import saola/preview/model.{
  type Message, type Model, MenubarClosed, MenubarOpened,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page("Menubar", "A horizontal menu bar with dropdown submenus.", [
    DocSection("demo", "Demo", [
      menubar.menubar_simple(
        [
          menubar.MenubarItem("File", [
            menubar.MenubarSubItem("New", MenubarClosed),
            menubar.MenubarSubItem("Open", MenubarClosed),
            menubar.MenubarSeparator,
            menubar.MenubarSubItem("Save", MenubarClosed),
            menubar.MenubarSubItemDisabled("Save As"),
          ]),
          menubar.MenubarItem("Edit", [
            menubar.MenubarSubItem("Undo", MenubarClosed),
            menubar.MenubarSubItem("Redo", MenubarClosed),
            menubar.MenubarSeparator,
            menubar.MenubarSubItem("Cut", MenubarClosed),
            menubar.MenubarSubItem("Copy", MenubarClosed),
          ]),
          menubar.MenubarItemDisabled("View"),
        ],
        model.menubar_open,
        MenubarOpened,
        fn() { MenubarClosed },
      ),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/menubar",
        "",
        "menubar.menubar_simple(",
        "  [",
        "    menubar.MenubarItem(\"File\", [",
        "      menubar.MenubarSubItem(\"New\", MenubarClosed),",
        "      menubar.MenubarSeparator,",
        "      menubar.MenubarSubItem(\"Save\", MenubarClosed),",
        "    ]),",
        "  ],",
        "  model.menubar_open,",
        "  MenubarOpened,",
        "  fn() { MenubarClosed },",
        ")",
      ]),
    ]),
  ])
}
