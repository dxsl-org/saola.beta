import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/alert
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page("Alerts", "Showcase of alert notifications.", [
    DocSection("demo", "Demo", [
      h.div([a.class("grid gap-4 mt-4")], [
        alert.view(
          alert.new(),
          "Heads up!",
          "You can add components to your app using the CLI.",
        ),
        alert.view(
          alert.new() |> alert.variant(alert.Destructive),
          "Error",
          "Your session has expired. Please log in again.",
        ),
        alert.alert_default("A simple informational message with no title."),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/alert",
        "",
        "// Shortcuts",
        "alert.alert_default(\"A simple informational message.\")",
        "alert.alert_destructive(\"Error\", \"Your session has expired.\")",
        "",
        "// Builder — config holds variant + icon; view takes title + description",
        "alert.new()",
        "|> alert.variant(alert.Destructive)",
        "|> alert.view(\"Error\", \"Your session has expired.\")",
      ]),
    ]),
  ])
}
