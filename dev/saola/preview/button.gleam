import gleam/option.{None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

import saola/button
import saola/icon/lc
import saola/preview/model.{type Message, Home, OnRouteChange}
import saola/preview/view/doc_page.{DocSection}

import components/general/button/button as saolabutton

pub fn view() -> Element(Message) {
  let attrs_disabled = button.ButtonExtraAttrs(True, None, button.default_aria)
  let attrs_aria_label =
    button.ButtonExtraAttrs(
      False,
      None,
      button.ButtonAria("Save changes", None),
    )
  let attrs_aria_expanded =
    button.ButtonExtraAttrs(
      False,
      None,
      button.ButtonAria("Expand menu", Some(True)),
    )

  doc_page.doc_page(
    "Buttons",
    "Showcase of different button styles and sizes.",
    [
      DocSection("variants", "Variants", [
        h.div([a.class("button-grid")], [
          button.button_primary("Primary", OnRouteChange(Home)),
          button.button_secondary("Secondary", OnRouteChange(Home)),
          button.button_outline("Outline", OnRouteChange(Home)),
          button.button_ghost("Ghost", OnRouteChange(Home)),
          button.button_destructive("Destructive", OnRouteChange(Home)),
          button.button(
            button.Link,
            "Link",
            button.Large,
            None,
            Some(OnRouteChange(Home)),
            button.default_extra_attrs,
          ),
        ]),
      ]),
      DocSection("with-icon", "With Icon", [
        h.div([a.class("button-grid")], [
          button.button(
            button.Outline,
            "Check",
            button.Large,
            Some(lc.check([])),
            Some(OnRouteChange(Home)),
            button.default_extra_attrs,
          ),
          button.button(
            button.Secondary,
            "Menu",
            button.Large,
            Some(lc.chevron_down([])),
            Some(OnRouteChange(Home)),
            attrs_aria_expanded,
          ),
          button.button_close(OnRouteChange(Home)),
        ]),
      ]),
      DocSection("sizes", "Sizes", [
        h.div([a.class("button-grid")], [
          button.button(
            button.Primary,
            "Large",
            button.Large,
            None,
            None,
            button.default_extra_attrs,
          ),
          button.button(
            button.Primary,
            "Small",
            button.Small,
            None,
            None,
            button.default_extra_attrs,
          ),
        ]),
      ]),
      DocSection("disabled", "Disabled", [
        h.div([a.class("button-grid")], [
          button.button(
            button.Primary,
            "Disabled Primary",
            button.Large,
            None,
            None,
            attrs_disabled,
          ),
          button.button(
            button.Secondary,
            "Disabled Secondary",
            button.Large,
            None,
            None,
            attrs_disabled,
          ),
          button.button(
            button.Outline,
            "Disabled Icon",
            button.Large,
            Some(lc.check([])),
            None,
            attrs_disabled,
          ),
        ]),
      ]),
      DocSection("form-types", "Form Types", [
        h.div([a.class("button-grid")], [
          button.button_submit("Submit"),
          button.button(
            button.Primary,
            "Reset",
            button.Large,
            None,
            None,
            button.ButtonExtraAttrs(
              False,
              Some(button.Reset),
              button.default_aria,
            ),
          ),
        ]),
      ]),
      DocSection("accessibility", "Accessibility (ARIA)", [
        h.div([a.class("button-grid")], [
          button.button(
            button.Primary,
            "Save",
            button.Large,
            None,
            None,
            attrs_aria_label,
          ),
        ]),
      ]),
      DocSection("anchor", "Anchor (Navigation)", [
        h.div([a.class("button-grid")], [
          button.button_primary_anchor("Primary Link", "#"),
          button.button_secondary_anchor("Secondary Link", "#"),
          button.button_outline_anchor("Outline Link", "#"),
          button.button_ghost_anchor("Ghost Link", "#"),
          button.button_anchor(
            button.Primary,
            "With Icon",
            button.Large,
            Some(lc.circle_arrow_right([])),
            "#",
            button.default_extra_attrs,
          ),
          button.button_anchor(
            button.Outline,
            "Disabled",
            button.Large,
            None,
            "#",
            button.ButtonExtraAttrs(True, None, button.default_aria),
          ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/button",
          "",
          "// Action buttons — use <button>",
          "button.button_primary(\"Save\", UserClickSave)",
          "button.button_outline(\"Cancel\", UserClickCancel)",
          "button.button_submit(\"Submit\")",
          "button.button_close(UserClickClose)",
          "",
          "// Navigation — use <a href>",
          "button.button_primary_anchor(\"Docs\", \"/docs\")",
          "button.button_outline_anchor(\"GitHub\", \"https://github.com/...\")",
          "button.button_anchor(Primary, \"Read more\", Large, None, \"/blog\", button.default_extra_attrs)",
        ]),
      ]),
      DocSection("Test", "Test", [
        element.fragment([
          saolabutton.render(saolabutton.ButtonConfig(
            button_type: saolabutton.HtmlButton,
            text: "Gửi biểu mẫu",
            class_names: "btn btn-lg-primary",
          )),

          // Nút loại 2: Thẻ <a> (Link) dẫn sang trang khác
          saolabutton.render(saolabutton.ButtonConfig(
            button_type: saolabutton.HtmlLink(href: "https://gleam.run"),
            text: "Đọc tài liệu",
            class_names: "btn btn-lg-link",
          ))
        ])
      ]),
    ],
  )
}
