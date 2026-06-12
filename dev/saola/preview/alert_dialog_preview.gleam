import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import lustre/event as e
import saola/alert_dialog
import saola/preview/model.{
  type Message, type Model, AlertDialogCancelled, AlertDialogConfirmed,
  AlertDialogOpened,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Alert Dialog",
    "A modal dialog that interrupts the user with important content.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Destructive action")]),
            h.button(
              [
                a.type_("button"),
                a.class("btn btn-destructive"),
                e.on_click(AlertDialogOpened),
              ],
              [text("Delete account")],
            ),
            alert_dialog.alert_dialog_simple(
              model.alert_dialog_open,
              "Are you absolutely sure?",
              "This action cannot be undone. This will permanently delete your account.",
              AlertDialogConfirmed,
              AlertDialogCancelled,
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/alert_dialog",
          "",
          "// model.alert_dialog_open : Bool",
          "alert_dialog.alert_dialog_simple(",
          "  model.alert_dialog_open,",
          "  \"Are you absolutely sure?\",",
          "  \"This action cannot be undone.\",",
          "  Confirmed,",
          "  Cancelled,",
          ")",
        ]),
      ]),
    ],
  )
}
