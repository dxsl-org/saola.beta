import gleam/string

/// Deploy base path from Vite's BASE_URL ("" in dev, "/saola.beta" on Pages).
/// Always without trailing slash — safe to concatenate with route paths.
@external(javascript, "./event_ffi.mjs", "appBase")
pub fn base() -> String

/// Prefix an app-internal route ("/badges") with the deploy base so links
/// stay inside the base path on GitHub Pages.
pub fn href(route_path: String) -> String {
  base() <> route_path
}

/// Strip the deploy base from a browser path so route matching can use
/// base-independent paths. "/saola.beta/badges" -> "/badges".
pub fn strip(path: String) -> String {
  case base() {
    "" -> path
    base ->
      case string.starts_with(path, base) {
        True ->
          case string.drop_start(path, string.length(base)) {
            "" -> "/"
            rest -> rest
          }
        False -> path
      }
  }
}
