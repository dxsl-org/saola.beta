import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/button
import saola/dialog
import saola/preview/model.{type Message, type Model, CloseDialog, OpenDialog}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page("Dialogs", "Modal dialogs for focused interactions.", [
    DocSection("demo", "Demo", [
      h.div([a.class("mt-4")], [
        button.button_primary("Open Dialog", OpenDialog),
      ]),
      dialog.new()
        |> dialog.description(
          "This action cannot be undone. This will permanently delete your account and remove your data from our servers.",
        )
        |> dialog.footer(
          h.div([a.class("flex gap-2")], [
            button.button_secondary("Cancel", CloseDialog),
            button.button_primary("Continue", CloseDialog),
          ]),
        )
        |> dialog.view(model.is_dialog_open, "Are you sure?", [], CloseDialog),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/dialog",
        "",
        "// model.is_dialog_open : Bool",
        "dialog.new()",
        "|> dialog.description(\"This cannot be undone.\")",
        "|> dialog.footer(confirm_row)",
        "|> dialog.view(model.is_dialog_open, \"Are you sure?\", [], CloseDialog)",
      ]),
    ]),
  ])
}
