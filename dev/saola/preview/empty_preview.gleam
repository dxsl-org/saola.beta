import gleam/option.{None, Some}
import lustre/element.{type Element, text}
import saola/button
import saola/empty
import saola/icon/li
import saola/icon/ls
import saola/preview/model.{type Message, StartedTrial}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Empty",
    "Empty-state panels for no-results and onboarding screens.",
    [
      DocSection("simple", "Simple", [
        empty.empty_simple(
          None,
          "Nothing here yet",
          "Create one to get started.",
          None,
        ),
      ]),
      DocSection("with-icon-action", "With Icon + Action", [
        empty.empty_simple(
          Some(li.inbox([])),
          "No messages",
          "You're all caught up.",
          Some(button.button_primary("Refresh", StartedTrial)),
        ),
      ]),
      DocSection("custom", "Custom (empty_full)", [
        empty.new()
        |> empty.media(ls.search_x([]))
        |> empty.media_variant(empty.Icon)
        |> empty.view("No results", [text("Try a different search term.")], []),
      ]),
      DocSection("bare", "Bare (no header)", [
        empty.new()
        |> empty.view("", [], [
          button.button_primary("Get started", StartedTrial),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/empty",
          "",
          "empty.empty_simple(",
          "  Some(li.inbox([])),",
          "  \"No messages\",",
          "  \"You're all caught up.\",",
          "  Some(button.button_primary(\"Refresh\", OnRefresh)),",
          ")",
        ]),
      ]),
    ],
  )
}
