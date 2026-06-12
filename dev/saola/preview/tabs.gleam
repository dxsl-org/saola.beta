import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, TabChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/tabs

pub fn view(model: Model) -> Element(Message) {
  let demo_tabs = [
    tabs.Tab(
      "account",
      "Account",
      h.p([], [
        text("Manage your account settings and preferences."),
      ]),
    ),
    tabs.Tab(
      "password",
      "Password",
      h.p([], [
        text("Change your password here. After saving, you'll be logged out."),
      ]),
    ),
    tabs.Tab(
      "notifications",
      "Notifications",
      h.p([], [
        text("Configure how you receive notifications."),
      ]),
    ),
  ]

  doc_page.doc_page("Tabs", "Organize content into tabbed panels.", [
    DocSection("demo", "Demo", [
      tabs.tabs_simple(
        items: demo_tabs,
        active_id: model.active_tab,
        on_tab_change: TabChanged,
      ),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/tabs",
        "",
        "tabs.tabs_simple(",
        "  items: [",
        "    tabs.Tab(\"account\", \"Account\", h.p([], [text(\"Content\")])),",
        "  ],",
        "  active_id: model.active_tab,",
        "  on_tab_change: TabChanged,",
        ")",
      ]),
    ]),
  ])
}
