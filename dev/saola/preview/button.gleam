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
    "Showcase of different button styles, sizes, and states.",
    [
      DocSection("variants", "Variants", [
        h.div([a.class("button-grid")], [
          button.button_primary("Primary", OnRouteChange(Home)),
          button.button_secondary("Secondary", OnRouteChange(Home)),
          button.button_outline("Outline", OnRouteChange(Home)),
          button.button_ghost("Ghost", OnRouteChange(Home)),
          button.button_destructive("Destructive", OnRouteChange(Home)),
          button.button_link("Link", OnRouteChange(Home)),
        ]),
      ]),
      DocSection("with-icon", "With Icon", [
        h.div([a.class("button-grid")], [
          button.new()
            |> button.variant(button.Outline)
            |> button.icon_start(lc.check([]))
            |> button.view("Check", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.variant(button.Secondary)
            |> button.icon_end(lc.chevron_down([]))
            |> button.aria(button.ButtonAria("Expand menu", Some(True)))
            |> button.view("Menu", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.icon_end(lc.circle_arrow_right([]))
            |> button.view("Continue", "", Some(OnRouteChange(Home))),
          button.button_close(OnRouteChange(Home)),
        ]),
      ]),
      DocSection("children-slots", "Children Slots", [
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "before/after take arbitrary children lists (not just one icon). "
            <> "icon_start/icon_end are single-element shortcuts.",
          ),
        ]),
        h.div([a.class("button-grid")], [
          button.new()
            |> button.before([lc.check([]), lc.check([])])
            |> button.after([lc.circle_arrow_right([])])
            |> button.view("Multi", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.variant(button.Outline)
            |> button.after([lc.chevron_down([])])
            |> button.view("After only", "", Some(OnRouteChange(Home))),
        ]),
      ]),
      DocSection("sizes", "Sizes", [
        h.div([a.class("button-grid")], [
          button.new()
            |> button.size(button.Small)
            |> button.view("Small", "", None),
          button.new() |> button.view("Medium (default)", "", None),
          button.new()
            |> button.size(button.Large)
            |> button.view("Large", "", None),
        ]),
      ]),
      DocSection("states", "States", [
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "One mutually-exclusive ButtonState: Idle / Loading / Loaded / "
            <> "Failed / Suspended / Disabled. Suspended is a system hold "
            <> "(checkout), distinct from Disabled. Each emits data-state for "
            <> "styling + transitions.",
          ),
        ]),
        h.div([a.class("button-grid")], [
          button.new()
            |> button.state(button.Loading)
            |> button.view("Loading", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.state(button.Loaded)
            |> button.before([lc.check([])])
            |> button.view("Loaded", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.variant(button.Destructive)
            |> button.state(button.Failed)
            |> button.view("Failed", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.state(button.Suspended)
            |> button.view("Suspended", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.state(button.Disabled)
            |> button.view("Disabled", "", None),
        ]),
      ]),
      DocSection("form-types", "Form Types", [
        h.div([a.class("button-grid")], [
          button.button_submit("Submit"),
          button.new()
            |> button.type_(button.Reset)
            |> button.view("Reset", "", None),
        ]),
      ]),
      DocSection("anchor", "Anchor (Navigation)", [
        h.div([a.class("button-grid")], [
          button.button_primary_anchor("Primary Link", "#"),
          button.button_secondary_anchor("Secondary Link", "#"),
          button.button_outline_anchor("Outline Link", "#"),
          button.button_link_anchor("Link", "#"),
          button.new()
            |> button.icon_end(lc.circle_arrow_right([]))
            |> button.view("With Icon", "#", None),
          button.new()
            |> button.variant(button.Outline)
            |> button.state(button.Disabled)
            |> button.view("Disabled", "#", None),
        ]),
      ]),
      DocSection("accent", "Custom Accent", [
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "accent recolors the solid look by overriding --color-primary inline "
            <> "— Basecoat's hover/focus follow. Pass any CSS color, or a theme "
            <> "token (var(--chart-N)) to stay theme-coherent.",
          ),
        ]),
        h.div([a.class("button-grid")], [
          button.new()
            |> button.accent(button.Accent(
              "var(--chart-2)",
              "var(--background)",
            ))
            |> button.view("Theme token", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.accent(button.Accent("oklch(0.55 0.22 263)", "white"))
            |> button.view("Custom oklch", "", Some(OnRouteChange(Home))),
          button.new()
            |> button.accent(button.Accent("var(--chart-5)", "white"))
            |> button.view("As anchor", "#", None),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/button",
          "",
          "// Shortcuts — 80% of cases",
          "button.button_primary(\"Save\", UserClickSave)",
          "button.button_submit(\"Submit\")",
          "button.button_primary_anchor(\"Docs\", \"/docs\")  // <a href>",
          "",
          "// Builder — view(config, label, href, on_click).",
          "// Empty href -> <button>; non-empty href -> <a>.",
          "button.new()",
          "|> button.variant(button.Outline)",
          "|> button.state(button.Loading)",
          "|> button.view(\"Save\", \"\", Some(SaveClicked))",
          "",
          "// Navigation: just pass the href.",
          "button.new() |> button.view(\"Docs\", \"/docs\", None)",
          "",
          "// Config style — record update",
          "button.view(",
          "  button.ButtonConfig(..button.default_config(), state: button.Loading),",
          "  \"Save\",",
          "  \"\",",
          "  Some(SaveClicked),",
          ")",
        ]),
      ]),
      DocSection("customizing", "Customizing Styles", [
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "src/saola/button.css is @generated from Basecoat — do not edit it. "
            <> "Customize from your own CSS in one of three layers:",
          ),
        ]),
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "1. Theme tokens — recolor/reshape every widget at once:",
          ),
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
          ".btn-primary {", "  background: #ff5722;",
          "  text-transform: uppercase;", "}",
        ]),
        h.p([a.class("text-muted-foreground text-sm")], [
          element.text(
            "3. One-off, no CSS file — add_class appends a utility/custom class:",
          ),
        ]),
        doc_page.snippet([
          "button.new()",
          "|> button.add_class(\"w-full shadow-lg\")",
          "|> button.view(\"Save\", \"\", Some(SaveClicked))",
        ]),
      ]),
    ],
  )
}
