import gleam/dict
import gleam/list
import gleam/string
import lustre/element
import saola/code_editor
import saola/dropdown_menu as dm
import saola/lustre_heatmap as hm
import saola/world_map as wm

// ---------------------------------------------------------------------------
// dropdown_menu
// ---------------------------------------------------------------------------

pub fn dropdown_menu_default_renders_container_class_test() {
  let html =
    dm.dropdown_simple(
      items: [dm.Flat(dm.Item("Save"))],
      is_open: False,
      trigger_click: Nil,
    )
    |> element.to_string
  assert string.contains(html, "dropdown-menu")
  assert string.contains(html, "<button")
  assert string.contains(html, "Open")
}

pub fn dropdown_menu_closed_state_aria_hidden_test() {
  let html =
    dm.dropdown_simple(
      items: [dm.Flat(dm.Item("Delete"))],
      is_open: False,
      trigger_click: Nil,
    )
    |> element.to_string
  // Popover should be hidden when closed
  assert string.contains(html, "aria-hidden=\"true\"")
  // Trigger button announces it has a menu popup
  assert string.contains(html, "aria-haspopup=\"menu\"")
}

pub fn dropdown_menu_open_state_aria_hidden_false_test() {
  let html =
    dm.dropdown_simple(
      items: [dm.Flat(dm.Item("Edit"))],
      is_open: True,
      trigger_click: Nil,
    )
    |> element.to_string
  // Popover is visible when open
  assert string.contains(html, "aria-hidden=\"false\"")
}

pub fn dropdown_menu_items_render_with_role_menuitem_test() {
  let html =
    dm.dropdown_simple(
      items: [dm.Flat(dm.Item("Option A")), dm.Flat(dm.Item("Option B"))],
      is_open: True,
      trigger_click: Nil,
    )
    |> element.to_string
  assert string.contains(html, "role=\"menuitem\"")
  assert string.contains(html, "Option A")
  assert string.contains(html, "Option B")
}

pub fn dropdown_menu_separator_renders_test() {
  let html =
    dm.dropdown_simple(
      items: [
        dm.Flat(dm.Item("Save")),
        dm.Flat(dm.Separator),
        dm.Flat(dm.Item("Delete")),
      ],
      is_open: True,
      trigger_click: Nil,
    )
    |> element.to_string
  assert string.contains(html, "role=\"separator\"")
}

pub fn dropdown_menu_group_renders_heading_test() {
  let html =
    dm.dropdown_simple(
      items: [
        dm.Group("Actions", [dm.Item("Save"), dm.Item("Load")]),
      ],
      is_open: True,
      trigger_click: Nil,
    )
    |> element.to_string
  assert string.contains(html, "role=\"group\"")
  assert string.contains(html, "role=\"heading\"")
  assert string.contains(html, "Actions")
}

pub fn dropdown_menu_link_renders_href_test() {
  let html =
    dm.dropdown_simple(
      items: [dm.Flat(dm.Link("Go Home", "/home"))],
      is_open: True,
      trigger_click: Nil,
    )
    |> element.to_string
  assert string.contains(html, "href=\"/home\"")
  assert string.contains(html, "Go Home")
}

pub fn dropdown_menu_custom_trigger_label_test() {
  let html =
    dm.dropdown_with_trigger(
      items: [dm.Flat(dm.Item("Export"))],
      trigger_label: "File Menu",
      is_open: False,
      trigger_click: Nil,
    )
    |> element.to_string
  assert string.contains(html, "File Menu")
  assert string.contains(html, "btn-outline")
}

pub fn dropdown_menu_role_menu_on_list_test() {
  let html =
    dm.dropdown_simple(
      items: [dm.Flat(dm.Item("X"))],
      is_open: True,
      trigger_click: Nil,
    )
    |> element.to_string
  assert string.contains(html, "role=\"menu\"")
}

// ---------------------------------------------------------------------------
// lustre_heatmap — SVG renderer (fully assertable)
// ---------------------------------------------------------------------------

