import gleam/option.{None, Some}
import gleam/string
import lustre/element
import saola/alert
import saola/badge
import saola/button
import saola/card
import saola/kbd
import saola/label
import saola/separator

// --- badge ---

pub fn badge_default_renders_test() {
  let html = badge.badge_default("New") |> element.to_string
  assert string.contains(html, "New")
  assert string.contains(html, "class=\"badge\"")
}

pub fn badge_secondary_renders_test() {
  let html = badge.badge_secondary("Beta") |> element.to_string
  assert string.contains(html, "badge-secondary")
}

pub fn badge_destructive_renders_test() {
  let html = badge.badge_destructive("Error") |> element.to_string
  assert string.contains(html, "badge-destructive")
}

pub fn badge_outline_renders_test() {
  let html = badge.badge_outline("Draft") |> element.to_string
  assert string.contains(html, "badge-outline")
}

// --- alert ---

pub fn alert_default_renders_test() {
  let html = alert.alert_default("Something happened.") |> element.to_string
  assert string.contains(html, "role=\"alert\"")
  assert string.contains(html, "Something happened.")
  assert string.contains(html, "class=\"alert\"")
}

pub fn alert_destructive_renders_test() {
  let html =
    alert.alert_destructive("Error", "Cannot save.") |> element.to_string
  assert string.contains(html, "alert-destructive")
  assert string.contains(html, "Error")
  assert string.contains(html, "Cannot save.")
}

pub fn alert_full_with_title_renders_test() {
  let html =
    alert.alert(
      alert.Default,
      title: "Heads up!",
      description: "A change was made.",
      icon: None,
    )
    |> element.to_string
  assert string.contains(html, "Heads up!")
  assert string.contains(html, "A change was made.")
  assert string.contains(html, "<h2")
}

// --- button ---

pub fn button_primary_renders_test() {
  let html = button.button_primary("Save", Nil) |> element.to_string
  assert string.contains(html, "btn-lg-primary")
  assert string.contains(html, "Save")
  assert string.contains(html, "<button")
}

pub fn button_secondary_renders_test() {
  let html = button.button_secondary("Cancel", Nil) |> element.to_string
  assert string.contains(html, "btn-lg-secondary")
}

pub fn button_outline_renders_test() {
  let html = button.button_outline("Edit", Nil) |> element.to_string
  assert string.contains(html, "btn-lg-outline")
}

pub fn button_destructive_renders_test() {
  let html = button.button_destructive("Delete", Nil) |> element.to_string
  assert string.contains(html, "btn-lg-destructive")
}

pub fn button_submit_has_type_submit_test() {
  let html = button.button_submit("Send") |> element.to_string
  assert string.contains(html, "type=\"submit\"")
  assert string.contains(html, "Send")
}

pub fn button_disabled_renders_test() {
  let html =
    button.new()
    |> button.disabled(True)
    |> button.view("Save", None)
    |> element.to_string
  assert string.contains(html, "disabled")
}

pub fn button_with_aria_label_renders_test() {
  let html =
    button.new()
    |> button.variant(button.Ghost)
    |> button.size(button.Small)
    |> button.aria(button.ButtonAria("Close dialog", None))
    |> button.view("", None)
    |> element.to_string
  assert string.contains(html, "aria-label=\"Close dialog\"")
}

pub fn button_small_renders_test() {
  let html =
    button.new()
    |> button.variant(button.Secondary)
    |> button.size(button.Small)
    |> button.view("Edit", Some(Nil))
    |> element.to_string
  assert string.contains(html, "btn-sm-secondary")
}

pub fn button_config_style_renders_test() {
  let html =
    button.view(
      button.ButtonConfig(..button.default_config(), disabled: True),
      "Save",
      None,
    )
    |> element.to_string
  assert string.contains(html, "btn-lg-primary")
  assert string.contains(html, "disabled")
}

