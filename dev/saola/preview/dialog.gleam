import gleam/option
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
      dialog.dialog(
        is_open: model.is_dialog_open,
        attrs: dialog.DialogAttrs(
          title: "Are you sure?",
          description: "This action cannot be undone. This will permanently delete your account and remove your data from our servers.",
          content: [],
          footer: option.Some(
            h.div([a.class("flex gap-2")], [
              button.button(
                button.Secondary,
                "Cancel",
                button.Large,
                option.None,
                option.Some(CloseDialog),
                button.default_extra_attrs,
              ),
              button.button(
                button.Primary,
                "Continue",
                button.Large,
                option.None,
                option.Some(CloseDialog),
                button.default_extra_attrs,
              ),
            ]),
          ),
          show_close_button: True,
          on_close: CloseDialog,
        ),
      ),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/dialog",
        "",
        "// model.is_dialog_open : Bool",
        "dialog.dialog(",
        "  is_open: model.is_dialog_open,",
        "  attrs: dialog.DialogAttrs(",
        "    title: \"Are you sure?\",",
        "    description: \"This cannot be undone.\",",
        "    content: [], footer: option.None,",
        "    show_close_button: True,",
        "    on_close: CloseDialog,",
        "  ),",
        ")",
      ]),
    ]),
  ])
}
