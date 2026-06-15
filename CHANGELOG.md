# Changelog

All notable changes to Saola are documented here.
Full per-batch history lives in [`docs/project-changelog.md`](docs/project-changelog.md).

## [Unreleased]

### Added

- **Modular CSS distribution** — per-widget colocated stylesheets (`src/saola/<widget>.css`, 25 generated from Basecoat + 29 authored) and five bundles in `priv/static/`: `saola.css` (full), `saola-base.css`, `saola-components.css`, `saola-charts.css`, `saola-preflight.css` (opt-in global reset). Consumers import the full bundle, a group bundle, or a single widget file (self-sufficient via `@import "./base.css"`).
- **CSS build pipeline** — `scripts/build-css.mjs` (selector-set slicer with fail-loud guards, `@generated`/`saola:custom` region contract) + `scripts/bundle-css.mjs` (ordered-manifest concatenation), runnable via `just build-css`; idempotent and re-runnable after Basecoat submodule syncs.
- **Button styling guide** — the button preview page (a "Customizing Styles" section) and the `saola/button` module docs now spell out the three CSS customization layers: theme tokens (`--color-*`/`--radius-*`), per-widget override (unlayered rules beat `@layer saola.*` without `!important`), and `add_class` for one-offs. Clarifies that `@generated` only forbids editing the sliced `src/saola/*.css`, not customizing from your own stylesheet.
- **Button shortcut symmetry** — `button_link` (Link-variant `<button>`), `button_destructive_anchor` and `button_link_anchor` complete full 6-variant coverage across both the `<button>` and `<a href>` shortcut families.
- **Button custom accent** — `accent(Accent(bg, fg))` recolors the solid look by overriding the `--color-primary` pair inline, reusing Basecoat's background/hover/focus machinery with no parallel CSS. Values accept any CSS color or a theme token (`var(--chart-2)`), keeping custom colors theme-coherent. The sanctioned "near two-axis" mechanism (variant × color) — documented as a reusable widget technique in `docs/code-standards.md` §3c.
- **Button children slots** — `before`/`after` take arbitrary children lists (an icon, a badge, several elements), generalizing the single-icon `icon_start`/`icon_end` (now thin shortcuts over them). The success/error glyph for `Loaded`/`Failed` (see the state model below) is a consumer element placed in a slot.
- **Uniform-Config migration (in progress)** — widgets are being migrated to the dual-style `Config` standard (`CLAUDE.md` rules 2/4/8): `WidgetConfig` + `new()`/`default_config()` + one-line setters + `view(config, …)` terminal, with each widget's `*_*` shortcuts kept at their existing signatures. **Migrated:** `button`, `badge`, `alert`, `kbd`, `label`, `separator`, `spinner`, `skeleton`, `avatar`, `breadcrumb`, `progress`, `pagination`, `card`, `item`, `empty`, `input`, `textarea`. **Breaking:** flat constructors / `Attrs` types removed — `badge(label, variant)`, `alert(variant, title, description, icon)`, `avatar(source, size, class)` (→ `view(config, source)`), `breadcrumb(items, attrs)` + `BreadcrumbAttrs`/`default_attrs` (→ `new() |> separator(..) |> view(items)`), `progress(value, attrs)` + `ProgressAttrs`/`default_attrs` (→ `new() |> … |> view(value)`), `pagination(page, total, on_change, attrs)` + `PaginationAttrs`/`default_attrs` (→ `new() |> … |> view(page, total, on_change)`), `card(CardAttrs)` + `CardAttrs`/`default_card_attrs` (→ `new() |> title(..)/description(..)/footer(..) |> view(content)`), `item(...)` (→ `new() |> … |> view(title, description, href)`; empty href → `<div>`, non-empty → `<a>`), `empty(...)` (→ `new() |> … |> view(title, description, content)`), `input(type_, value, on_input, attrs)` + `InputExtraAttrs`/`default_extra_attrs` (→ `new() |> … |> view(value, on_input)`), `textarea(value, on_input, attrs)` + `TextareaExtraAttrs`/`default_extra_attrs` (→ `new() |> … |> view(value, on_input)`). The `InitValue`/`SyncValue` value-binding ADTs are unchanged. Shortcuts keep their signatures (`badge_*`, `alert_*`, `kbd`, `label`/`label_for`, `separator`/`separator_vertical`, `spinner`/`spinner_simple`, `skeleton*`, `avatar_*`, `breadcrumb_simple` — no caller change).

