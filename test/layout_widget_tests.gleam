import gleam/list
import gleam/string
import lustre/element
import lustre/element/html as h
import saola/badge
import saola/button
import saola/dialog
import saola/table
import saola/tabs
import saola/toast
import saola/tooltip

// --- tabs ---

pub fn tabs_simple_renders_tablist_test() {
  let html =
    tabs.tabs_simple(
      items: [
        tabs.Tab("one", "First", h.p([], [h.text("Panel 1")])),
        tabs.Tab("two", "Second", h.p([], [h.text("Panel 2")])),
      ],
      active_id: "one",
      on_tab_change: fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "role=\"tablist\"")
  assert string.contains(html, "role=\"tab\"")
  assert string.contains(html, "role=\"tabpanel\"")
  assert string.contains(html, "First")
  assert string.contains(html, "Second")
}

pub fn tabs_active_has_aria_selected_test() {
  let html =
    tabs.tabs_simple(
      items: [
        tabs.Tab("a", "Alpha", h.text("Content A")),
        tabs.Tab("b", "Beta", h.text("Content B")),
      ],
      active_id: "a",
      on_tab_change: fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "aria-selected=\"true\"")
  assert string.contains(html, "aria-selected=\"false\"")
}

pub fn tabs_panel_ids_linked_test() {
  let html =
    tabs.tabs_simple(
      items: [tabs.Tab("settings", "Settings", h.text("Settings content"))],
      active_id: "settings",
      on_tab_change: fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "id=\"tab-settings\"")
  assert string.contains(html, "id=\"panel-settings\"")
  assert string.contains(html, "aria-controls=\"panel-settings\"")
  assert string.contains(html, "aria-labelledby=\"tab-settings\"")
}

pub fn tabs_inactive_panel_hidden_test() {
  let html =
    tabs.tabs_simple(
      items: [
        tabs.Tab("x", "X", h.text("X content")),
        tabs.Tab("y", "Y", h.text("Y content")),
      ],
      active_id: "x",
      on_tab_change: fn(id) { id },
    )
    |> element.to_string
  assert string.contains(html, "aria-hidden=\"true\"")
  assert string.contains(html, "aria-hidden=\"false\"")
}

// --- dialog ---

pub fn dialog_open_renders_test() {
  let html =
    dialog.new()
    |> dialog.description("Are you sure?")
    |> dialog.show_close_button(False)
    |> dialog.view(True, "Confirm", [], Nil)
    |> element.to_string
  assert string.contains(html, "<dialog")
  assert string.contains(html, "open")
  assert string.contains(html, "class=\"dialog\"")
  assert string.contains(html, "aria-modal=\"true\"")
  assert string.contains(html, "Confirm")
  assert string.contains(html, "Are you sure?")
}

pub fn dialog_closed_has_no_open_attr_test() {
  let html =
    dialog.new()
    |> dialog.show_close_button(False)
    |> dialog.view(False, "Info", [], Nil)
    |> element.to_string
  assert !string.contains(html, " open")
}

pub fn dialog_with_footer_renders_test() {
  let footer = button.button_primary("OK", Nil)
  let html =
    dialog.new()
    |> dialog.footer(footer)
    |> dialog.show_close_button(False)
    |> dialog.view(True, "Warning", [], Nil)
    |> element.to_string
  assert string.contains(html, "<footer")
  assert string.contains(html, "OK")
}

pub fn dialog_with_close_button_renders_test() {
  let html =
    dialog.dialog_simple(
      is_open: True,
      title: "Delete?",
      content: [],
      on_close: Nil,
    )
    |> element.to_string
  // Close button is icon-only (empty label + icon) → square icon variant.
  assert string.contains(html, "btn-sm-icon-outline")
}

// --- toast ---

pub fn toast_new_creates_struct_test() {
  let t =
    toast.new_toast_simple("Saved!", "Your file was saved.", toast.Default)
  assert t.title == "Saved!"
  assert t.description == "Your file was saved."
  assert t.variant == toast.Default
  assert string.starts_with(t.id, "toast")
}

