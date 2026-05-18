import lustre/attribute.{type Attribute} as a
import lustre/effect.{type Effect}

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

/// Returns an Effect that registers a one-time OS dark-mode listener.
/// Pass `is_system_active: True` when your app is in System theme mode.
/// The listener persists for the page lifetime and fires `to_msg` on OS preference changes.
pub fn theme_sub(is_system_active: Bool, to_msg: fn(Bool) -> msg) -> Effect(msg) {
  case is_system_active {
    False -> effect.none()
    True -> {
      use dispatch <- effect.from
      do_media_query_sub("(prefers-color-scheme: dark)", fn(is_dark) {
        dispatch(to_msg(is_dark))
      })
    }
  }
}

/// Returns the current OS dark-mode preference. Safe to call at init time.
@external(javascript, "./theme_ffi.mjs", "getCurrentDarkMode")
pub fn get_system_dark() -> Bool

@external(javascript, "./theme_ffi.mjs", "mediaQuerySub")
fn do_media_query_sub(query: String, callback: fn(Bool) -> Nil) -> Nil