### Fixed

- **Icon-only buttons use the square Basecoat class** — an empty label with an icon (or loading spinner) now emits `btn-{sm,lg}-icon-{variant}` instead of the text-padded `btn-{sm,lg}-{variant}`, so `button_close` and other icon-only buttons render as proper squares rather than mis-shapen narrow buttons.
- **Disabled/loading anchors are genuinely inert** — an anchor-rendered button omits `href` while inert (`Loading`/`Suspended`/`Disabled`), keeping `aria-disabled` + `tabindex="-1"`. Previously the link kept its `href` and stayed mouse-clickable since `aria-disabled` is advisory only.
- **Loading & aria-disabled states are visually dimmed** — buttons/anchors using `aria-busy`/`aria-disabled` (loading buttons, disabled anchors) now get `opacity: 50%` + `pointer-events: none`, mirroring Basecoat's native `:disabled` visual that those aria-state elements never matched.
- **Underline follows the `link` variant, not the element** — a button-styled `<a href>` no longer shows the browser's default anchor underline, and the `link` variant reads as a hyperlink (underline) on any element, `<button>` or `<a>`. Underline is a property of the variant, never of the rendered tag.

### Changed

- All Saola CSS now lives under `@layer saola.*` — unlayered consumer CSS always wins; the global Tailwind preflight no longer leaks into host pages (scoped `:where(widget-roots)` reset replaces it; the global form is opt-in via `saola-preflight.css`). Class and CSS-variable names remain Basecoat/shadcn-compatible.
- Demo loads CSS via `dev/dev-widgets.css` (generated aggregate) + slimmed `assets/app.css`; `assets/basecoat.css` is now pipeline input only.
- All 50 widget modules now use `list.flatten` for conditional attribute assembly instead of `a.none()` sentinels — eliminates trailing spaces in generated `class` attributes (e.g. `class="btn    "` → `class="btn"`).
- **Button API redesign** — one public `ButtonConfig` record consumed two ways (builder pipes + record update), plus shortcuts. Options: `variant`, `size`, `before`/`after` slots (`icon_start`/`icon_end` shortcuts), `accent`, `aria`, `type_`, `add_class` (append-only). Anchor shortcuts (`button_primary_anchor` etc.) render navigation URLs with full button styling. (Final terminal + state model in the two entries below.)
- **Button default size is now `Medium`** (was `Large`) — `ButtonSize` gains `Medium`, mapping to Basecoat's `btn-{variant}` (no size segment). **Breaking:** `new()` and every shortcut now emit `btn-{variant}` instead of `btn-lg-{variant}`; pass `size(Large)` to restore the previous look.
- **Button `view` defaults to `type="button"`** — a `<button>` with no `type` is `type="submit"` per HTML and would submit its enclosing `<form>`; `view` now forces `type="button"` unless `type_` is `Submit`/`Reset`.
- **Button state model** — a single `ButtonState` enum (`Idle | Loading | Loaded | Failed | Suspended | Disabled`) replaces the `loading`/`disabled` booleans (kept as sugar setters over `state`). Models async/checkout flows; **`Suspended`** is a system hold (stays in the a11y tree via `aria-disabled`), distinct from **`Disabled`** (native `disabled`). Every non-idle state emits `data-state="..."` so consumers can style it and animate the `loading → loaded → idle` hand-off via `transition: all`. **Breaking:** record-update of `loading:`/`disabled:` fields → use `state:`.
- **Button render target via `href`** — one terminal `view(config, label, href, on_click)`: a **non-empty** `href` renders `<a href>` (navigation), an **empty** `href` renders `<button>` (uses `on_click`). One function makes conditional `<a>`-vs-`<button>` rendering trivial. **Breaking:** `view` gains the `href` param (pass `""` for buttons); `view_anchor` is removed.

### Removed

- `button.view_anchor` — folded into `view` via the `href` parameter (non-empty `href` → `<a>`). Anchor shortcuts (`button_primary_anchor` etc.) are unchanged.
- `assets/component.css` (rules relocated to their owning widget files).
- `ButtonExtraAttrs` and the positional `button()`/`button_anchor()` functions — replaced by `ButtonConfig` + `view` (breaking; shortcut functions keep their signatures).
- Flat `badge(label, variant)` — replaced by `BadgeConfig` + `view` + `badge_*` shortcuts (breaking).

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
