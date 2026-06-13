# Changelog

All notable changes to Saola are documented here.
Full per-batch history lives in [`docs/project-changelog.md`](docs/project-changelog.md).

## [Unreleased]

### Added

- **Modular CSS distribution** — per-widget colocated stylesheets (`src/saola/<widget>.css`, 25 generated from Basecoat + 29 authored) and five bundles in `priv/static/`: `saola.css` (full), `saola-base.css`, `saola-components.css`, `saola-charts.css`, `saola-preflight.css` (opt-in global reset). Consumers import the full bundle, a group bundle, or a single widget file (self-sufficient via `@import "./base.css"`).
- **CSS build pipeline** — `scripts/build-css.mjs` (selector-set slicer with fail-loud guards, `@generated`/`saola:custom` region contract) + `scripts/bundle-css.mjs` (ordered-manifest concatenation), runnable via `just build-css`; idempotent and re-runnable after Basecoat submodule syncs.
- **Button styling guide** — the button preview page (a "Customizing Styles" section) and the `saola/button` module docs now spell out the three CSS customization layers: theme tokens (`--color-*`/`--radius-*`), per-widget override (unlayered rules beat `@layer saola.*` without `!important`), and `add_class` for one-offs. Clarifies that `@generated` only forbids editing the sliced `src/saola/*.css`, not customizing from your own stylesheet.
- **Button shortcut symmetry** — `button_link` (Link-variant `<button>`), `button_destructive_anchor` and `button_link_anchor` complete full 6-variant coverage across both the `<button>` and `<a href>` shortcut families.

### Fixed

- **Icon-only buttons use the square Basecoat class** — an empty label with an icon (or loading spinner) now emits `btn-{sm,lg}-icon-{variant}` instead of the text-padded `btn-{sm,lg}-{variant}`, so `button_close` and other icon-only buttons render as proper squares rather than mis-shapen narrow buttons.
- **Disabled/loading anchors are genuinely inert** — `view_anchor` now omits `href` while `disabled`/`loading` (keeping `aria-disabled` + `tabindex="-1"`). Previously the link kept its `href` and stayed mouse-clickable since `aria-disabled` is advisory only.
- **Loading & aria-disabled states are visually dimmed** — buttons/anchors using `aria-busy`/`aria-disabled` (loading buttons, disabled anchors) now get `opacity: 50%` + `pointer-events: none`, mirroring Basecoat's native `:disabled` visual that those aria-state elements never matched.

### Changed

- All Saola CSS now lives under `@layer saola.*` — unlayered consumer CSS always wins; the global Tailwind preflight no longer leaks into host pages (scoped `:where(widget-roots)` reset replaces it; the global form is opt-in via `saola-preflight.css`). Class and CSS-variable names remain Basecoat/shadcn-compatible.
- Demo loads CSS via `dev/dev-widgets.css` (generated aggregate) + slimmed `assets/app.css`; `assets/basecoat.css` is now pipeline input only.
- All 50 widget modules now use `list.flatten` for conditional attribute assembly instead of `a.none()` sentinels — eliminates trailing spaces in generated `class` attributes (e.g. `class="btn    "` → `class="btn"`).
- **Button API redesign** — one public `ButtonConfig` record consumed through two styles: builder pipes (`button.new() |> button.variant(..) |> button.view(label, Some(msg))`) and record update (`ButtonConfig(..button.default_config(), loading: True)`). Render-as is type-safe via terminals: `view` → `<button>` (requires `Option(msg)`), `view_anchor` → `<a>` (requires `href`). New options: `loading` (spinner + `aria-busy`, stays in the a11y tree via `aria-disabled`), `icon_start`/`icon_end`, `add_class` (append-only). Anchor shortcuts (`button_primary_anchor` etc.) render navigation URLs with full button styling.

### Removed

- `assets/component.css` (rules relocated to their owning widget files).
- `ButtonExtraAttrs` and the positional `button()`/`button_anchor()` functions — replaced by `ButtonConfig` + `view`/`view_anchor` (breaking; shortcut functions keep their signatures).

## [1.0.0] — 2026-05-17

Initial public release.

### Widgets (56+)

**Core** — Button, Badge, Alert, Card, Checkbox, Input, Textarea, Label, Radio Group, Switch, Separator, Table

**Advanced** — Dropdown Menu, Select, Combobox, Dialog, Alert Dialog, Popover, Tooltip, Hover Card, Tabs, Accordion, Toast, Sheet, Menubar

**Form & Input** — Field, Slider, Toggle, Toggle Group, Input OTP, Calendar, Date Picker, Command Palette

**Specialized** — Spinner, Native Select, Button Group, Input Group, Context Menu, Drawer, Search, Rating, Multiselect, Time Picker

**Layout & Navigation** — Breadcrumb, Pagination, Scroll Area, Aspect Ratio, Collapsible, Sidebar, Resizable, Empty, Item, Navigation Menu, Carousel, Navigation Bar, Stepper, Tree View

**Data Display** — Data Table (typed, sortable, filterable, paginated)

**Third-party wrappers** — CodeMirror Editor, Monaco Editor, D3 Bar Chart (custom element wrappers)

### Features

- **Theme system** (`saola/theme`) — `Light`, `Dark`, `System` variants; `watch_system_dark` for reactive OS dark-mode listener; `get_system_dark()` for init-time state; dark mode via `.dark` class on root element
- **Form field** (`saola/field`) — label, description, hint, error, required indicator, ARIA attributes
- **Two-tier API** — every widget exposes the widget name itself for complete control + shortcut functions for common cases
- **Typed variants** — all visual variants are Gleam ADTs (`ButtonVariant`, `BadgeVariant`, etc.) — no magic strings
- **Stateless by design** — widgets are pure functions; all state lives in the consumer's Lustre `Model`

### Design system

Built on [Basecoat CSS](https://basecoatui.com) — a pure-HTML port of shadcn/ui using CSS custom properties for theming.

### Test coverage

284 tests across all widget modules.
