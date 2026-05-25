import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

import saola/icon/lx

pub type ButtonVariant {
  Primary
  Secondary
  Outline
  Ghost
  Link
  Destructive
}

pub type ButtonSize {
  Large
  Small
}

pub type ButtonAria {
  ButtonAria(label: String, expanded: Option(Bool))
}

pub type ButtonRoleType {
  /// Render as type='button'
  Regular
  /// Render as type='submit'
  Submit
  /// Render as type='reset'
  Reset
}

pub type ButtonExtraAttrs {
  ButtonExtraAttrs(
    disabled: Bool,
    type_: Option(ButtonRoleType),
    aria: ButtonAria,
  )
}

/// Fully customizable button.
///
/// Example:
/// ```gleam
/// button_full(Primary, "Save", Large, None, Some(UserClickSave), default_extra_attrs)
/// button_full(Outline, "Delete", Large, Some(icon/lt.trash([])), Some(UserClickDelete), default_extra_attrs)
/// ```
pub fn button_full(
  variant: ButtonVariant,
  label: String,
  size: ButtonSize,
  icon: Option(Element(msg)),
  click_message: Option(msg),
  extra_attrs: ButtonExtraAttrs,
) -> Element(msg) {
  let css_name = case size, variant {
    Large, Primary -> "btn-lg-primary"
    Large, Secondary -> "btn-lg-secondary"
    Large, Outline -> "btn-lg-outline"
    Large, Ghost -> "btn-lg-ghost"
    Large, Link -> "btn-lg-link"
    Large, Destructive -> "btn-lg-destructive"
    Small, Primary -> "btn-sm-primary"
    Small, Secondary -> "btn-sm-secondary"
    Small, Outline -> "btn-sm-outline"
    Small, Ghost -> "btn-sm-ghost"
    Small, Link -> "btn-sm-link"
    Small, Destructive -> "btn-sm-destructive"
  }
  let event_handler =
    click_message |> option.map(e.on_click) |> option.unwrap(a.none())
  let icon_el = option.unwrap(icon, element.none())
  let label_el = case string.trim(label) {
    "" -> element.none()
    text -> h.text(text)
  }
  let disabled_attr = case extra_attrs.disabled {
    True -> a.disabled(True)
    False -> a.none()
  }
  let type_attr = case extra_attrs.type_ {
    None -> a.none()
    Some(Regular) -> a.type_("button")
    Some(Submit) -> a.type_("submit")
    Some(Reset) -> a.type_("reset")
  }
  let aria_label_attr = case extra_attrs.aria.label {
    "" -> a.none()
    l -> a.aria_label(l)
  }
  let aria_expanded_attr = case extra_attrs.aria.expanded {
    None -> a.none()
    Some(expanded) -> a.aria_expanded(expanded)
  }
  h.button(
    [
      a.class(css_name),
      event_handler,
      disabled_attr,
      type_attr,
      aria_label_attr,
      aria_expanded_attr,
    ],
    [icon_el, label_el],
  )
}

// --- Default values ---

pub const default_aria = ButtonAria("", None)

pub const default_extra_attrs = ButtonExtraAttrs(False, None, default_aria)

// --- Convenience shortcuts ---

pub fn button_primary(label: String, click_message: msg) -> Element(msg) {
  button_full(Primary, label, Large, None, Some(click_message), default_extra_attrs)
}

pub fn button_secondary(label: String, click_message: msg) -> Element(msg) {
  button_full(Secondary, label, Large, None, Some(click_message), default_extra_attrs)
}

pub fn button_outline(label: String, click_message: msg) -> Element(msg) {
  button_full(Outline, label, Large, None, Some(click_message), default_extra_attrs)
}

pub fn button_ghost(label: String, click_message: msg) -> Element(msg) {
  button_full(Ghost, label, Large, None, Some(click_message), default_extra_attrs)
}

pub fn button_destructive(label: String, click_message: msg) -> Element(msg) {
  button_full(Destructive, label, Large, None, Some(click_message), default_extra_attrs)
}

/// Submit button (type="submit"). Use inside a <form>.
pub fn button_submit(label: String) -> Element(msg) {
  button_full(
    Primary,
    label,
    Large,
    None,
    None,
    ButtonExtraAttrs(False, Some(Submit), default_aria),
  )
}

/// Small icon-only close button (×).
pub fn button_close(click_message: msg) -> Element(msg) {
  button_full(Outline, "", Small, Some(lx.x([])), Some(click_message), default_extra_attrs)
}