pub fn heatmap_svg_renders_svg_root_test() {
  let data = [hm.HeatmapCell(row: 0, col: 0, value: 0.5)]
  let html =
    hm.heatmap_svg(
      data,
      hm.HeatmapAttrs(rows: 4, cols: 4, cell_size: 10, color_scheme: "blues"),
    )
    |> element.to_string
  assert string.contains(html, "<svg")
  assert string.contains(html, "xmlns=\"http://www.w3.org/2000/svg\"")
}

pub fn heatmap_svg_dimensions_match_attrs_test() {
  // 5 cols × 8 px = 40; 3 rows × 8 px = 24
  let data = [hm.HeatmapCell(row: 0, col: 0, value: 0.0)]
  let html =
    hm.heatmap_svg(
      data,
      hm.HeatmapAttrs(rows: 3, cols: 5, cell_size: 8, color_scheme: "blues"),
    )
    |> element.to_string
  assert string.contains(html, "width=\"40\"")
  assert string.contains(html, "height=\"24\"")
  assert string.contains(html, "viewBox=\"0 0 40 24\"")
}

pub fn heatmap_svg_renders_rect_per_cell_test() {
  let data = [
    hm.HeatmapCell(row: 0, col: 0, value: 0.0),
    hm.HeatmapCell(row: 0, col: 1, value: 1.0),
    hm.HeatmapCell(row: 1, col: 0, value: 0.5),
  ]
  let html =
    hm.heatmap_svg(
      data,
      hm.HeatmapAttrs(rows: 2, cols: 2, cell_size: 6, color_scheme: "blues"),
    )
    |> element.to_string
  assert string.contains(html, "<rect")
  // Three cells → three <rect elements
  assert string.contains(html, "x=\"0\"")
  assert string.contains(html, "x=\"6\"")
}

pub fn heatmap_svg_cell_position_from_col_row_test() {
  // Cell at row=1, col=2, cell_size=10 → x=20, y=10
  let data = [hm.HeatmapCell(row: 1, col: 2, value: 0.3)]
  let html =
    hm.heatmap_svg(
      data,
      hm.HeatmapAttrs(rows: 3, cols: 4, cell_size: 10, color_scheme: "blues"),
    )
    |> element.to_string
  assert string.contains(html, "x=\"20\"")
  assert string.contains(html, "y=\"10\"")
}

pub fn heatmap_svg_color_scheme_reds_in_fill_test() {
  let data = [hm.HeatmapCell(row: 0, col: 0, value: 0.5)]
  let html =
    hm.heatmap_svg(
      data,
      hm.HeatmapAttrs(rows: 1, cols: 1, cell_size: 4, color_scheme: "reds"),
    )
    |> element.to_string
  // The reds scheme produces hsl(4 ...) fills
  assert string.contains(html, "fill=\"hsl(4 ")
}

pub fn heatmap_svg_color_scheme_greens_in_fill_test() {
  let data = [hm.HeatmapCell(row: 0, col: 0, value: 0.5)]
  let html =
    hm.heatmap_svg(
      data,
      hm.HeatmapAttrs(rows: 1, cols: 1, cell_size: 4, color_scheme: "greens"),
    )
    |> element.to_string
  assert string.contains(html, "fill=\"hsl(142 ")
}

pub fn heatmap_svg_empty_data_renders_no_rects_test() {
  let html =
    hm.heatmap_svg(
      [],
      hm.HeatmapAttrs(rows: 2, cols: 2, cell_size: 5, color_scheme: "blues"),
    )
    |> element.to_string
  assert string.contains(html, "<svg")
  assert !string.contains(html, "<rect")
}

// cell_display_value is pure computation — deterministic and bounds-checked
pub fn heatmap_cell_display_value_in_range_test() {
  let v = hm.cell_display_value(3, 7, 42)
  assert v >= 0
  assert v <= 100
}

pub fn heatmap_cell_display_value_deterministic_test() {
  let v1 = hm.cell_display_value(5, 5, 1)
  let v2 = hm.cell_display_value(5, 5, 1)
  assert v1 == v2
}