pub fn toaster_renders_container_test() {
  let t = toast.new_toast_simple("Done", "Task complete.", toast.Default)
  let html = toast.toaster([t], fn(id) { id }) |> element.to_string
  assert string.contains(html, "class=\"toaster\"")
  assert string.contains(html, "aria-live=\"polite\"")
  assert string.contains(html, "class=\"toast\"")
  assert string.contains(html, "Done")
  assert string.contains(html, "Task complete.")
}

pub fn toaster_empty_renders_container_test() {
  let html = toast.toaster([], fn(id) { id }) |> element.to_string
  assert string.contains(html, "class=\"toaster\"")
}

pub fn toaster_destructive_renders_test() {
  let t = toast.new_toast_simple("Error", "Failed.", toast.Destructive)
  let html = toast.toaster([t], fn(id) { id }) |> element.to_string
  assert string.contains(html, "toast-destructive")
}

// --- table ---

pub fn table_simple_renders_headers_test() {
  let html =
    table.table_simple(
      headers: ["Name", "Email", "Role"],
      rows: [],
      extra_attrs: table.default_table_attrs,
    )
    |> element.to_string
  assert string.contains(html, "<table")
  assert string.contains(html, "<thead")
  assert string.contains(html, "<th")
  assert string.contains(html, "scope=\"col\"")
  assert string.contains(html, "Name")
  assert string.contains(html, "Email")
}

pub fn table_simple_renders_rows_test() {
  let html =
    table.table_simple(
      headers: ["Plan", "Status"],
      rows: [
        table.TableRow([
          table.TextCell("Starter"),
          table.ElementCell(badge.badge_default("Active")),
        ]),
      ],
      extra_attrs: table.default_table_attrs,
    )
    |> element.to_string
  assert string.contains(html, "<tbody")
  assert string.contains(html, "<tr")
  assert string.contains(html, "<td")
  assert string.contains(html, "Starter")
  assert string.contains(html, "Active")
}

pub fn table_with_caption_renders_test() {
  let html =
    table.table_simple(
      headers: ["X"],
      rows: [],
      extra_attrs: table.TableExtraAttrs("Monthly data", ""),
    )
    |> element.to_string
  assert string.contains(html, "<caption")
  assert string.contains(html, "Monthly data")
}

pub fn table_helper_renders_test() {
  let html =
    table.table(["A", "B"], [["row1a", "row1b"], ["row2a", "row2b"]])
    |> element.to_string
  assert string.contains(html, "row1a")
  assert string.contains(html, "row2b")
}

// --- tooltip ---

pub fn tooltip_attr_renders_test() {
  let html =
    h.button([tooltip.attr("Save the file")], [h.text("Save")])
    |> element.to_string
  assert string.contains(html, "data-tooltip=\"Save the file\"")
}

pub fn tooltip_wrapper_renders_test() {
  let html =
    tooltip.tooltip("Copy link", h.span([], [h.text("Copy")]))
    |> element.to_string
  assert string.contains(html, "data-tooltip=\"Copy link\"")
  assert string.contains(html, "Copy")
}

pub fn tooltip_side_attr_renders_test() {
  let html =
    h.button([tooltip.side_attr(tooltip.Bottom)], [h.text("More")])
    |> element.to_string
  assert string.contains(html, "data-side=\"bottom\"")
}

pub fn tooltip_side_wrapper_renders_test() {
  let html =
    tooltip.tooltip_side("Edit", tooltip.Left, h.span([], [h.text("Edit")]))
    |> element.to_string
  assert string.contains(html, "data-tooltip=\"Edit\"")
  assert string.contains(html, "data-side=\"left\"")
}

pub fn tooltip_all_sides_render_test() {
  let sides = [
    #(tooltip.Top, "top"),
    #(tooltip.Bottom, "bottom"),
    #(tooltip.Left, "left"),
    #(tooltip.Right, "right"),
  ]
  list.each(sides, fn(pair) {
    let #(side, expected) = pair
    let html =
      tooltip.tooltip_side("Tip", side, h.span([], []))
      |> element.to_string
    assert string.contains(html, "data-side=\"" <> expected <> "\"")
  })
}
