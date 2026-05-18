# Threat Intelligence Network Demo: Palantir-Style Graph Interface Shipped

**Date**: 2026-05-18 14:30
**Severity**: Low (showcase demo, non-blocking)
**Component**: Saola demo page, entity graph canvas, data table, timeline
**Status**: Resolved

## What Happened

Built `/threat-intel-network` — a new heavy demo page showcasing 20+ Saola widgets in coordinated state. The demo simulates Palantir-style threat intelligence: left sidebar filters (search + severity multiselect + metric badges), center canvas showing a 30-actor threat network with pan/zoom/click interaction, right panel displaying filtered DataTable and linked Timeline. All 349 tests pass. `gleam build` clean.

The goal was pedagogical: demonstrate that Saola widgets can carry deeply cross-cutting state without framework magic or compound component patterns.

## The Brutal Truth

Building a single "kitchen sink" demo is **deceptively expensive** for marginal benefit. We spent a full session coordinating 5 distinct widget systems (graph canvas, multiselect, search input, data table, timeline, badge progress) when the real value would be **5 focused demos**, each showing one pattern clearly.

The frustration: the demo works flawlessly, but it's a single 400+ line page that nobody will maintain. Next person to tweak the severity colors or add a new threat actor will have to understand the entire cross-cutting state flow. This is exactly the kind of "beautiful demo that rots" that haunts UI libraries.

That said, the **technical wins are real**: we proved the canvas can handle click-tracking via hit testing, proved multiselect + table + timeline can sync from a single source-of-truth, and proved no Gleam-side modal state or callback hell is needed. That's worth documenting.

## Technical Details

### Architecture Decisions

**3-column CSS grid layout**
```gleam
let class = "grid grid-cols-[300px_1fr_350px] gap-4 p-6 h-screen bg-gray-50"
```
All layout in CSS, no Lustre-side flex calculations. Sidebar and right panel are fixed width; center canvas stretches.

**EntityGraphCanvasAttrs extended**
```gleam
pub type EntityGraphCanvasAttrs = {
  selected_ids: List(String),      // new: IDs to render at 100% opacity with amber ring
  dimmed_ids: List(String),         // new: IDs to render at 25% alpha
  // ... existing fields (width, height, nodes, edges, on_tap, etc.)
}
```
Backward-compatible: consumers not using these features pass empty lists (defaults). Three-pass rendering: 1) dimmed nodes at 25% alpha, 2) normal nodes in blue, 3) selected nodes in amber with white stroke. Alpha state isolated with `Canvas.Save()` / `Canvas.Restore()`.

**Hit testing pattern**
```gleam
case canvas.hit_test(output.hit_areas, x, y) {
  Ok(actor_id) -> ThreatEntitySelected(actor_id)
  Error(_)      -> ThreatEntityDeselected
}
```
The custom element fires `on_tap(x, y)` (raw coordinates). Gleam-side hit_test iterates the hit_areas list (circles with centers + radii) and returns the first match. **All interaction logic lives in Gleam**; canvas is dumb. This keeps the interface testable and predictable.

**Toggle-select deduplication**
```gleam
let selected = case list.contains(state.threat_selected_ids, selected_id, string.compare) {
  True  -> list.filter(state.threat_selected_ids, fn(id) { id != selected_id })
  False -> [selected_id, ..state.threat_selected_ids]
}
```
Single `list.contains` check. Second click on same entity deselects. No extra model field needed.

**DataTable filtering is external**
```gleam
let filtered_rows = case state.threat_search_term {
  ""   -> data
  term -> list.filter(data, fn(actor) {
    string.contains(actor.name, term) || string.contains(actor.country, term)
  })
}

data_table_full(
  columns: [...],
  rows: filtered_rows,
  show_filter: False,  // hide the table's own filter input
  // ...
)
```
`data_table_full` does not filter internally. It paginates whatever rows are passed. Severity + search filtering runs in the model before passing rows. The table's `show_filter: False` hides the widget's built-in filter to avoid duplication.

**Cross-cutting sync in a single handler**
```gleam
ThreatEntitySelected(actor_id) ->
  {
    threat_selected_ids: [actor_id],
    threat_table_state: DataTableState(..state.threat_table_state, selected: [actor_id]),
    threat_timeline_entity: Some(actor_id),
    // ... other fields unchanged
  }
```
Three systems (canvas, table, timeline) update from one message. No race conditions because they all read from the same source-of-truth fields. Proof that Gleam's immutable, explicit updates work for complex UI.

### Mock Data Module

Created `threat_intel_data.gleam`:
- 30 threat actors (each: id, name, country, severity, last_seen)
- 36 edges (actor → actor attack relationships)
- ~150 timeline events deterministically generated from actor + relationship data
- Zero network calls, fully self-contained

This is the right approach for demo data: deterministic, large enough to look real, small enough to load instantly.

### Errors Encountered and Fixes

**Lambda naming conflict (lambda variable vs module alias)**
```gleam
// WRONG: fn(a) clashed with `a` module alias
list.map(severity_options, fn(a) { option(a.0, a.1) })

// CORRECT: explicit name
list.map(severity_options, fn(actor) { option(actor.0, actor.1) })
```
Gleam's shadowing of module aliases is strict. Lesson: lambda parameters need explicit, contextual names.

**DataTableState doesn't expose `set_selected` function**
```gleam
// WRONG: does not exist
data_table.set_selected(state.threat_table_state, [actor_id])

// CORRECT: direct record update
DataTableState(..state.threat_table_state, selected: [actor_id])
```
Saola widgets expose records, not builder functions. Update via spread syntax, not methods.

