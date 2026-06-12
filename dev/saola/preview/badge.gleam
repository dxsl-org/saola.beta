import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/badge
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page("Badges", "Inline labels to highlight status or category.", [
    DocSection("demo", "Demo", [
      h.div([a.class("flex gap-3 flex-wrap mt-4")], [
        badge.badge_default("Default"),
        badge.badge_secondary("Secondary"),
        badge.badge_destructive("Destructive"),
        badge.badge_outline("Outline"),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/badge",
        "",
        "badge.badge_default(\"Default\")",
        "badge.badge_secondary(\"Secondary\")",
        "badge.badge_destructive(\"Destructive\")",
        "badge.badge_outline(\"Outline\")",
      ]),
    ]),
    DocSection("api", "API", [
      h.p([], [
        text(
          "Each shortcut wraps the fully-customizable badge function. "
          <> "Full signatures live in the API Reference under saola/badge.",
        ),
      ]),
    ]),
  ])
}
