import gleam/option.{None, Some}
import gleam/string
import lustre/element
import lustre/element/html as h
import saola/carousel
import saola/combobox
import saola/navigation_menu
import saola/toast

// --- carousel ---

pub fn carousel_simple_renders_test() {
  let slides = [h.div([], [h.text("Slide 1")]), h.div([], [h.text("Slide 2")])]
  let html =
    carousel.carousel_simple(slides, 0, fn(i, p, n) { #(i, p, n) })
    |> element.to_string
  assert string.contains(html, "saola-carousel")
}

pub fn carousel_orientation_attr_test() {
  let html =
    carousel.carousel_full(
      [h.div([], [h.text("S")])],
      0,
      False,
      True,
      fn(i, p, n) { #(i, p, n) },
      carousel.CarouselAttrs(
        orientation: carousel.Vertical,
        loop: False,
        class: "",
      ),
    )
    |> element.to_string
  assert string.contains(html, "orientation=\"vertical\"")
}

pub fn carousel_loop_attr_test() {
  let html =
    carousel.carousel_full(
      [h.div([], [h.text("S")])],
      0,
      False,
      True,
      fn(i, p, n) { #(i, p, n) },
      carousel.CarouselAttrs(
        orientation: carousel.Horizontal,
        loop: True,
        class: "",
      ),
    )
    |> element.to_string
  assert string.contains(html, " loop")
}

pub fn carousel_horizontal_default_test() {
  let html =
    carousel.carousel_simple(
      [h.div([], [h.text("S")])],
      0,
      fn(i, p, n) { #(i, p, n) },
    )
    |> element.to_string
  assert string.contains(html, "orientation=\"horizontal\"")
}

// --- combobox ---

pub fn combobox_closed_renders_trigger_test() {
  let opts = [
    combobox.ComboboxOption(value: "a", label: "Apple"),
    combobox.ComboboxOption(value: "b", label: "Banana"),
  ]
  let html =
    combobox.combobox_simple(opts, None, False, fn(_) { "" }, fn(v) { v })
    |> element.to_string
  assert string.contains(html, "role=\"combobox\"")
  assert string.contains(html, "aria-expanded=\"false\"")
  assert string.contains(html, "Select...")
}

pub fn combobox_open_renders_panel_test() {
  let opts = [combobox.ComboboxOption(value: "a", label: "Apple")]
  let html =
    combobox.combobox_simple(opts, None, True, fn(_) { "" }, fn(v) { v })
    |> element.to_string
  assert string.contains(html, "aria-expanded=\"true\"")
  assert string.contains(html, "role=\"listbox\"")
  assert string.contains(html, "Apple")
}

pub fn combobox_selected_shows_label_test() {
  let opts = [
    combobox.ComboboxOption(value: "a", label: "Apple"),
    combobox.ComboboxOption(value: "b", label: "Banana"),
  ]
  let html =
    combobox.combobox_simple(opts, Some("b"), False, fn(_) { "" }, fn(v) { v })
    |> element.to_string
  assert string.contains(html, "Banana")
}

pub fn combobox_selected_option_aria_test() {
  let opts = [combobox.ComboboxOption(value: "x", label: "Xylophone")]
  let html =
    combobox.combobox_simple(opts, Some("x"), True, fn(_) { "" }, fn(v) { v })
    |> element.to_string
  assert string.contains(html, "aria-selected=\"true\"")
}

pub fn combobox_filter_includes_match_test() {
  let opts = [
    combobox.ComboboxOption(value: "a", label: "Apple"),
    combobox.ComboboxOption(value: "b", label: "Banana"),
    combobox.ComboboxOption(value: "c", label: "Cherry"),
  ]
  let result = combobox.combobox_filter(opts, "an")
  assert result == [combobox.ComboboxOption(value: "b", label: "Banana")]
}

pub fn combobox_filter_empty_query_returns_all_test() {
  let opts = [
    combobox.ComboboxOption(value: "a", label: "Apple"),
    combobox.ComboboxOption(value: "b", label: "Banana"),
  ]
  let result = combobox.combobox_filter(opts, "")
  assert result == opts
}

pub fn combobox_filter_case_insensitive_test() {
  let opts = [combobox.ComboboxOption(value: "a", label: "Apple")]
  let result = combobox.combobox_filter(opts, "APPLE")
  assert result == opts
}

pub fn combobox_empty_results_shows_no_results_test() {
  let html =
    combobox.combobox_full(
      [],
      None,
      "zzz",
      True,
      fn(_) { "" },
      fn(q) { q },
      fn(v) { v },
      combobox.default_attrs,
    )
    |> element.to_string
  assert string.contains(html, "No results.")
}

// --- navigation menu ---

pub fn nav_menu_renders_nav_test() {
  let html =
    navigation_menu.navigation_menu_simple(
      [],
      None,
      fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "<nav")
  assert string.contains(html, "nav-menu")
}

pub fn nav_menu_link_renders_test() {
  let html =
    navigation_menu.navigation_menu_simple(
      [
        navigation_menu.NavMenuLink(
          label: "Home",
          href: "/home",
          active: False,
        ),
      ],
      None,
      fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "Home")
  assert string.contains(html, "href=\"/home\"")
}

pub fn nav_menu_active_link_class_test() {
  let html =
    navigation_menu.navigation_menu_simple(
      [
        navigation_menu.NavMenuLink(
          label: "Active",
          href: "/active",
          active: True,
        ),
      ],
      None,
      fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "nav-menu-link-active")
}

pub fn nav_menu_dropdown_closed_test() {
  let html =
    navigation_menu.navigation_menu_simple(
      [
        navigation_menu.NavMenuDropdown(
          label: "Products",
          id: "products",
          content: navigation_menu.NavMenuSimple([#("Widget A", "#")]),
        ),
      ],
      None,
      fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "aria-expanded=\"false\"")
  assert string.contains(html, "aria-haspopup=\"true\"")
  assert !string.contains(html, "Widget A")
}

pub fn nav_menu_dropdown_open_test() {
  let html =
    navigation_menu.navigation_menu_simple(
      [
        navigation_menu.NavMenuDropdown(
          label: "Products",
          id: "products",
          content: navigation_menu.NavMenuSimple([#("Widget A", "#")]),
        ),
      ],
      Some("products"),
      fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "aria-expanded=\"true\"")
  assert string.contains(html, "Widget A")
  assert string.contains(html, "role=\"menu\"")
}

pub fn nav_menu_rich_content_test() {
  let html =
    navigation_menu.navigation_menu_simple(
      [
        navigation_menu.NavMenuDropdown(
          label: "Custom",
          id: "custom",
          content: navigation_menu.NavMenuRich(
            h.div([], [h.text("Rich panel")]),
          ),
        ),
      ],
      Some("custom"),
      fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "Rich panel")
}

// --- toast (new variants) ---

pub fn toast_success_variant_test() {
  let t = toast.new_toast_simple("Done", "All good.", toast.Success)
  let html = toast.toaster([t], fn(id) { id }) |> element.to_string
  assert string.contains(html, "toast-success")
}

pub fn toast_warning_variant_test() {
  let t = toast.new_toast_simple("Warning", "Check this.", toast.Warning)
  let html = toast.toaster([t], fn(id) { id }) |> element.to_string
  assert string.contains(html, "toast-warning")
}

pub fn toast_info_variant_test() {
  let t = toast.new_toast_simple("Info", "FYI.", toast.Info)
  let html = toast.toaster([t], fn(id) { id }) |> element.to_string
  assert string.contains(html, "toast-info")
}

pub fn toast_with_action_renders_test() {
  let t =
    toast.new_toast(
      "Upgrade",
      "Get more features.",
      toast.Default,
      Some(toast.ToastAction("Upgrade now", "clicked")),
    )
  let html = toast.toaster([t], fn(id) { id }) |> element.to_string
  assert string.contains(html, "Upgrade now")
  assert string.contains(html, "data-toast-action")
}

pub fn toast_dismiss_button_renders_test() {
  let t = toast.new_toast_simple("Hi", "Hello.", toast.Default)
  let html = toast.toaster([t], fn(id) { id }) |> element.to_string
  assert string.contains(html, "data-toast-cancel")
}
