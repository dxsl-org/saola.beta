import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/command
import saola/preview/model.{
  type Message, type Model, CommandNavDown, CommandNavUp, CommandQueryChanged,
  CommandSelected,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  let items = [
    command.CommandGroup("Suggestions", [
      command.CommandAction("calendar", "Calendar", CommandSelected("calendar")),
      command.CommandAction("search", "Search Emoji", CommandSelected("search")),
      command.CommandAction(
        "calculator",
        "Calculator",
        CommandSelected("calculator"),
      ),
    ]),
    command.CommandSeparator,
    command.CommandGroup("Settings", [
      command.CommandActionShortcut(
        "profile",
        "Profile",
        "⌘P",
        CommandSelected("profile"),
      ),
      command.CommandActionShortcut(
        "billing",
        "Billing",
        "⌘B",
        CommandSelected("billing"),
      ),
      command.CommandActionShortcut(
        "settings",
        "Settings",
        "⌘S",
        CommandSelected("settings"),
      ),
      command.CommandDisabled("New Team"),
    ]),
  ]

  doc_page.doc_page(
    "Command",
    "A command palette for searching and executing actions.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Full command palette (keyboard navigation)")]),
            h.div([a.style("max-width", "480px")], [
              command.new()
              |> command.view(
                model.command_query,
                items,
                model.command_highlighted,
                fn(q) { CommandQueryChanged(q) },
                fn() { CommandNavUp },
                fn() { CommandNavDown },
                fn(_idx) { CommandSelected("") },
              ),
            ]),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Simple (no keyboard nav)")]),
            h.div([a.style("max-width", "480px")], [
              command.command_simple(
                "",
                [
                  command.CommandAction("copy", "Copy", CommandSelected("copy")),
                  command.CommandAction("cut", "Cut", CommandSelected("cut")),
                  command.CommandAction(
                    "paste",
                    "Paste",
                    CommandSelected("paste"),
                  ),
                  command.CommandSeparator,
                  command.CommandDisabled("Select All"),
                ],
                fn(q) { CommandQueryChanged(q) },
                fn(_idx) { CommandSelected("") },
              ),
            ]),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/command",
          "",
          "command.command_simple(",
          "  \"\",",
          "  [",
          "    command.CommandAction(\"copy\", \"Copy\", CommandSelected(\"copy\")),",
          "    command.CommandSeparator,",
          "    command.CommandDisabled(\"Select All\"),",
          "  ],",
          "  fn(q) { CommandQueryChanged(q) },",
          "  fn(_idx) { CommandSelected(\"\") },",
          ")",
        ]),
      ]),
    ],
  )
}
