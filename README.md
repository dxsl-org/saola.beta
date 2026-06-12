# Saola

Typed UI building blocks for [Lustre](https://hexdocs.pm/lustre) applications — stateless widgets and full-runtime components.
Built on top of [Basecoat CSS](https://basecoatui.com/) (a pure-HTML port of shadcn/ui).

> **Widget vs Component** — Saola provides two kinds of UI building blocks:
> - *Widgets* are plain view functions — stateless, no registration needed.
> - *Components* are Lustre components with their own runtime instance, backed by a custom HTML element. They require a one-time `register()` call at startup.

## Widgets

| Module | Shortcuts | Full API |
|--------|-----------|----------|
| `saola/accordion` | `accordion_simple` | `accordion` |
| `saola/alert` | `alert_default`, `alert_destructive` | `alert` |
| `saola/alert_dialog` | `alert_dialog_simple` | `alert_dialog` |
| `saola/aspect_ratio` | `aspect_ratio` | — |
| `saola/avatar` | `avatar_initials`, `avatar_image` | `avatar` |
| `saola/badge` | `badge_default`, `badge_secondary`, `badge_outline`, `badge_destructive` | — |
| `saola/breadcrumb` | `breadcrumb_simple` | `breadcrumb` |
| `saola/button` | `button_primary`, `button_secondary`, `button_outline`, `button_ghost`, `button_destructive`, `button_submit` | `button` |
| `saola/card` | `card_simple` | `card` |
| `saola/checkbox` | `checkbox_simple` | `checkbox` |
| `saola/collapsible` | `collapsible_simple` | `collapsible` |
| `saola/command` | — | `command`, `command_nav_up`, `command_nav_down`, `command_get_value_at`, `command_item_count` |
| `saola/data_table` | `data_table_simple` | `data_table` |
| `saola/dialog` | — | `dialog` |
| `saola/field` | `field_simple` | `field` |
| `saola/hover_card` | `hover_card_simple` | `hover_card` |
| `saola/input` | — | `input` |
| `saola/input_otp` | `input_otp_simple` | `input_otp` |
| `saola/label` | `label_for` | — |
| `saola/menubar` | `menubar_simple` | `menubar` |
| `saola/multiselect` | `multiselect_simple` | `multiselect` |
| `saola/pagination` | `pagination_simple` | `pagination` |
| `saola/popover` | `popover_simple` | `popover` |
| `saola/progress` | `progress_simple` | `progress` |
| `saola/radio_group` | `radio_group_simple` | `radio_group` |
| `saola/rating` | `rating_readonly`, `rating_interactive` | `rating` |
| `saola/resizable` | `resizable_simple` | `resizable` |
| `saola/scroll_area` | `scroll_area_simple` | `scroll_area` |
| `saola/search` | `search_simple`, `search_clearable` | `search` |
| `saola/select` | `select_simple` | `select` |
| `saola/separator` | `separator`, `separator_vertical` | — |
| `saola/sheet` | `sheet_simple` | `sheet` |
| `saola/sidebar` | `sidebar_simple` | `sidebar` |
| `saola/skeleton` | `skeleton_text`, `skeleton_circle` | `skeleton` |
| `saola/slider` | `slider_simple` | `slider` |
| `saola/switch` | `switch_simple` | `switch` |
| `saola/table` | `table_simple` | — |
| `saola/tabs` | `tabs_simple` | — |
| `saola/textarea` | — | `textarea` |
| `saola/toast` | `new_toast` (factory) | `toaster` (container) |
| `saola/toggle` | `toggle_simple` | `toggle` |
| `saola/button_group` | `button_group_simple` | `button_group` |
| `saola/calendar` | — | `calendar` |
| `saola/carousel` | `carousel_simple` | `carousel` |
| `saola/context_menu` | — | `context_menu` |
| `saola/date_picker` | — | `date_picker` |
| `saola/drawer` | `drawer_simple` | `drawer` |
| `saola/empty` | `empty_simple` | `empty` |
| `saola/input_group` | `input_group_simple` | `input_group` |
| `saola/item` | `item_simple`, `item_link` | `item` |
| `saola/native_select` | `native_select_simple` | `native_select` |
| `saola/navigation_bar` | `nav_bar_simple`, `nav_bar_link` | `nav_bar` |
| `saola/navigation_menu` | `navigation_menu_simple` | `navigation_menu` |
| `saola/spinner` | `spinner_simple` | `spinner` |
| `saola/stepper` | `stepper_simple` | `stepper` |
| `saola/theme` | — | `apply_to_html`, `watch_system_dark`, `get_system_dark` |
| `saola/time_picker` | `time_picker_simple` | `time_picker` |
| `saola/timeline` | `timeline_simple` | `timeline` |
| `saola/toggle_group` | `toggle_group_simple` | `toggle_group` |
| `saola/tooltip` | `tooltip`, `tooltip_side` | `attr`, `side_attr` |
| `saola/tree_view` | `tree_view_simple` | `tree_view` |

### Third-party widget wrappers

These wrappers ship as custom elements (`<script>` required separately):

| Module | Custom element | Dependency |
|--------|---------------|------------|
| `saola/codemirror_editor` | `<saola-codemirror-editor>` | CodeMirror 6 |
| `saola/monaco_editor` | `<saola-monaco-editor>` | Monaco / VS Code |
| `saola/d3_bar_chart` | `<saola-d3-bar-chart>` | D3.js v7 |

## Components

Components carry their own Lustre runtime and are backed by a custom HTML element.
Call `register()` once at application startup before rendering them.

| Module | Custom element | Notes |
|--------|---------------|-------|
| `saola/component/combobox` | `<combo-box>` | Searchable dropdown with keyboard navigation and async-safe preselection |

## Dark Mode / Theming

`Theme` variants: `theme.Light` (default) | `theme.Dark` | `theme.System` (follows OS preference).

### Apps with a theme toggle (recommended)

Use `apply_to_html` as a Lustre `Effect` when the theme changes, because it needs to update the `<html>` class outside the area where the Lustre app mounts. Pair it with `watch_system_dark` to track OS preference changes:

```gleam
import saola/theme

// In init — apply initial theme and subscribe to OS preference changes
fn init(_flags) -> #(Model, lustre.Effect(Msg)) {
  #(
    Model(theme: theme.Light, system_os_dark: theme.get_system_dark(), ...),
    effect.batch([
      theme.watch_system_dark(True, SystemOsDarkChanged),
      theme.apply_to_html(theme.Light, theme.get_system_dark()),
    ]),
  )
}

// In update — apply theme on change
ThemeToggled(t) -> #(Model(..model, theme: t), theme.apply_to_html(t, model.system_os_dark))
SystemOsDarkChanged(is_dark) -> #(Model(..model, system_os_dark: is_dark), theme.apply_to_html(model.theme, is_dark))
```

Add this script to `<head>` to avoid flash-of-wrong-theme on load:

```html
<script>
  if (window.matchMedia('(prefers-color-scheme: dark)').matches)
    document.documentElement.classList.add('dark')
</script>
```

`apply_to_html` explicitly calls `classList.add/remove('dark')` on `<html>`, so it always overrides whatever the inline script set — no conflict.

### Static theme (no toggle)

If the theme is fixed at startup and never changes at runtime, `apply_to_html` is still the preferred way to sync the root theme class.

## Form Fields and Validation

Use `saola/field` to wrap any input with label, description, hint, and error:

```gleam
import saola/field
import saola/input

field.field(
  field.FieldAttrs(
    label: "Email", description: "", error: "",
    orientation: field.Vertical, required: True, hint: "",
  ),
  input.input(input.Email, option.Some(input.SyncValue(model.email)),
    on_input: option.Some(EmailChanged),
    extra_attrs: input.InputExtraAttrs(..input.default_extra_attrs, placeholder: "you@example.com"),
  ),
)
```

To wire `formal` validation results into `FieldAttrs`:

```gleam
// Add `formal` to your app's [dependencies], then:
fn field_from_result(result: Result(String, String), attrs: field.FieldAttrs) -> field.FieldAttrs {
  case result {
    Ok(_)  -> field.FieldAttrs(..attrs, error: "")
    Error(e) -> field.FieldAttrs(..attrs, error: e)
  }
}
```

## Design principles

- **Stateless widgets** — widgets are pure `fn ... -> Element(msg)`. The consumer's `Model` owns all state.
- **Stateful components** — components (`saola/component/*`) carry their own Lustre runtime for cases where an isolated state machine genuinely simplifies the API.
- **External-state duality** — form widgets accept `InitValue(v)` (seed once) or `SyncValue(v)` (keep in sync with model).
- **Two-tier API** — each widget exposes a `_simple` shortcut for the common case and the widget name itself for complete control.
- **Typed, not stringly typed** — variants (`ButtonVariant`, `BadgeVariant`, …) are Gleam custom types, not magic strings.

## Running the preview app

```sh
just preview
```

Requires [Just](https://just.systems/) and [Bun](https://bun.sh/).

## Contributing

1. Clone the repo (includes `external/basecoat` submodule — run `git submodule update --init`).
2. Run `gleam test` to verify all tests pass.
3. The live preview app lives in `dev/saola/preview/`; add a showcase page for any new widget.
4. Follow the rules in `CLAUDE.md` for widget API conventions.

## CSS Distribution

### Three import modes for consumers

**1. Full bundle** — drop-in, everything included:
```html
<link rel="stylesheet" href="/path/to/saola.css">
```

**2. Group bundles** — load only the layer(s) you need:
```html
<link rel="stylesheet" href="/path/to/saola-base.css">        <!-- tokens + scoped reset only -->
<link rel="stylesheet" href="/path/to/saola-components.css">  <!-- base + all UI widgets -->
<link rel="stylesheet" href="/path/to/saola-charts.css">      <!-- base + chart widgets -->
```

**3. Per-widget granular** (Vite consumers) — import only what you use. Requires a Vite alias pointing at the package `src/` tree. Add this to your `vite.config.js`:
```js
import { resolve } from 'path';
export default {
  resolve: {
    alias: {
      '@saola': resolve('./node_modules/saola/src/saola'),
      // or for a local checkout: resolve('./build/packages/saola/src/saola')
    },
  },
};
```
Then in your CSS entry:
```css
@import '@saola/button.css';
@import '@saola/dialog.css';
/* add only the widgets you use */
```
Per-widget files import `base.css` themselves. Duplicate `@import "./base.css"` across widgets is idempotent (Vite deduplicates).

**Opt-in global preflight** — only if your app needs the full Tailwind/Basecoat reset (not required for embedding Saola into an existing shadcn/Tailwind app):
```html
<link rel="stylesheet" href="/path/to/saola-preflight.css">
```

### Distribution contract

- `priv/static/` bundles are the primary shipped artifact (`priv/` is included in Hex tarballs).
- Per-widget colocated `src/saola/*.css` files also ship in the tarball and are importable via the Vite alias recipe above.
- Final packaging is managed by the upstream public repo (`saola.beta` is internal-only).
- Bundles are built by ordered concatenation (not `@import`) to avoid Lightning CSS / postcss-import deduplication ambiguity. The concat order is committed in `scripts/css-bundle-manifest.json`.

### Layer architecture

All saola CSS uses cascade layers so unlayered consumer CSS always wins:

```
@layer saola, saola.theme, saola.base, saola.components, saola.charts;
       ^       ^             ^           ^                 ^
       root    tokens        scoped      widgets           charts
               (:root/.dark) reset       (components)
```

By default the scoped reset targets only known widget root selectors via `:where(…)` — zero specificity, host styles always win. Load `saola-preflight.css` to opt into the global reset.

### Updating the bundled Basecoat CSS (full sync workflow)

**Security gate — ALWAYS perform these steps in order:**

1. **Diff-review the submodule build script before running it** — the build script executes untrusted third-party code:
   ```sh
   git diff HEAD external/basecoat   # inspect what changed
   # Manually review external/basecoat/scripts/build.js
   # and external/basecoat/package.json devDeps for new/changed scripts
   ```
2. **Build the upstream CSS** (only after the review above):
   ```sh
   cd external/basecoat && bun run build
   ```
3. **Copy the compiled output** into the saola repo:
   ```sh
   cp external/basecoat/packages/css/dist/basecoat.cdn.css assets/basecoat.css
   ```
4. **Run the full CSS pipeline** — slices and bundles in one command:
   ```sh
   just build-css
   # equivalent to: bun scripts/build-css.mjs && bun scripts/bundle-css.mjs
   ```
   The slicer is deterministic and fails loudly if any compiled selector has no mapping in `scripts/css-section-map.json` (catches upstream renames/removals). The bundler fails loudly if any `src/saola/*.css` is absent from `scripts/css-bundle-manifest.json`.

5. **Commit** the updated `assets/basecoat.css`, the regenerated `src/saola/*.css` / `src/saola/base.css`, and the updated `priv/static/` bundles together.

### CSS pipeline

**Full pipeline order:**

```
assets/basecoat.css          (compiled Tailwind v4 — slicer input)
       │
       ▼
bun scripts/build-css.mjs    (Strategy-B selector-set slicer)
       │
       ├── src/saola/base.css            (@property passthrough + tokens + scoped reset)
       ├── src/saola/<widget>.css ×25    (generated; each @imports base.css)
       └── .build-css/preflight.css      (gitignored; source for saola-preflight.css bundle)
       │
       ▼
bun scripts/bundle-css.mjs   (ordered-concatenation bundler, manifest = css-bundle-manifest.json)
       │
       ├── priv/static/saola.css             (base + components + charts — full bundle)
       ├── priv/static/saola-base.css        (base only)
       ├── priv/static/saola-components.css  (base + all component widgets)
       ├── priv/static/saola-charts.css      (base + chart widgets)
       ├── priv/static/saola-preflight.css   (base + global preflight — opt-in)
       └── dev/dev-widgets.css               (dev-only aggregate @imports for Vite HMR)
```

The slicer reads `assets/basecoat.css` (the compiled Tailwind v4 build) and emits:

| Output | Description |
|--------|-------------|
| `src/saola/base.css` | `@property` passthrough + `@layer saola.theme` tokens + `@layer saola.base` scoped reset |
| `src/saola/<widget>.css` ×25 | Per-widget component CSS wrapped in `@layer saola.components`, each imports `./base.css` |
| `.build-css/preflight.css` | Isolated global Tailwind reset (gitignored; bundled into `saola-preflight.css`) |

Each generated per-widget file opens with `/* @generated saola-css … */`. The slicer refuses to overwrite any file lacking this sentinel (protects hand-written augmentations). A `/* saola:custom */` marker after the generated region is preserved verbatim on every re-run.

The 29 authored widget files (those without the sentinel, from Phase 02) are picked up directly by the bundler via `scripts/css-bundle-manifest.json`.

The `basecoat` submodule is placed under `external/` rather than `dev/` because Gleam scans `dev/` for source code to build.

## Licence

Apache-2.0
