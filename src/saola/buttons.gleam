import gleam/option.{type Option, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type ButtonVariant {
  Primary
  Secondary
  // It hold a string of icon name, like "badge-check"
  WithIcon(String)
}

pub type ButtonSize {
  Large
  Small
}

/// Fully customizable button
///
/// Example:
/// ```gleam
/// type Msg {
///    UserClickSubmit
/// }
///
/// button_full(Primary, "Submit", Large, Some(UserClickSubmit))
/// button_full(Secondary, "Pay", Small, None)
/// ```
pub fn button_full(
  variant: ButtonVariant,
  label: String,
  size: ButtonSize,
  // Note: `msg` is lowercase, it is a generic (type parameter)
  click_message: Option(msg),
) -> Element(msg) {
  let css =
    a.class(case size, variant {
      Large, Primary -> "btn-lg-primary"
      Large, Secondary -> "btn-lg-secondary"
      Large, WithIcon(_i) -> "btn-lg-outline"
      Small, Primary -> "btn-sm-primary"
      Small, Secondary -> "btn-sm-secondary"
      Small, WithIcon(_i) -> "btn-sm-outline"
    })
  let event_handler =
    click_message |> option.map(e.on_click) |> option.unwrap(a.none())
  let icon = case variant {
    // Assume that the icon is represented as HTML `<i class='icon-badge-check'></i>`.
    // The implementation may be different, depending on which icon framework we choose.
    WithIcon(icon_name) -> h.i([a.class("icon-" <> icon_name)], [])
    _ -> element.none()
  }
  let label = case string.trim(label) {
    text if text != "" -> h.text(text)
    _ -> element.none()
  }
  h.button([css, event_handler], [icon, label])
}

// -- Some common used buttons --

/// Create a primary button.
/// 
/// Example:
/// ```gleam
/// type Msg {
///    UserClickSave
/// }
/// 
/// button_primary(UserClickSave)
/// ```
/// 
pub fn button_primary(label: String, click_message: msg) -> Element(msg) {
  button_full(Primary, label, Large, Some(click_message))
}

pub fn button_close(click_message: msg) -> Element(msg) {
  button_full(WithIcon("close"), "", Small, Some(click_message))
}