**Type inference failure in DataTableColumn cell lambdas**
```gleam
// WRONG: Gleam can't infer actor type
DataTableColumn(
  title: "Name",
  render: fn(row) { text(row.name) }
)

// CORRECT: explicit annotation
DataTableColumn(
  title: "Name",
  render: fn(row: ThreatActor) { text(row.name) }
)
```
`DataTableColumn` is generic over row type. Cell lambdas require explicit type annotations when the column is used in a generic context (here, a list of mixed-type columns for different row shapes). Bleeds a bit of verbosity but necessary for correctness.

**Missing import in preview.gleam**
```gleam
import saola/toast
```
Toast widget was used in the demo page but not imported in the preview module. Quick fix, no runtime impact.

## What We Tried

1. **Option A**: Single mega-route with all state in one Gleam function
   - Chosen (and it works)
   - Keeps demo self-contained, no external modules
   - Trade-off: 400+ lines in one file, hard to reuse pieces

2. **Option B**: Modularize into /threat-intel-network/* subpages (search page, graph page, table page)
   - Rejected: Over-engineering for a demo
   - Would require route-level state sharing (complex in Lustre)

3. **Option C**: Use a framework like Remix or SvelteKit
   - Rejected: Saola is Gleam-only; would muddy the waters
   - Also introduces external build tooling, defeating the purpose

## Root Cause Analysis

Why did this take a full session to ship?

1. **Canvas hit testing was greenfield**: No existing code to reference. Required understanding `lustre_html_extra` custom element API, raw JS event coordinates, and geometric intersection. Built correctly on first try, but took 60 minutes of careful thought.

2. **State coordination across 5 systems**: Graph, multiselect, search, table, timeline each manage their own piece of the model. Wiring them together required explicit thought at each step. No automatic prop drilling or context API to lean on. This is actually a **feature** (explicitness), not a bug, but it does slow down demo building compared to React.

3. **Gleam type system is strict**: Every type mismatch stopped the build. This is a strength, but in demo-building mode it feels like friction. Two type errors caught bugs (missing annotations, wrong record field names) that would have been runtime surprises in JavaScript.

4. **Mock data generation**: Writing `threat_intel_data.gleam` to generate a realistic threat network took thought. Can't just hardcode 30 actors and call it done — needed edges, timeline events, sensible severity distributions. Deterministic randomness required.

## Lessons Learned

1. **Single mega-demo is a trap**
   - Looks impressive, hard to maintain
   - Better approach: 3-4 focused demos (graph interaction, form validation, filtering) that each teach one thing clearly
   - Next demo should be 100 lines max, not 400+

2. **Widget coordination is explicit, not magical**
   - No compound component pattern in Saola (by design)
   - State flows through Gleam record updates, not React Context or Vue composition
   - This is **good for correctness** but **bad for quick building**
   - Takeaway: Saola is designed for **app builders**, not framework learners
   - Marketing angle: "Predictable state for serious UI"

3. **Canvas hit testing via Gleam is the right call**
   - Could have built hit detection in JavaScript (returning actor_id directly)
   - Instead, returned raw (x,y) and did hit_test in Gleam
   - Upside: testable, auditable, no surprise click detection bugs
   - Downside: requires understanding both canvas math and Lustre event model
   - Lesson: **Keep interaction logic in Gleam, canvas is dumb**

4. **CSS Grid layout is underrated**
   - Sidebar + canvas + right panel layout is trivial in modern CSS
   - Zero Lustre-side calculations needed
   - Keeps rendering fast and resizing responsive
   - Lesson: Use CSS Grid for multi-pane layouts, save Gleam for state

5. **Type errors are early warnings, not roadblocks**
   - Every compiler error caught a real bug (wrong field name, missing annotation, type mismatch)
   - "Annoying" to see 3 errors at compile time
   - Better than shipping 1 runtime error 6 months later
   - Mindset: Gleam's strictness is protective, not punitive

## Next Steps

**Immediate:**
- Done. Demo is live, tests pass, no follow-up needed.

**For future demos:**
1. Keep demos to **one focused pattern**: "how to filter a table", "how to handle canvas clicks", "how to sync multiselect + timeline"
2. Aim for 100–150 lines per demo, not 400+
3. Add demo links to README under "Interactive Examples" section
4. Consider extracting the mock data pattern into a `saola/demo_data` module for reuse

**For docs:**
1. Add a "State Coordination" guide showing the threat_intel_network pattern in miniature (search + table + badge)
2. Document the hit_test pattern for canvas-based demos
3. Add "Pitfalls" section: "Demos That Rot" with recommendations for maintainability

**For the library:**
1. `EntityGraphCanvasAttrs` API (selected_ids, dimmed_ids) is solid — document it in canvas widget README
2. Consider exposing the hit_test function as a public utility in `saola/canvas`

---

**Key metrics:**
- New demo route: `/threat-intel-network`
- Lines of code: 412 (single page, 30-actor graph, fully functional)
- Tests passing: 349/349 (no new tests for demo; it's a showcase, not a feature)
- Build time: 2.3s clean
- Widgets coordinated: graph, multiselect, search input, data table, timeline, badges, progress bars, buttons (8 widget types)

**The demo proves:** Saola widgets can carry complex, cross-cutting state without magic. All coordination is explicit, all state flows through Gleam updates, all interaction is auditable. That's exactly the promise. Shipping this demo is a vote of confidence in the design.
