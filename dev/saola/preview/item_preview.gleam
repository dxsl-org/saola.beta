import gleam/list
import gleam/option.{None, Some}
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
    item.item(
      variant: item.Default,
      size: item.Large,
      media: Some(lu.user([])),
      media_variant: item.MediaIcon,
      title: "Alice Smith",
      description: "Software engineer",
      actions: actions,
      class: "",
    ),
    item.item(
      variant: item.Default,
      size: item.Large,
      media: Some(lu.user([])),
      media_variant: item.MediaIcon,
      title: "Bob Jones",
      description: "Product designer",
      actions: actions,
      class: "",
    ),
    item.item(
      variant: item.Default,
      size: item.Large,
      media: Some(lu.user([])),
      media_variant: item.MediaIcon,
      title: "Carol Doe",
      description: "Engineering manager",
      actions: actions,
      class: "",
    ),
  ]

  doc_page.doc_page("Item", "Row-layout primitive for lists.", [
    DocSection("variants", "Variants", [
      h.div([], [
        item.item(
          variant: item.Default,
          size: item.Large,
          media: None,
          media_variant: item.MediaDefault,
          title: "Default variant",
          description: "Transparent background.",
          actions: actions,
          class: "",
        ),
        item.item(
          variant: item.Outline,
          size: item.Large,
          media: None,
          media_variant: item.MediaDefault,
          title: "Outline variant",
          description: "Bordered.",
          actions: actions,
          class: "",
        ),
        item.item(
          variant: item.Muted,
          size: item.Large,
          media: None,
          media_variant: item.MediaDefault,
          title: "Muted variant",
          description: "Muted background.",
          actions: actions,
          class: "",
        ),
      ]),
    ]),
    DocSection("sizes", "Sizes", [
      item.item(
        variant: item.Outline,
        size: item.Small,
        media: None,
        media_variant: item.MediaDefault,
        title: "Small size",
        description: "Tighter padding.",
        actions: actions,
        class: "",
      ),
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
        "item.item(",
        "  variant: item.Default,",
        "  size: item.Large,",
        "  media: None,",
        "  media_variant: item.MediaDefault,",
        "  title: \"Alice Smith\",",
        "  description: \"Software engineer\",",
        "  actions: [button.button_outline(\"View\", OnView)],",
        "  class: \"\",",
        ")",
      ]),
    ]),
  ])
}
