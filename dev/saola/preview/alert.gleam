import gleam/option.{None}
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
        alert.alert(
          alert.Default,
          title: "Heads up!",
          description: "You can add components to your app using the CLI.",
          icon: None,
        ),
        alert.alert(
          alert.Destructive,
          title: "Error",
          description: "Your session has expired. Please log in again.",
          icon: None,
        ),
        alert.alert_default("A simple informational message with no title."),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/alert",
        "import gleam/option.{None}",
        "",
        "alert.alert(alert.Default, title: \"Heads up!\",",
        "  description: \"You can add components to your app.\",",
        "  icon: None)",
        "",
        "alert.alert(alert.Destructive, title: \"Error\",",
        "  description: \"Your session has expired.\", icon: None)",
        "",
        "alert.alert_default(\"A simple informational message.\")",
      ]),
    ]),
  ])
}
