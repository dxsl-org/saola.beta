# Saola Code Standards

**Last Updated:** 2026-06-12

This document describes the architectural patterns, naming conventions, and code standards that govern Saola development. See also `CLAUDE.md` in the project root for detailed widget API rules.

---

## Overview

Saola enforces:
- **Stateless widgets** — all state owned by the consumer's Lustre `Model`
- **CSS modularity** — per-widget colocated CSS files + layered bundles
- **Accessibility first** — explicit ARIA, semantic HTML, keyboard navigation
- **Type safety** — ADTs for variants, no magic strings
- **Gleam standards** — `gleam format`, `gleam build`, passing tests

---

## Widget API Patterns (from CLAUDE.md)

### 1. Stateless Widgets

Every widget is a pure function returning `Element(msg)`. No internal mutable state.

```gleam
pub fn button(variant: ButtonVariant, size: ButtonSize, label: String, on_click: Option(msg)) -> Element(msg)
```

The consumer's Lustre `Model` owns all state (open/close, selected, errors, etc.).

### 2. Full-Options Form + Shortcut Pattern

Every widget exposes two entry points:

**Full-options form** — flat `widget(...)` for simple widgets, or the dual-style `Config` pattern (§3b) for complex ones.

**Shortcut functions** — sensible defaults for common cases
```gleam
pub fn button_primary(label: String, on_click: msg) -> Element(msg)
pub fn button_secondary(label: String, on_click: msg) -> Element(msg)
```

Shortcuts delegate to the full-options form using `const default_*` (for scalar fields) or `fn default_*()` / `default_config()` (for polymorphic fields).

### 3. Attrs Records (When Justified)

Introduce an `Attrs` type **only** when the full function would take 4+ parameters.

```gleam
pub type DialogAttrs {
  DialogAttrs(description: String, icon: Option(Element(msg)), class: String)
}

pub fn dialog(open: Bool, title: String, attrs: DialogAttrs) -> Element(msg)
```

Provide `pub const default_*` for convenience. Do not wrap everything into Attrs just to reduce parameters.

### 3b. Dual-Style Config Pattern (Complex Widgets)

When a widget accumulates many optional fields (~6+) or has multiple render targets, upgrade from `Attrs` to one public `Config` record consumed through two equivalent syntaxes. Reference implementation: `src/saola/button.gleam`.

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
```

Contract:
- `WidgetConfig(msg)` is **public, not opaque** — record-update syntax must work for consumers.
- `new()` and `default_config()` both return defaults; each setter is one line of record update over the same record.
- The Config holds **presentation options only**. Required data and the render-target decision live in **terminal functions** (`view` → `<button>`, `view_anchor` → `<a>`). `on_click`/`href` are terminal parameters, never setters — this keeps render-as type-safe and unmixable.
- A single `view()` that infers the element from which setters were called is banned.
- Existing flat widgets stay valid; migrate only when option count grows.

### 3c. Custom Accent via CSS-Variable Override (theme-borrowing)

Saola is a category-A library (typed, installed, consumed) that **borrows** Basecoat/shadcn's CSS + theme. Because Basecoat reads every solid color through a CSS variable (`background: var(--color-primary)`, and even `hover` via `color-mix(var(--color-primary) ...)`), a widget can offer an **arbitrary accent color without authoring any parallel CSS** — just override the variable inline on the element.

This is the sanctioned "near two-axis" mechanism (variant × color) — do NOT introduce a second color/token system to get it.

```gleam
// Typed color holder — values are CSS colors or theme-token references.
pub type Accent { Accent(bg: String, fg: String) }

pub fn accent(config: WidgetConfig(msg), accent: Accent) -> WidgetConfig(msg)

