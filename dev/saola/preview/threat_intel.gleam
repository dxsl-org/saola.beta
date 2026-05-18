import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e
import saola/badge
import saola/canvas_command as canvas
import saola/data_table
import saola/empty
import saola/entity_graph_canvas as egc
import saola/multiselect
import saola/progress
import saola/search
import saola/timeline
import saola/preview/model.{
  type Model, type Msg, ThreatEntityDeselected, ThreatEntitySelected,
  ThreatFiltersCleared, ThreatGraphPanned, ThreatGraphZoomed,
  ThreatSearchChanged, ThreatSearchCleared, ThreatSeverityFilterChanged,
  ThreatTablePageChanged, ThreatTableRowSelected, ThreatTableSortChanged,
}
import saola/preview/threat_intel_data.{type ThreatActor}

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

pub fn view_threat_intel_network(model: Model) -> Element(Msg) {
  h.div(
    [a.class("threat-intel-root")],
    [
      left_sidebar(model),
      center_graph(model),
      right_panel(model),
    ],
  )
}

// ---------------------------------------------------------------------------
// Left sidebar — search + severity filter + metrics
// ---------------------------------------------------------------------------

fn left_sidebar(model: Model) -> Element(Msg) {
  let actors = threat_intel_data.all_actors()
  h.div(
    [a.class("threat-intel-sidebar")],
    [
      h.div(
        [a.class("threat-intel-section")],
        [
          search.search_full(
            search.Small,
            model.threat_search,
            ThreatSearchChanged,
            Some(ThreatSearchCleared),
            search.SearchAttrs(
              placeholder: "Search actors…",
              disabled: False,
              name: "",
              class: "",
            ),
          ),
        ],
      ),
      h.div(
        [a.class("threat-intel-section")],
        [
          h.p([a.class("threat-intel-label")], [h.text("Severity")]),
          multiselect.multiselect_full(
            threat_intel_data.all_severity_options(),
            model.threat_severity_filter,
            ThreatSeverityFilterChanged,
            multiselect.default_attrs(),
          ),
        ],
      ),
      h.div(
        [a.class("threat-intel-section")],
        [
          h.p([a.class("threat-intel-label")], [h.text("Metrics")]),
          metric_row("Critical", count_by_severity(actors, "critical"), badge.Destructive),
          metric_row("High", count_by_severity(actors, "high"), badge.Default),
          metric_row("Medium", count_by_severity(actors, "medium"), badge.Secondary),
          metric_row("Low", count_by_severity(actors, "low"), badge.Outline),
        ],
      ),
      case model.threat_severity_filter != []
        || model.threat_search != ""
        || model.threat_selected_ids != []
      {
        False -> element.none()
        True ->
          h.button(
            [a.type_("button"), a.class("btn btn-ghost btn-sm"), e.on_click(ThreatFiltersCleared)],
            [h.text("✕ Clear filters")],
          )
      },
    ],
  )
}

fn metric_row(label: String, count: Int, variant: badge.BadgeVariant) -> Element(Msg) {
  h.div(
    [a.class("threat-metric-row")],
    [
      badge.badge(label, variant),
      h.span([a.class("threat-metric-count")], [h.text(int.to_string(count))]),
      progress.progress_full(
        count,
        progress.ProgressAttrs(
          min: 0,
          max: 30,
          variant: progress.Default,
          label: label,
          class: "threat-metric-bar",
        ),
      ),
    ],
  )
}

fn count_by_severity(actors: List(ThreatActor), sev: String) -> Int {
  list.count(actors, fn(a) { threat_intel_data.severity_label(a.severity) == sev })
}

// ---------------------------------------------------------------------------
// Center — entity graph canvas
// ---------------------------------------------------------------------------

