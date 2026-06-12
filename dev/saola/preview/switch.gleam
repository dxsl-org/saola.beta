import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/preview/model.{type Message, SwitchToggled}
import saola/preview/view/doc_page.{DocSection}
import saola/switch

pub fn view(notifications: Bool, marketing: Bool) -> Element(Message) {
  doc_page.doc_page("Switch", "A toggle switch for boolean on/off settings.", [
    DocSection("demo", "Demo", [
      h.div([a.class("mt-4 grid gap-4")], [
        switch.switch_simple("Enable notifications", notifications, fn(v) {
          SwitchToggled("notifications", v)
        }),
        switch.switch_simple("Marketing emails", marketing, fn(v) {
          SwitchToggled("marketing", v)
        }),
        switch.switch(
          "Disabled switch",
          switch.InitChecked(True),
          on_change: fn(v) { SwitchToggled("disabled", v) },
          extra_attrs: switch.SwitchExtraAttrs(
            ..switch.default_extra_attrs,
            disabled: True,
          ),
        ),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/switch",
        "",
        "// Simple",
        "switch.switch_simple(\"Enable notifications\", model.notifications, fn(v) {",
        "  SwitchToggled(\"notifications\", v)",
        "})",
        "",
        "// Disabled",
        "switch.switch(",
        "  \"Disabled\", switch.InitChecked(True),",
        "  on_change: fn(v) { SwitchToggled(\"disabled\", v) },",
        "  extra_attrs: switch.SwitchExtraAttrs(..switch.default_extra_attrs, disabled: True),",
        ")",
      ]),
    ]),
  ])
}