// Render: emit per-property style overrides (Lustre's a.style is singular).
fn accent_attrs(config) -> List(a.Attribute(msg)) {
  case config.accent {
    None -> []
    Some(acc) -> [
      a.style("--color-primary", acc.bg),
      a.style("--color-primary-foreground", acc.fg),
    ]
  }
}
```

Rules:
- **Reuse the existing token** the Basecoat solid rule reads (`--color-primary` + `-foreground`). Never invent a new token or hand-author color CSS.
- Encourage theme-token values (`var(--chart-2)`) so custom colors stay sourced from the active theme.
- Cleanest for the **solid** look (default `Primary`); outline/ghost arbitrary colors still go through `add_class` (border/text aren't a single variable). Document this limit.
- Reference implementation: `saola/button` `Accent` + `accent`.

### 4. Variants as ADTs (Not Strings)

```gleam
pub type ButtonVariant {
  Primary
  Secondary
  Outline
  Ghost
  Destructive
}
```

No magic strings. Type system catches typos.

### 5. Form Input Value Binding (InitValue / SyncValue)

Form inputs expose two binding modes:

```gleam
pub type InputValue {
  InitValue(String)  // seed once, then manual updates (with formal library)
  SyncValue(String)  // kept in sync with model (controlled input)
}
```

Maps to HTML: `InitValue` → `a.default_value`, `SyncValue` → `a.value`.

### 6. Explicit ARIA

ARIA attributes are explicit, not imported from a framework.

```gleam
a.role("combobox")
a.aria_label("Select an option")
a.aria_expanded(is_open)
a.aria_disabled(is_disabled)
a.aria_current("page")  // navigation
```

Prefer semantic HTML tags (`<button>`, `<nav>`, `<main>`) over ARIA attributes when possible.

---

## CSS Standards

### File Organization

**Per-widget colocated CSS** — one `.css` file per `.gleam` widget module:
- `src/saola/button.gleam` → `src/saola/button.css`
- `src/saola/data_table.gleam` → `src/saola/data_table.css`
- File names use **snake_case** (match Gleam module naming)

**Shared base** — `src/saola/base.css` contains:
- `@property` rules (Tailwind v4 custom properties — must be top-level, invalid inside `@layer`)
- `@layer saola.theme` — design tokens (`:root` and `.dark` scope)
- `@layer saola.base` — scoped reset (`:where(widget-roots)` for zero specificity)

### Generated vs. Authored Files

**Generated files** (`/* @generated saola-css … */` sentinel):
- Emitted by `scripts/build-css.mjs` slicer from compiled `assets/basecoat.css`
- Regenerated on every `just build-css`
- Wrap selector set in `@layer saola.components`
- Each imports `./base.css`
- Slicer refuses to overwrite files lacking sentinel (protects customizations)

**Authored files** (no sentinel, hand-written):
- Custom CSS for widgets with Basecoat gaps or complex layouts
- Preserve `/* saola:custom */` region when slicer is re-run
- Example: `carousel.css` for host layout (Gleam wrapper is light-DOM but host element needs positioning)

### Cascade Layers

All CSS uses the same layer hierarchy so consumer CSS always wins:

```css
@layer saola, saola.theme, saola.base, saola.components, saola.charts;
```

- `saola.theme` — design tokens (lowest specificity)
- `saola.base` — scoped reset (`:where()` for zero specificity)
- `saola.components` — widget styles (UI widgets, form inputs)
- `saola.charts` — chart/visualization widgets (D3 bar, heatmap, etc.)

Unlayered consumer CSS **always** overrides layered Saola CSS, regardless of specificity.

### Design Tokens

Use **Basecoat CSS variables** — no prefixing, no custom tokens.

Available tokens:
```css
--color-primary
--color-secondary
--color-muted
--color-border
--color-background
--color-foreground
--color-muted-foreground
--color-destructive
--color-destructive-foreground
--color-ring
--radius-sm
--radius-md
--radius-lg
```

Dark mode applied via `.dark` class on root; Basecoat convention handles `--color-*` overrides.

### Class Names (Basecoat Naming)

Derive class names from [Basecoat CSS](https://basecoatui.com) **directly**. No custom prefixes.

```gleam
// CORRECT — Basecoat names
let class = case variant {
  Primary     -> "btn btn-primary"
  Secondary   -> "btn btn-secondary"
  Destructive -> "btn btn-destructive"
}

// WRONG — custom prefix
let class = "saola-btn-" <> variant_to_string(variant)
```

Build class names via string concatenation; no utility function needed.

### Scoped Reset (`:where(widget-roots)`)

By default, the reset targets only known widget root selectors via `:where()` — zero specificity, host styles always win.

```css
@layer saola.base {
  :where(.btn, .dialog, .alert, ...) {
    box-sizing: border-box;
    border: 0 solid;
    border-color: var(--color-border);
    /* ... other preflight defaults ... */
  }
}
```

Host preflight resets are **optional** — loaded via `saola-preflight.css` (for full Tailwind reset when embedding into non-shadcn apps).

### Adding CSS for a New Widget

1. Create `src/saola/my_widget.css` (no sentinel yet)
2. Wrap in `@layer saola.components`
3. Import base: `@import "./base.css";`
4. Use Basecoat class names and design tokens
5. Add path to `scripts/css-bundle-manifest.json` under `"components"` array
6. Run `just build-css` → bundles will include your widget
7. Add widget to sidebar + preview pages

Example:

```css
/* src/saola/my_widget.css */
@layer saola;
@import "./base.css";