pub fn button_loading_renders_spinner_and_busy_test() {
  let html =
    button.new()
    |> button.loading(True)
    |> button.view("Saving", Some(Nil))
    |> element.to_string
  assert string.contains(html, "aria-busy=\"true\"")
  assert string.contains(html, "spinner")
  // Loading stays in the a11y tree: aria-disabled, NOT native disabled.
  assert string.contains(html, "aria-disabled=\"true\"")
  let without_aria = string.replace(html, "aria-disabled", "")
  assert !string.contains(without_aria, "disabled")
}

pub fn button_loading_replaces_icon_start_test() {
  let html =
    button.new()
    |> button.icon_start(element.text("ICONMARK"))
    |> button.loading(True)
    |> button.view("Saving", None)
    |> element.to_string
  assert string.contains(html, "spinner")
  assert !string.contains(html, "ICONMARK")
}

pub fn button_add_class_appends_test() {
  let html =
    button.new()
    |> button.add_class("w-full")
    |> button.view("Save", None)
    |> element.to_string
  assert string.contains(html, "btn-lg-primary w-full")
}

pub fn button_anchor_renders_href_test() {
  let html =
    button.new()
    |> button.variant(button.Outline)
    |> button.view_anchor("Docs", "/docs")
    |> element.to_string
  assert string.contains(html, "<a")
  assert string.contains(html, "href=\"/docs\"")
  assert string.contains(html, "btn-lg-outline")
}

pub fn button_anchor_disabled_uses_aria_test() {
  let html =
    button.new()
    |> button.disabled(True)
    |> button.view_anchor("Docs", "/docs")
    |> element.to_string
  assert string.contains(html, "aria-disabled=\"true\"")
  assert string.contains(html, "tabindex=\"-1\"")
}

// --- card ---

pub fn card_simple_renders_test() {
  let html = card.card_simple("Settings", []) |> element.to_string
  assert string.contains(html, "class=\"card\"")
  assert string.contains(html, "Settings")
}

pub fn card_with_description_renders_test() {
  let html =
    card.card(card.CardAttrs(
      title: "Profile",
      description: "Manage your account.",
      content: [],
      footer: None,
    ))
    |> element.to_string
  assert string.contains(html, "Profile")
  assert string.contains(html, "Manage your account.")
  assert string.contains(html, "<header")
}

pub fn card_with_footer_renders_test() {
  let footer = button.button_primary("Save", Nil)
  let html =
    card.card(card.CardAttrs(
      title: "Account",
      description: "",
      content: [],
      footer: Some(footer),
    ))
    |> element.to_string
  assert string.contains(html, "<footer")
  assert string.contains(html, "Save")
}

pub fn card_empty_header_omitted_test() {
  let html =
    card.card(card.CardAttrs(
      title: "",
      description: "",
      content: [],
      footer: None,
    ))
    |> element.to_string
  assert !string.contains(html, "<header")
}

// --- label ---

pub fn label_for_renders_test() {
  let html = label.label_for("Email", "email-input") |> element.to_string
  assert string.contains(html, "class=\"label")
  assert string.contains(html, "for=\"email-input\"")
  assert string.contains(html, "Email")
}

pub fn label_without_for_renders_test() {
  let html = label.label("Username", "", "") |> element.to_string
  assert string.contains(html, "class=\"label")
  assert string.contains(html, "Username")
  assert !string.contains(html, "for=")
}

// --- separator ---

pub fn separator_renders_test() {
  let html = separator.separator() |> element.to_string
  assert string.contains(html, "<hr")
  assert string.contains(html, "role=\"separator\"")
  assert !string.contains(html, "aria-orientation")
}

pub fn separator_vertical_renders_test() {
  let html = separator.separator_vertical() |> element.to_string
  assert string.contains(html, "aria-orientation=\"vertical\"")
}

// --- kbd ---

pub fn kbd_renders_test() {
  let html = kbd.kbd("⌘K") |> element.to_string
  assert string.contains(html, "<kbd")
  assert string.contains(html, "class=\"kbd\"")
  assert string.contains(html, "⌘K")
}
