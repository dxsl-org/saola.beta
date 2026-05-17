import lustre/attribute.{type Attribute} as a

pub type Theme {
  Light
  Dark
  System
}

/// Returns the attribute to place on the root element to control the color theme.
/// For `System`, the script in index.html handles applying `.dark` based on OS preference.
pub fn theme_attr(theme: Theme) -> Attribute(msg) {
  case theme {
    // Light is the default; basecoat.css defines tokens under :root with no modifier class needed
    Light -> a.none()
    Dark -> a.class("dark")
    // System: handled by the inline script in index.html at page load; no runtime class needed
    System -> a.none()
  }
}