fn center_graph(model: Model) -> Element(Msg) {
  h.div(
    [a.class("threat-intel-graph-panel")],
    [
      h.p([a.class("threat-intel-panel-title")], [h.text("Threat Actor Network")]),
      case model.threat_graph_layout_done {
        False ->
          h.div([a.class("threat-intel-loading")], [h.text("Computing layout…")])
        True -> render_graph(model)
      },
      case model.threat_graph_hovered {
        None -> element.none()
        Some(id) ->
          case threat_intel_data.find_actor(id) {
            None -> element.none()
            Some(actor) ->
              h.div(
                [a.class("threat-intel-hover-label")],
                [
                  h.text(actor.name <> " · "),
                  badge.badge(
                    threat_intel_data.severity_label(actor.severity),
                    severity_badge_variant(actor.severity),
                  ),
                ],
              )
          }
      },
    ],
  )
}

fn render_graph(model: Model) -> Element(Msg) {
  let nodes = list.map(threat_intel_data.all_actors(), actor_to_node)
  let edges = list.map(threat_intel_data.all_edges(), edge_to_graph_edge)
  let dimmed =
    case model.threat_severity_filter {
      [] -> []
      filter ->
        list.filter_map(threat_intel_data.all_actors(), fn(actor) {
          case list.contains(filter, threat_intel_data.severity_label(actor.severity)) {
            True -> Error(Nil)
            False -> Ok(actor.id)
          }
        })
    }
  let attrs =
    egc.EntityGraphCanvasAttrs(
      width: 560.0,
      height: 420.0,
      pan: model.threat_graph_pan,
      zoom: model.threat_graph_zoom,
      selected_ids: model.threat_selected_ids,
      dimmed_ids: dimmed,
    )
  let output =
    egc.entity_graph_canvas(
      nodes,
      edges,
      model.threat_graph_positions,
      attrs,
      Some(fn(id) { ThreatEntitySelected(id) }),
    )
  egc.entity_graph_element(
    output,
    fn(x, y) {
      case canvas.hit_test(output.hit_areas, x, y) {
        Some(msg) -> msg
        None -> ThreatEntityDeselected
      }
    },
    fn(dx, dy) { ThreatGraphPanned(dx, dy) },
    fn(delta) { ThreatGraphZoomed(delta) },
  )
}

fn actor_to_node(actor: ThreatActor) -> egc.GraphNode {
  egc.GraphNode(id: actor.id, label: actor.name, group: threat_intel_data.severity_label(actor.severity))
}

fn edge_to_graph_edge(te: threat_intel_data.ThreatEdge) -> egc.GraphEdge {
  egc.GraphEdge(id: te.id, source: te.source, target: te.target, label: te.label)
}

// ---------------------------------------------------------------------------
// Right panel — DataTable + Timeline
// ---------------------------------------------------------------------------

fn right_panel(model: Model) -> Element(Msg) {
  h.div(
    [a.class("threat-intel-right-panel")],
    [
      h.div(
        [a.class("threat-intel-table-section")],
        [
          h.p([a.class("threat-intel-panel-title")], [h.text("Threat Actors")]),
          actor_table(model),
        ],
      ),
      h.div(
        [a.class("threat-intel-timeline-section")],
        [
          h.p([a.class("threat-intel-panel-title")], [
            h.text(case model.threat_timeline_entity {
              None -> "Timeline — select an actor"
              Some(id) ->
                case threat_intel_data.find_actor(id) {
                  None -> "Timeline"
                  Some(actor) -> "Timeline — " <> actor.name
                }
            }),
          ]),
          timeline_panel(model),
        ],
      ),
    ],
  )
}

fn actor_table(model: Model) -> Element(Msg) {
  let rows = sorted_filtered_actors(model)
  case rows {
    [] ->
      empty.empty_full(
        media: None,
        media_variant: empty.Default,
        title: "No actors match",
        description: [h.text("Adjust the severity filter or search query.")],
        content: [],
        attrs: empty.default_attrs,
      )
    _ ->
      data_table.data_table_full(
        actor_columns(),
        rows,
        model.threat_table_state,
        ThreatTableSortChanged,
        fn(_q) { ThreatFiltersCleared },
        ThreatTablePageChanged,
        ThreatTableRowSelected,
        fn(actor: ThreatActor) { actor.id },
        data_table.DataTableAttrs(show_filter: False, show_pagination: True, class: ""),
      )
  }
}

