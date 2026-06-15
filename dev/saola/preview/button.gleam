import gleam/option.{None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

import saola/button
import saola/icon/lc
import saola/preview/model.{type Message, Home, OnRouteChange}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
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
          button.new()
            |> button.variant(button.Link)
            |> button.view("Link", Some(OnRouteChange(Home))),
        ]),
      ]),
      DocSection("with-icon", "With Icon", [
        h.div([a.class("button-grid")], [
          button.new()
            |> button.variant(button.Outline)
            |> button.icon_start(lc.check([]))
            |> button.view("Check", Some(OnRouteChange(Home))),
          button.new()
            |> button.variant(button.Secondary)
            |> button.icon_end(lc.chevron_down([]))
            |> button.aria(button.ButtonAria("Expand menu", Some(True)))
            |> button.view("Menu", Some(OnRouteChange(Home))),
          button.new()
            |> button.variant(button.Primary)
            |> button.icon_end(lc.circle_arrow_right([]))
            |> button.view("Continue", Some(OnRouteChange(Home))),
          button.button_close(OnRouteChange(Home)),
        ]),
      ]),
      DocSection("sizes", "Sizes", [
        h.div([a.class("button-grid")], [
          button.new() |> button.view("Large", None),
          button.new()
            |> button.size(button.Small)
            |> button.view("Small", None),
        ]),
      ]),
      DocSection("loading", "Loading", [
        h.div([a.class("button-grid")], [
          button.new()
            |> button.loading(True)
            |> button.view("Saving", Some(OnRouteChange(Home))),
          button.new()
            |> button.variant(button.Outline)
            |> button.loading(True)
            |> button.view("Loading", None),
        ]),
      ]),
      DocSection("disabled", "Disabled", [
        h.div([a.class("button-grid")], [
          button.new()
            |> button.disabled(True)
            |> button.view("Disabled Primary", None),
          button.new()
            |> button.variant(button.Secondary)
            |> button.disabled(True)
            |> button.view("Disabled Secondary", None),
          button.new()
            |> button.variant(button.Outline)
            |> button.icon_start(lc.check([]))
            |> button.disabled(True)
            |> button.view("Disabled Icon", None),
        ]),
      ]),
      DocSection("form-types", "Form Types", [
        h.div([a.class("button-grid")], [
          button.button_submit("Submit"),
          button.new()
            |> button.type_(button.Reset)
            |> button.view("Reset", None),
        ]),
      ]),
      DocSection("anchor", "Anchor (Navigation)", [
        h.div([a.class("button-grid")], [
          button.button_primary_anchor("Primary Link", "#"),
          button.button_secondary_anchor("Secondary Link", "#"),
          button.button_outline_anchor("Outline Link", "#"),
          button.button_ghost_anchor("Ghost Link", "#"),
          button.new()
            |> button.icon_end(lc.circle_arrow_right([]))
            |> button.view_anchor("With Icon", "#"),
          button.new()
            |> button.variant(button.Outline)
            |> button.disabled(True)
            |> button.view_anchor("Disabled", "#"),
        ]),
      ]),
      DocSection("accessibility", "Accessibility (ARIA)", [
        h.div([a.class("button-grid")], [
          button.new()
            |> button.aria(button.ButtonAria("Save changes", None))
            |> button.view("Save", None),
        ]),
      ]),
      DocSection("accent", "Custom Accent", [
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "accent recolors the solid look by overriding --color-primary inline "
            <> "— Basecoat's hover/focus follow automatically. Pass any CSS color, "
            <> "or a theme token (var(--chart-N)) to stay theme-coherent.",
          ),
        ]),
        h.div([a.class("button-grid")], [
          button.new()
            |> button.accent(button.Accent("var(--chart-2)", "var(--background)"))
            |> button.view("Theme token", Some(OnRouteChange(Home))),
          button.new()
            |> button.accent(button.Accent("oklch(0.55 0.22 263)", "white"))
            |> button.view("Custom oklch", Some(OnRouteChange(Home))),
          button.new()
            |> button.accent(button.Accent("var(--chart-5)", "white"))
            |> button.view_anchor("As anchor", "#"),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/button",
          "",
          "// Shortcuts — 80% of cases",
          "button.button_primary(\"Save\", UserClickSave)",
          "button.button_submit(\"Submit\")",
          "button.button_close(UserClickClose)",
          "",
          "// Builder style — pipe setters, terminal decides <button> vs <a>",
          "button.new()",
          "|> button.variant(button.Outline)",
          "|> button.icon_end(lc.arrow_right([]))",
          "|> button.loading(model.saving)",
          "|> button.view(\"Save\", Some(SaveClicked))",
          "",
          "button.new()",
          "|> button.view_anchor(\"Docs\", \"/docs\")  // <a href> — navigation",
          "",
          "// Config style — record update",
          "button.view(",
          "  button.ButtonConfig(..button.default_config(), loading: model.saving),",
          "  \"Save\",",
          "  Some(SaveClicked),",
          ")",
        ]),
      ]),
      DocSection("customizing", "Customizing Styles", [
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "src/saola/button.css is @generated from Basecoat — do not edit it "
            <> "(just build-css overwrites it). Customize from your own CSS "
            <> "instead, in one of three layers:",
          ),
        ]),
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text("1. Theme tokens — recolor/reshape every widget at once:"),
        ]),
        doc_page.snippet([
          "/* your app.css */",
          ":root {",
          "  --color-primary: oklch(0.55 0.22 263);  /* primary across all widgets */",
          "  --radius-md: 0.25rem;                    /* corner radius */",
          "}",
        ]),
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "2. Per-widget override — target the Basecoat class directly. "
            <> "All Saola CSS lives in @layer saola.*, so any unlayered rule of "
            <> "yours wins — no !important, no specificity battle:",
          ),
        ]),
        doc_page.snippet([
          "/* your app.css — beats @layer saola.components automatically */",
          ".btn-lg-primary {",
          "  background: #ff5722;",
          "  text-transform: uppercase;",
          "}",
        ]),
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "3. One-off, no CSS file — add_class appends a utility/custom class "
            <> "after the variant class:",
          ),
        ]),
        doc_page.snippet([
          "button.new()",
          "|> button.add_class(\"w-full shadow-lg\")",
          "|> button.view(\"Save\", Some(SaveClicked))",
        ]),
      ]),
    ],
  )
}