@layer saola.components {
  .my-widget {
    display: flex;
    gap: 1rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    padding: 1rem;
    background: var(--color-background);
  }

  .my-widget-title {
    font-weight: 600;
    color: var(--color-foreground);
  }
}
```

---

## Accessibility Standards

### Semantic HTML

Prefer semantic HTML over ARIA attributes:
- `<button>` instead of `<div role="button">`
- `<nav>` instead of `<div role="navigation">`
- `<main>` instead of `<div role="main">`
- `<label>` for form inputs with `htmlFor`

### ARIA Attributes (Explicit)

When semantic HTML is insufficient, use explicit ARIA:

```gleam
// Modal dialog
a.role("dialog")
a.aria_modal(True)
a.aria_labelledby(title_id)

// Combobox
a.role("combobox")
a.aria_owns(listbox_id)
a.aria_expanded(is_open)
a.aria_controls(listbox_id)

// Interactive list
a.role("list")
// … children with role="listitem"

// Disabled state
a.aria_disabled(is_disabled)
// … ALSO apply a.disabled attribute on form controls
```

### Keyboard Navigation

- **All interactive widgets must be keyboard-accessible**: Tab, Enter, Escape, Arrow keys as appropriate
- **Focus order** should follow visual order (use `tabindex` sparingly; prefer semantic order)
- **Escape key** closes overlays (dialogs, popovers, dropdowns)
- **Arrow keys** navigate lists/menus/tabs

### Alt Text & Labels

- Form inputs always have associated `<label>` (via `htmlFor`)
- Images get `alt` attributes (or `aria-hidden` if decorative)
- Icon-only buttons get `aria_label`

### Testing Accessibility

- Use `element.to_string()` + assertions to verify ARIA attributes are present
- `gleam test` suite verifies role, aria-label, aria-expanded, aria-disabled, etc.
- Manual testing: keyboard navigation, screen reader (NVDA, JAWS, VoiceOver)

---

## File Naming Conventions

### Gleam Modules

Use **snake_case**:
- `src/saola/button.gleam` — widget
- `src/saola/data_table.gleam` — compound widget
- `src/saola/graph_layout.gleam` — utility module

### JavaScript / FFI Modules

Use **kebab-case** (ES module standard):
- `src/saola/carousel.ffi.mjs` — FFI bridge (Lustre convention: dot before `ffi`)
- `src/saola/graph_layout_worker.js` — Worker thread
- `src/saola/component-helpers.mjs` — shared utility (hyphens)

**Not** `carousel_ffi.mjs` or `carousel-ffi.mjs` — use dot separator.

### CSS Files

Use **snake_case** to match Gleam module names:
- `src/saola/button.css`
- `src/saola/data_table.css`
- `src/saola/base.css` (shared)

---

## Testing Standards

### Unit Tests

Use `gleam test` (built-in test runner):

```gleam
import gleeunit
import gleeunit.should

pub fn test_button_renders() {
  let html = button.button_primary("Click", OnClick) |> element.to_string
  html |> should.contain("btn")
  html |> should.contain("btn-primary")
  html |> should.contain("Click")
}

pub fn test_button_has_click_handler() {
  let html = button.button_primary("Click", OnClick) |> element.to_string
  html |> should.contain("data-message=")
}

pub fn test_alert_has_role() {
  let html = alert.alert_destructive("Error", None) |> element.to_string
  html |> should.contain("role=\"alert\"")
}
```

### Test File Naming

- `test/new_widget_tests*.gleam` — new widget batches (1, 2, 3, 4, 5, 6, 7, 8, …)
- One test module per batch (not one per widget)

### Coverage

- Render tests: verify output HTML contains expected classes, attributes, text
- Variant tests: verify each variant renders with correct class suffix
- Accessibility tests: verify ARIA attributes, roles, labels
- State tests: verify callback handlers are wired correctly

---

## Build & Test Commands

```bash
# Format
gleam format

# Build
gleam build

# Test
gleam test

# Docs
gleam docs build

# CSS pipeline
just build-css
# equivalent to: bun scripts/build-css.mjs && bun scripts/bundle-css.mjs

# Dev preview
just preview
```

---

## References

- **Basecoat CSS:** https://basecoatui.com
- **Gleam Style Guide:** https://gleam.run/book/tour/strings-and-string-builders.html
- **ARIA Authoring Practices:** https://www.w3.org/WAI/ARIA/apg/
- **WCAG 2.1:** https://www.w3.org/WAI/WCAG21/quickref/
