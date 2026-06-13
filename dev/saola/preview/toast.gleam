import gleam/option
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/button
import saola/preview/model.{
  type Message, type Model, AddToast, DismissToast, StartedTrial,
}
import saola/preview/view/doc_page.{DocSection}
import saola/toast

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Toasts",
    "Transient notifications. The consumer manages the list in their model.",
    [
      DocSection("demo", "Demo", [
        h.div([], [
          h.div([a.class("flex gap-3 flex-wrap mt-4")], [
            button.button_primary(
              "Default",
              AddToast(toast.new_toast_simple(
                "Saved!",
                "Your changes have been saved.",
                toast.Default,
              )),
            ),
            button.button_secondary(
              "Destructive",
              AddToast(toast.new_toast_simple(
                "Error",
                "Could not save changes.",
                toast.Destructive,
              )),
            ),
            button.button_secondary(
              "Success",
              AddToast(toast.new_toast_simple(
                "Success",
                "Operation completed.",
                toast.Success,
              )),
            ),
            button.button_secondary(
              "Warning",
              AddToast(toast.new_toast_simple(
                "Warning",
                "This action may have side effects.",
                toast.Warning,
              )),
            ),
            button.button_secondary(
              "Info",
              AddToast(toast.new_toast_simple(
                "Info",
                "Here is some useful information.",
                toast.Info,
              )),
            ),
            button.button_secondary(
              "With Action",
              AddToast(toast.new_toast(
                "Start your trial",
                "Get 14 days of Pro features free.",
                toast.Default,
                option.Some(toast.ToastAction("Start trial", StartedTrial)),
              )),
            ),
          ]),
          toast.toaster(model.toasts, DismissToast),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/toast",
          "import gleam/option",
          "",
          "// In your model: toasts: List(toast.Toast)",
          "toast.new_toast_simple(\"Saved!\", \"Your changes.\", toast.Default)",
          "toast.toaster(model.toasts, DismissToast)",
        ]),
      ]),
    ],
  )
}
