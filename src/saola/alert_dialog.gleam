//// Alert dialog (confirm/cancel) widget — dual-style `Config` (uniform pattern):
////
//// ```gleam
//// alert_dialog.alert_dialog_simple(model.open, "Delete?", "Permanent.", Yes, No)  // shortcut
//// alert_dialog.new()
//// |> alert_dialog.confirm_label("Delete")
//// |> alert_dialog.cancel_label("Keep")
//// |> alert_dialog.view(model.open, "Delete?", "This is permanent.", Yes, No)
//// ```

import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// Presentation options for an alert dialog. Public for record-update syntax.
/// The `open`/`title`/`description`/`on_confirm`/`on_cancel` are required (`view`).
pub type AlertDialogConfig {
  AlertDialogConfig(confirm_label: String, cancel_label: String, class: String)
}

/// Builder entry point. Defaults: "Confirm"/"Cancel" labels, no extra class.
pub fn new() -> AlertDialogConfig {
  AlertDialogConfig(confirm_label: "Confirm", cancel_label: "Cancel", class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> AlertDialogConfig {
  new()
}

/// Set the confirm button label (default "Confirm").
pub fn confirm_label(config: AlertDialogConfig, label: String) -> AlertDialogConfig {
  AlertDialogConfig(..config, confirm_label: label)
}

/// Set the cancel button label (default "Cancel").
pub fn cancel_label(config: AlertDialogConfig, label: String) -> AlertDialogConfig {
  AlertDialogConfig(..config, cancel_label: label)
}

/// Append an extra CSS class on the dialog. Additive only.
pub fn add_class(config: AlertDialogConfig, class: String) -> AlertDialogConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  AlertDialogConfig(..config, class: merged)
}

/// Render the alert dialog (renders nothing while `open` is False).
pub fn view(
  config: AlertDialogConfig,
  open: Bool,
  title: String,
  description: String,
  on_confirm: msg,
  on_cancel: msg,
) -> Element(msg) {
  case open {
    False -> h.text("")
    True -> {
      let extra_class_attrs = case config.class {
        "" -> []
        c -> [a.class(c)]
      }
      h.div(
        [
          a.class("dialog-overlay"),
          a.attribute("aria-modal", "true"),
          a.role("alertdialog"),
          a.attribute("aria-labelledby", "alert-dialog-title"),
          a.attribute("aria-describedby", "alert-dialog-desc"),
        ],
        [
          h.div(list.flatten([[a.class("dialog")], extra_class_attrs]), [
            h.div([a.class("dialog-header")], [
              h.h2([a.class("dialog-title"), a.id("alert-dialog-title")], [
                h.text(title),
              ]),
              h.p([a.class("dialog-description"), a.id("alert-dialog-desc")], [
                h.text(description),
              ]),
            ]),
            h.div([a.class("dialog-footer")], [
              h.button(
                [
                  a.type_("button"),
                  a.class("btn btn-outline"),
                  e.on_click(on_cancel),
                ],
                [h.text(config.cancel_label)],
              ),
              h.button(
                [
                  a.type_("button"),
                  a.class("btn btn-primary"),
                  e.on_click(on_confirm),
                ],
                [h.text(config.confirm_label)],
              ),
            ]),
          ]),
        ],
      )
    }
  }
}

// --- Convenience shortcuts ---

pub fn alert_dialog_simple(
  open: Bool,
  title: String,
  description: String,
  on_confirm: msg,
  on_cancel: msg,
) -> Element(msg) {
  new() |> view(open, title, description, on_confirm, on_cancel)
}