fn actor_columns() -> List(data_table.DataTableColumn(ThreatActor, Msg)) {
  [
    data_table.DataTableColumn(
      header: "Name",
      cell: fn(actor: ThreatActor) { h.text(actor.name) },
      sort_key: Some("name"),
    ),
    data_table.DataTableColumn(
      header: "Severity",
      cell: fn(actor: ThreatActor) {
        badge.badge(
          threat_intel_data.severity_label(actor.severity),
          severity_badge_variant(actor.severity),
        )
      },
      sort_key: Some("severity"),
    ),
    data_table.DataTableColumn(
      header: "Country",
      cell: fn(actor: ThreatActor) { h.text(actor.country) },
      sort_key: Some("country"),
    ),
    data_table.DataTableColumn(
      header: "IP",
      cell: fn(actor: ThreatActor) { h.span([a.class("font-mono text-xs")], [h.text(actor.ip)]) },
      sort_key: None,
    ),
    data_table.DataTableColumn(
      header: "Last Seen",
      cell: fn(actor: ThreatActor) { h.text(actor.last_seen) },
      sort_key: Some("last_seen"),
    ),
  ]
}

fn sorted_filtered_actors(model: Model) -> List(ThreatActor) {
  let all = threat_intel_data.all_actors()
  let after_severity = case model.threat_severity_filter {
    [] -> all
    filter ->
      list.filter(all, fn(actor) {
        list.contains(filter, threat_intel_data.severity_label(actor.severity))
      })
  }
  let q = string.lowercase(model.threat_search)
  let after_search = case q {
    "" -> after_severity
    _ ->
      list.filter(after_severity, fn(actor) {
        string.contains(string.lowercase(actor.name), q)
        || string.contains(string.lowercase(actor.country), q)
        || string.contains(actor.ip, q)
      })
  }
  case model.threat_table_state.sort_by {
    option.None -> after_search
    option.Some(key) ->
      list.sort(after_search, fn(a_actor, b_actor) {
        let #(av, bv) = case key {
          "name" -> #(a_actor.name, b_actor.name)
          "country" -> #(a_actor.country, b_actor.country)
          "last_seen" -> #(a_actor.last_seen, b_actor.last_seen)
          "severity" -> #(
            threat_intel_data.severity_label(a_actor.severity),
            threat_intel_data.severity_label(b_actor.severity),
          )
          _ -> #(a_actor.name, b_actor.name)
        }
        case model.threat_table_state.sort_dir {
          data_table.Asc -> string.compare(av, bv)
          data_table.Desc -> string.compare(bv, av)
        }
      })
  }
}

fn timeline_panel(model: Model) -> Element(Msg) {
  case model.threat_timeline_entity {
    None ->
      h.div(
        [a.class("threat-intel-timeline-empty")],
        [h.text("Click an actor in the graph or table to view their event history.")],
      )
    Some(entity_id) -> {
      let events = threat_intel_data.events_for(entity_id)
      let items =
        list.map(events, fn(ev) {
          timeline.TimelineItem(
            time: ev.time,
            title: ev.title,
            description: ev.description,
            icon: None,
            variant: ev.variant,
          )
        })
      timeline.timeline_simple(items)
    }
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn severity_badge_variant(
  sev: threat_intel_data.Severity,
) -> badge.BadgeVariant {
  case sev {
    threat_intel_data.Critical -> badge.Destructive
    threat_intel_data.High -> badge.Default
    threat_intel_data.Medium -> badge.Secondary
    threat_intel_data.Low -> badge.Outline
  }
}
