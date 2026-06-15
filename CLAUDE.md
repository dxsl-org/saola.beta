# Saola — Coding Rules

## Terminology

Call UI building blocks **widgets**, not *components*. In Lustre, `component` is a heavier construct that carries its own runtime instance. Saola widgets are pure functions.

When this project grows, we will add complex UI elements in the form of (Lustre) *componenent*.

---

## Saola Widget Rules

### 1. Stateless widgets — external state only

Widgets never own mutable state. All state lives in the consumer's Lustre `Model`.

```gleam
// CORRECT: consumer owns open/close state
pub fn dropdown_menu(is_open: Bool, on_close: fn() -> msg, ...) -> Element(msg)

// WRONG: do not keep is_open inside the widget
```

### 2. Full-options form + convenience shortcuts

Every widget exposes:
- A **full-options form** — the dual-style `Config` pattern (rule 8): `new()` + setters + typed `view` terminal(s). This is the **universal** form for every widget, trivial or complex — one mental model across the whole library (`widget.new() |> widget.x(..) |> widget.view(data)`).
- Shortcut functions for common cases (`widget_primary`, `widget_simple`, etc.) — the ergonomic path, especially for trivial widgets.

Shortcuts delegate to the full-options form using defaults.

```gleam
pub fn button_primary(label: String, click_message: msg) -> Element(msg) {
  new() |> view(label, Some(click_message))
}
```

### 3. Default values

Use `pub const default_*` for records whose fields are all scalar (String, Bool, Int, Option of scalar).

Use `pub fn default_*() -> T` (a function) for records that contain `Element(msg)` or any polymorphic field — because `pub const` cannot hold generic types.

### 4. Widget `Attrs` types — LEGACY, migrating to `Config`

> **Standard change (uniform API):** `Attrs` records and flat positional forms are **legacy**. The target is the dual-style `Config` pattern (rule 8) for **every** widget — one mental model across the library. Do **not** add new `Attrs` types; new widgets ship as `Config` from the start, and existing `Attrs`/flat widgets are being migrated.

For historical context: `Attrs` was introduced to bundle 4+ positional params into one record. That goal is now served by `Config` (which also gives builder + record-update syntax and typed terminals). When you touch an `Attrs`/flat widget, migrate it to `Config` rather than extending the old shape.

### 5. Form inputs — InitValue / SyncValue

Form inputs expose a two-mode ADT for value binding:

```gleam
pub type InputValue {
  InitValue(String)  // seeds default_value once — use with `formal` library
  SyncValue(String)  // kept in sync with model — use for controlled inputs
}
```

`InitValue` maps to `a.default_value`, `SyncValue` maps to `a.value`.

### 6. Variants as ADTs

Use Gleam ADTs for visual variants, never magic strings.

```gleam
pub type BadgeVariant { Default | Secondary | Destructive | Outline }
```

### 7. CSS — Basecoat class names, string concatenation