// Interactive SVG: same structure, check for style attribute
pub fn heatmap_svg_interactive_renders_svg_test() {
  let html =
    hm.heatmap_svg_interactive(
      [hm.HeatmapCell(row: 0, col: 0, value: 0.5)],
      hm.HeatmapAttrs(rows: 2, cols: 2, cell_size: 6, color_scheme: "blues"),
      dict.new(),
      fn(x, y) { #(x, y) },
      fn(x, y) { #(x, y) },
      #(0.0, 0.0),
      fn(x, y) { #(x, y) },
      #(0.0, 0.0),
    )
    |> element.to_string
  assert string.contains(html, "<svg")
  assert string.contains(html, "cursor:crosshair")
}

// ---------------------------------------------------------------------------
// world_map — web-component wrapper (rule 6: tag + string attrs only)
// Properties (markers, arcs, mapWidth, mapHeight) flow via a.property and are
// silently dropped by element.to_string — assert only on the custom element
// tag. Pure helper actors_to_markers is fully assertable.
// ---------------------------------------------------------------------------

pub fn world_map_renders_custom_element_tag_test() {
  let html =
    wm.world_map_element(
      [],
      [],
      wm.default_world_map_attrs,
      fn(id) { id },
      fn(name) { name },
    )
    |> element.to_string
  assert string.contains(html, "saola-world-map")
}

pub fn world_map_empty_children_renders_self_closing_test() {
  let html =
    wm.world_map_element(
      [],
      [],
      wm.default_world_map_attrs,
      fn(id) { id },
      fn(name) { name },
    )
    |> element.to_string
  // No child elements — element has no inner content
  assert !string.contains(html, "</div>")
  assert string.contains(html, "</saola-world-map>")
}

// actors_to_markers — pure computation, no FFI involved
pub fn actors_to_markers_maps_each_actor_test() {
  let actors = [
    #("ip-1", "Beijing", 39.9, 116.4, "high", 5),
    #("ip-2", "Lagos", 6.5, 3.4, "medium", 2),
  ]
  let markers =
    wm.actors_to_markers(
      actors,
      fn(a) { a.0 },
      fn(a) { a.1 },
      fn(a) { a.2 },
      fn(a) { a.3 },
      fn(a) { a.4 },
      fn(a) { a.5 },
      [],
      fn(_a) { False },
    )
  assert list.length(markers) == 2
}

pub fn actors_to_markers_selected_ids_set_selected_field_test() {
  let actors = [#("node-a", "Tokyo", 35.7, 139.7, "critical", 10)]
  let markers =
    wm.actors_to_markers(
      actors,
      fn(a) { a.0 },
      fn(a) { a.1 },
      fn(a) { a.2 },
      fn(a) { a.3 },
      fn(a) { a.4 },
      fn(a) { a.5 },
      ["node-a"],
      fn(_a) { False },
    )
  let assert [marker] = markers
  assert marker.selected == True
}

pub fn actors_to_markers_unselected_id_not_selected_test() {
  let actors = [#("node-b", "Paris", 48.9, 2.3, "low", 1)]
  let markers =
    wm.actors_to_markers(
      actors,
      fn(a) { a.0 },
      fn(a) { a.1 },
      fn(a) { a.2 },
      fn(a) { a.3 },
      fn(a) { a.4 },
      fn(a) { a.5 },
      ["node-a"],
      fn(_a) { False },
    )
  let assert [marker] = markers
  assert marker.selected == False
}

pub fn actors_to_markers_dimmed_fn_applied_test() {
  let actors = [
    #("n1", "London", 51.5, -0.1, "medium", 3),
    #("n2", "Cairo", 30.1, 31.2, "low", 1),
  ]
  let markers =
    wm.actors_to_markers(
      actors,
      fn(a) { a.0 },
      fn(a) { a.1 },
      fn(a) { a.2 },
      fn(a) { a.3 },
      fn(a) { a.4 },
      fn(a) { a.5 },
      [],
      fn(a) { a.0 == "n2" },
    )
  let assert [m1, m2] = markers
  assert m1.dimmed == False
  assert m2.dimmed == True
}

pub fn actors_to_markers_empty_input_returns_empty_list_test() {
  let markers =
    wm.actors_to_markers(
      [],
      fn(a: #(String, String, Float, Float, String, Int)) { a.0 },
      fn(a) { a.1 },
      fn(a) { a.2 },
      fn(a) { a.3 },
      fn(a) { a.4 },
      fn(a) { a.5 },
      [],
      fn(_a) { False },
    )
  assert markers == []
}

pub fn actors_to_markers_preserves_severity_and_connections_test() {
  let actors = [#("svc-x", "Mumbai", 19.1, 72.9, "critical", 42)]
  let markers =
    wm.actors_to_markers(
      actors,
      fn(a) { a.0 },
      fn(a) { a.1 },
      fn(a) { a.2 },
      fn(a) { a.3 },
      fn(a) { a.4 },
      fn(a) { a.5 },
      [],
      fn(_a) { False },
    )
  let assert [marker] = markers
  assert marker.severity == "critical"
  assert marker.connections == 42
  assert marker.label == "Mumbai"
}

// ---------------------------------------------------------------------------
// code_editor — web-component wrapper (rule 6: tag + string attrs only)
// ---------------------------------------------------------------------------

pub fn code_editor_renders_custom_element_tag_test() {
  let html =
    code_editor.editor(attrs: code_editor.default_editor_attrs)
    |> element.to_string
  assert string.contains(html, "saola-codemirror-editor")
}

pub fn code_editor_string_attributes_serialized_test() {
  let html =
    code_editor.editor(attrs: code_editor.EditorAttrs(
      id: "",
      value: "console.log('hi')",
      language: "javascript",
      theme: "vs-dark",
      height: 400,
      read_only: False,
      class: "",
      aria_label: "Code editor",
    ))
    |> element.to_string
  // All these are a.attribute() calls — serialized by to_string
  assert string.contains(html, "language=\"javascript\"")
  assert string.contains(html, "theme=\"vs-dark\"")
  assert string.contains(html, "height=\"400\"")
  // Lustre HTML-encodes single quotes as &#39; in attribute values
  assert string.contains(html, "value=\"console.log(&#39;hi&#39;)\"")
}

pub fn code_editor_read_only_attribute_true_test() {
  let html =
    code_editor.editor(attrs: code_editor.EditorAttrs(
      id: "",
      value: "",
      language: "python",
      theme: "vs-dark",
      height: 300,
      read_only: True,
      class: "",
      aria_label: "Read only editor",
    ))
    |> element.to_string
  assert string.contains(html, "read-only=\"true\"")
}

pub fn code_editor_read_only_attribute_false_test() {
  let html =
    code_editor.editor(attrs: code_editor.default_editor_attrs)
    |> element.to_string
  assert string.contains(html, "read-only=\"false\"")
}

pub fn code_editor_aria_label_attribute_test() {
  let html =
    code_editor.editor(
      attrs: code_editor.EditorAttrs(
        ..code_editor.default_editor_attrs,
        aria_label: "SQL query editor",
      ),
    )
    |> element.to_string
  assert string.contains(html, "aria-label=\"SQL query editor\"")
}

pub fn code_editor_wrapper_class_on_element_test() {
  let html =
    code_editor.editor(attrs: code_editor.default_editor_attrs)
    |> element.to_string
  assert string.contains(html, "saola-codemirror-editor")
}

pub fn code_editor_id_attribute_when_provided_test() {
  let html =
    code_editor.editor(
      attrs: code_editor.EditorAttrs(
        ..code_editor.default_editor_attrs,
        id: "my-editor",
      ),
    )
    |> element.to_string
  assert string.contains(html, "id=\"my-editor\"")
}

pub fn code_editor_no_id_attribute_when_empty_test() {
  let html =
    code_editor.editor(attrs: code_editor.default_editor_attrs)
    |> element.to_string
  assert !string.contains(html, "id=")
}

pub fn code_editor_custom_language_attribute_test() {
  let html =
    code_editor.editor(
      attrs: code_editor.EditorAttrs(
        ..code_editor.default_editor_attrs,
        language: "typescript",
      ),
    )
    |> element.to_string
  assert string.contains(html, "language=\"typescript\"")
}
