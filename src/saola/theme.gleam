import lustre/effect.{type Effect}

pub type Theme {
  Light
  Dark
  System
}

pub type OsColorScheme {
  OsDark
  OsLight
}

/// Returns an Effect that registers a one-time OS dark-mode listener.
/// The listener persists for the page lifetime and fires `to_msg` on OS preference changes.
pub fn watch_system_dark(to_msg: fn(OsColorScheme) -> msg) -> Effect(msg) {
  use dispatch <- effect.from
  use is_dark <- do_watch_dark_mode
  dispatch(
    to_msg(case is_dark {
      True -> OsDark
      False -> OsLight
    }),
  )
}

/// Applies the theme by toggling the `dark` class on `<html>`.
pub fn apply_to_html(theme: Theme, os_scheme: OsColorScheme) -> Effect(msg) {
  let is_dark = case theme {
    Dark -> True
    Light -> False
    System ->
      case os_scheme {
        OsDark -> True
        OsLight -> False
      }
  }
  use _dispatch <- effect.from
  do_set_html_theme(is_dark)
}

/// Returns the current OS dark-mode preference. Safe to call at init time.
pub fn is_system_dark() -> OsColorScheme {
  case do_get_current_dark_mode() {
    True -> OsDark
    False -> OsLight
  }
}

@external(javascript, "./theme.ffi.mjs", "getCurrentDarkMode")
fn do_get_current_dark_mode() -> Bool

@external(javascript, "./theme.ffi.mjs", "watchDarkMode")
fn do_watch_dark_mode(callback: fn(Bool) -> Nil) -> Nil

@external(javascript, "./theme.ffi.mjs", "setHtmlTheme")
fn do_set_html_theme(is_dark: Bool) -> Nil
