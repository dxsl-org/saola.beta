import gleam/list
import gleam/option.{Some}
import lustre/element.{type Element}
import lustre/element/html as h
import saola/button
import saola/icon/lu
import saola/item
import saola/preview/model.{type Message, StartedTrial}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  let actions = [button.button_outline("View", StartedTrial)]

  let three_items = [
    item.new()
      |> item.media(lu.user([]))
      |> item.media_variant(item.MediaIcon)
      |> item.actions(actions)
      |> item.view("Alice Smith", "Software engineer", ""),
    item.new()
      |> item.media(lu.user([]))
      |> item.media_variant(item.MediaIcon)
      |> item.actions(actions)
      |> item.view("Bob Jones", "Product designer", ""),
    item.new()
      |> item.media(lu.user([]))
      |> item.media_variant(item.MediaIcon)
      |> item.actions(actions)
      |> item.view("Carol Doe", "Engineering manager", ""),
  ]

  doc_page.doc_page("Item", "Row-layout primitive for lists.", [
    DocSection("variants", "Variants", [
      h.div([], [
        item.new()
          |> item.actions(actions)
          |> item.view("Default variant", "Transparent background.", ""),
        item.new()
          |> item.variant(item.Outline)
          |> item.actions(actions)
          |> item.view("Outline variant", "Bordered.", ""),
        item.new()
          |> item.variant(item.Muted)
          |> item.actions(actions)
          |> item.view("Muted variant", "Muted background.", ""),
      ]),
    ]),
    DocSection("sizes", "Sizes", [
      item.new()
      |> item.variant(item.Outline)
      |> item.size(item.Small)
      |> item.actions(actions)
      |> item.view("Small size", "Tighter padding.", ""),
    ]),
    DocSection("group", "Group with Separators", [
      item.item_group(list.intersperse(three_items, item.item_separator())),
    ]),
    DocSection("link-item", "Link Item", [
      item.item_link(
        href: "#alice",
        title: "Alice Smith",
        description: "Click to view profile",
        action: Some(button.button_outline("Open", StartedTrial)),
        class: "",
      ),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/item",
        "",
        "// Shortcuts",
        "item.item_simple(\"Alice\", \"Engineer\", Some(view_button))",
        "item.item_link(href: \"/u/alice\", title: \"Alice\", ...)  // renders <a>",
        "",
        "// Builder — view(config, title, description, href).",
        "// Empty href -> <div>; non-empty href -> <a>.",
        "item.new()",
        "|> item.variant(item.Outline)",
        "|> item.actions([button.button_outline(\"View\", OnView)])",
        "|> item.view(\"Alice Smith\", \"Software engineer\", \"\")",
      ]),
    ]),
  ])
}