Derive class names from [Basecoat](https://basecoatui.com) directly. Build with string concatenation; no `cn()` utility is needed.

```gleam
let class = case variant {
  Default     -> "alert"
  Destructive -> "alert alert-destructive"
}
```

### 8. Widget API style — dual-style `Config` for EVERY widget (uniform)

**Every widget** — trivial or complex — uses the **dual-style `Config` pattern**: one public record consumed through two equivalent syntaxes, plus shortcuts on top. This is the single mental model across the whole library; there is no per-widget "is this flat or Config?" decision to remember. Reference implementation: `saola/button`.

```gleam
// Builder style — pipe setters
button.new()
|> button.variant(button.Outline)
|> button.loading(model.saving)
|> button.view("Save", Some(SaveClicked))

// Config style — record update
button.view(
  button.ButtonConfig(..button.default_config(), loading: model.saving),
  "Save",
  Some(SaveClicked),
)

// Shortcut — the ergonomic path (always available, esp. for trivial widgets)
button.button_primary("Save", SaveClicked)
```

```gleam
// Builder style — pipe setters
button.new()
|> button.variant(button.Outline)
|> button.state(button.Loading)
|> button.view("Save", "", Some(SaveClicked))

// Config style — record update
button.view(
  button.ButtonConfig(..button.default_config(), state: button.Loading),
  "Save",
  "",
  Some(SaveClicked),
)
```

Pattern contract:
- One **public** (not opaque) `WidgetConfig(msg)` record — public so record-update syntax works for consumers.
- `new()` (builder entry) and `default_config()` (record-update entry) both return the defaults; each setter is one line of record update.
- The `Config` holds **presentation options only**. Required data lives in **terminal `view(...)` parameters**, not setters (keeps required data un-defaultable and render decisions explicit).
- **Render target**, when a widget can render as more than one element, is decided by a terminal **parameter**, not separate terminals: `button` takes an `href` string — non-empty → `<a href>`, empty → `<button>` — so conditional `<a>`-vs-`<button>` is one call. (This supersedes the earlier two-terminal `view`/`view_anchor` design.)
- Shortcuts (rule 2) are implemented as `new() |> ... |> view(...)`.

A `view()` that infers the element from which *setters* were called is still banned — the deciding input must be an explicit terminal **parameter** (like `href`), not hidden config state.

**Trivial widgets** (0–1 option, e.g. `kbd`, `separator`, `spinner`) still follow the pattern — `new()` + `view()` (+ a `class` setter if applicable) — even though the shortcut is the path consumers actually use. Uniformity is the point: the cost is authoring-time boilerplate, paid once, in exchange for zero per-widget cognitive load.

### 9. ARIA attributes — explicit, no Radix dependency

- Prefer semantic HTML tags over ARIA attributes (e.g., use `<button>` instead of `<div role="button">`).
- Design widget constructors to accept ARIA attributes relevant to the widget (grouped in a parameter). This helps users learn which attributes are applicable.
- If the design is incomplete, users can manually add ARIA attributes via `lustre/attribute`.

```gleam
a.role("alert")
a.aria_label("Close")
a.aria_expanded(is_open)
a.aria_labelledby(title_id)
```

### 10. Auto-generated IDs

Use `typeid` when an accessible ID is needed but not provided by the consumer:

```gleam
import typeid
let id = typeid.new(prefix: "dlg") |> result.map(typeid.to_string) |> result.unwrap("dlg-fallback")
```

---

## File Naming

### JavaScript / ES module files (`.mjs`)

Use **kebab-case** for all `.mjs` files — hyphens, not underscores.

FFI bridge files follow the Lustre convention and use a **dot separator** before `ffi`:

```
canvas.ffi.mjs          ✓  (FFI bridge file)
graph-layout.ffi.mjs    ✓  (FFI bridge file)
component-helpers.mjs   ✓  (helper module, not an FFI bridge)
canvas_ffi.mjs          ✗
canvas-ffi.mjs          ✗
```

Hyphens are valid in file names and import paths (they appear only in string literals, never as bare identifiers), and are the standard convention for ES modules.

---

## Gleam Type Rules

### 10. Named types over homogeneous tuples

When a tuple has two or more members of the same type, define a custom type instead. Homogeneous tuples like `#(Int, Int, Int)` or `#(Int, Int, Float, Float)` offer no indication of what each position means — callers must remember positional order, and the compiler cannot catch transpositions.

```gleam
// WRONG: members are the same type, order is ambiguous
heatmap_svg_hover: Option(#(Int, Int, Int, Float, Float))

// CORRECT: named fields document intent and prevent transposition
pub type HeatmapHover {
  HeatmapHover(row: Int, col: Int, value: Int, mouse_x: Float, mouse_y: Float)
}
heatmap_svg_hover: Option(HeatmapHover)
```

The exception is short, universally-understood pairs like `#(Float, Float)` for `(x, y)` coordinates — but prefer a named type even there once the tuple grows or appears in multiple places.

---

## Web Component (External Library Wrapper) Rules

### 1. Properties for structured data, attributes for strings

HTML attributes are **always strings**. Use `a.property` for arrays and objects — Lustre's reconciler sets them as native JS properties (`element.propName = value`).

```gleam
// CORRECT: native JS array, no serialization
a.property("series", json.array(data, of: encode_point))

// WRONG: JSON round-trip through a string attribute
a.attribute("data-series", json.array(data, of: encode_point) |> json.to_string)
```

`gleam_json` values (`json.array`, `json.object`, etc.) are bare JS values at runtime — `json.array` compiles to a plain JS array. There is no intermediate wrapper to unwrap.

### 2. JS custom element — property setter, not observedAttributes

Only list **string scalar attributes** in `observedAttributes`. Handle structured data through a JavaScript property setter:

```js
// CORRECT
static observedAttributes = ['chart-title', 'height']

set series(value) {
  this._series = Array.isArray(value) ? value : []
  if (this.isConnected) this.render()
}
```

```js
// WRONG
static observedAttributes = ['data-series']  // can't receive arrays via attributes
```

### 3. Guard isConnected before rendering

Always check `this.isConnected` before rendering in setters and callbacks, because setters can fire before the element is attached to the DOM.

```js
set series(value) {
  this._series = Array.isArray(value) ? value : []
  if (this.isConnected) this.render()  // guard required
}
```

### 4. Custom element naming convention

`{library}-{type}` — examples: `d3-bar-chart`, `codemirror-editor`.

Use the `saola-` prefix only to avoid collision with another registered element of the same name.

### 5. Shadow DOM + template

Use Shadow DOM by default for encapsulation. Define the template once outside the class, clone it in the constructor:

```js
const template = document.createElement('template')
template.innerHTML = `<style>:host { display: block; }</style>...`

class MyElement extends HTMLElement {
  constructor() {
    super()
    this.attachShadow({ mode: 'open' }).append(template.content.cloneNode(true))
  }
}
```

**Exception — canvas-based renderers (Cytoscape.js, sigma.js, raw `<canvas>`):** use light DOM (no `attachShadow`). Shadow DOM breaks canvas mouse event retargeting, causing drag and hover to malfunction (Cytoscape.js bug #3273).

### 6. element.to_string skips properties

`lustre/element.to_string` (used in tests) serializes HTML attributes but **silently skips DOM properties**. Tests cannot assert on property values — assert on attributes and the element tag instead.

```gleam
// CORRECT: assert on attributes only
assert string.contains(html, "saola-d3-bar-chart")
assert string.contains(html, "chart-title=\"Revenue\"")

// WRONG: property "series" will never appear in to_string output
assert string.contains(html, "series=")
```

---

## Widget Documentation DoD

A widget addition or public-API change is NOT complete until:
1. Every public function/type has a `///` doc comment (params, return, errors) — `gleam docs build` must pass.
2. Its preview page in `dev/saola/preview/` uses the `doc_page` scaffold with at least Demo and Usage (snippet) sections.
3. The sidebar entry exists in the correct category group.
