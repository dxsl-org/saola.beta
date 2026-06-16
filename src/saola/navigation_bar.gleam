//// Navigation bar widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// navigation_bar.nav_bar_simple(Some(logo), links)                  // shortcut
//// navigation_bar.new()
//// |> navigation_bar.variant(navigation_bar.Sticky)
//// |> navigation_bar.view(Some(logo), links, actions)
//// ```

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// Positioning behaviour: in-flow (`Default`), pinned (`Sticky`), or detached
/// (`Floating`).
pub type NavBarVariant {
  Default
  Sticky
  Floating
}

/// Presentation options for a nav bar. Public for record-update syntax. The
/// logo/links/actions are the required data, passed to `view`.
pub type NavBarConfig {
  NavBarConfig(variant: NavBarVariant, class: String)
}

/// Builder entry point. Defaults: Default variant, no extra class.
pub fn new() -> NavBarConfig {
  NavBarConfig(variant: Default, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> NavBarConfig {
  new()
}

/// Set the variant (Default, Sticky, Floating).
pub fn variant(config: NavBarConfig, variant: NavBarVariant) -> NavBarConfig {
  NavBarConfig(..config, variant: variant)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: NavBarConfig, class: String) -> NavBarConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  NavBarConfig(..config, class: merged)
}

/// Render the nav bar: optional logo, link list, trailing actions.
pub fn view(
  config: NavBarConfig,
  logo: Option(Element(msg)),
  links: List(Element(msg)),
  actions: List(Element(msg)),
) -> Element(msg) {
  let variant_class = case config.variant {
    Default -> "nav-bar"
    Sticky -> "nav-bar nav-bar-sticky"
    Floating -> "nav-bar nav-bar-floating"
  }
  let root_class = case config.class {
    "" -> variant_class
    c -> variant_class <> " " <> c
  }
  let logo_el = case logo {
    None -> element.none()
    Some(l) -> h.div([a.class("nav-bar-logo")], [l])
  }
  let links_el = case links {
    [] -> element.none()
    ls -> h.nav([a.class("nav-bar-links")], ls)
  }
  let actions_el = case actions {
    [] -> element.none()
    acts -> h.div([a.class("nav-bar-actions")], acts)
  }
  h.header([a.class(root_class)], [
    h.div([a.class("nav-bar-inner")], [logo_el, links_el, actions_el]),
  ])
}

// --- Convenience shortcuts ---

/// A default nav bar with a logo and links, no trailing actions.
pub fn nav_bar_simple(
  logo: Option(Element(msg)),
  links: List(Element(msg)),
) -> Element(msg) {
  new() |> view(logo, links, [])
}

/// A single navigation link for use inside the nav bar.
pub fn nav_bar_link(
  href: String,
  label: String,
  is_active: Bool,
) -> Element(msg) {
  let aria_current_attrs = case is_active {
    True -> [a.attribute("aria-current", "page")]
    False -> []
  }
  h.a(
    list.flatten([
      [
        a.href(href),
        a.class(case is_active {
          True -> "nav-bar-link nav-bar-link-active"
          False -> "nav-bar-link"
        }),
      ],
      aria_current_attrs,
    ]),
    [h.text(label)],
  )
}
