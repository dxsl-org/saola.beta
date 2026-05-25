# Display List Canvas Architecture — From JS Blackboxes to Type-Safe Gleam Commands

**Date**: 2026-05-18 14:30
**Severity**: Medium
**Component**: Canvas rendering, graph visualization, bar chart
**Status**: Resolved

## What Happened

Completed a 4-phase architectural overhaul replacing Cytoscape.js and raw D3 blackboxes with a command-pattern renderer. Gleam now owns all visualization logic; JavaScript executes only what Gleam tells it to. 349 tests passing.

## The Brutal Truth

This was the RIGHT architectural move and it hurt exactly how much it should have. Before: every viz widget was a black box. Gleam had zero visibility into layout, scales, hit-testing. That meant bugs lived in JavaScript, type safety evaporated at the library boundary, and testing visualization logic was impossible. Now? Gleam controls everything. The price was four weeks of grinding through custom element plumbing, Worker thread setup, and vector math that wanted trigonometry but didn't need it.

## Technical Details

**Canvas Core** (`canvas_command.gleam`): 30-variant ADT with pure command executor. `HitArea(msg)` wraps RectHit/CircleHit — consumer specifies what message fires on tap/hover/drag. Hit-testing is deterministic Gleam code.

**FFI File Safety**: All `canvas_ffi.mjs` and `graph_layout_ffi.mjs` now guard `typeof document === 'undefined'` at module scope. Prevents Node.js test runner crashes when `customElements.define` fires during import.

**Worker Design**: `graph_layout_worker.js` runs D3 force simulation for 300 ticks, normalizes output to [0,1]. Worker spawned lazily, terminated after each run — not persistent. Routes responses by random ID.

**Bar Chart**: Added `bar_chart_canvas()` parallel to `bar_chart()`. Shared Layout math, bars rendered as CanvasCommands, RectHit per bar. Zero breaking changes — both exist side-by-side.

**Entity Graph**: Migrated from Cytoscape to pure canvas. Circle nodes, line edges with arrowhead geometry. Key insight: perpendicular vector + `float.square_root` normalize direction without `atan2`/`cos`/`sin`. Hit areas in screen-space post–pan/zoom inverse transform.

## Lessons Learned

1. **`json.array` is bare JS at runtime** — use `a.property`, never `a.attribute`, for structured data. Attributes coerce to strings; properties hold native JS values.

2. **Light DOM for canvas** — Shadow DOM breaks mouse event retargeting. Cytoscape.js issue #3273. Accepted the trade-off for correctness.

3. **`list.find_map` signature matters** — gleam_stdlib ≥0.44 requires `Result(b, c)`, not `Option`. Cost us a test cycle.

4. **Hit areas are screen-space** — consumers forget to inverse-transform pan/zoom. Document it in every hit area constructor.

5. **Workers are dumb pipes** — no persistent state. Each layout request is independent. Simpler than managing lifecycle.

## Next Steps

- Monitor performance of bar chart rendering at scale (>1000 bars)
- Consider caching Worker instance if layout requests spike
- Document `CanvasCommand` ADT in architecture guide — developers will need to extend it
- Deprecation path for `entity_graph.gleam` / `bar_chart()` — support both during transition

**Commit:** `51d3b91`
