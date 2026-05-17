# Saola

Typed, stateless UI widgets for [Lustre](https://hexdocs.pm/lustre) applications.
Built on top of [Basecoat CSS](https://basecoatui.com/) (a pure-HTML port of shadcn/ui).

> **Widget vs Component** — Lustre uses the word "component" for elements with their own runtime instance.
> Saola elements are called *widgets* to avoid confusion: they are plain view functions, no runtime state.

## Getting started

Add the package:

```sh
gleam add saola
```

Import the CSS (add to your HTML shell):

```html
<link rel="stylesheet" href="https://unpkg.com/basecoat-css@latest/dist/basecoat.css" />
```

Use a widget inside any Lustre `view` function:

```gleam
import saola/button
import saola/badge

fn view(model: Model) -> Element(Msg) {
  h.div([], [
    badge.badge_secondary("New"),
    button.button_primary("Get started", UserClickedStart),
  ])
}
```

## Widgets

| Module | Shortcuts | Full API |
|--------|-----------|----------|
| `saola/accordion` | `accordion_simple` | `accordion_full` |
| `saola/alert` | `alert_default`, `alert_destructive` | `alert_full` |
| `saola/alert_dialog` | `alert_dialog_simple` | `alert_dialog_full` |
| `saola/aspect_ratio` | `aspect_ratio` | — |
| `saola/avatar` | `avatar_initials`, `avatar_image` | `avatar_full` |
| `saola/badge` | `badge_default`, `badge_secondary`, `badge_outline`, `badge_destructive` | — |
| `saola/breadcrumb` | `breadcrumb_simple` | `breadcrumb_full` |
| `saola/button` | `button_primary`, `button_secondary`, `button_outline`, `button_ghost`, `button_destructive`, `button_submit` | `button_full` |
| `saola/card` | `card_simple` | `card` |
| `saola/checkbox` | `checkbox_simple` | `checkbox_full` |
| `saola/collapsible` | `collapsible_simple` | `collapsible_full` |
| `saola/command` | — | `command_full`, `command_nav_up`, `command_nav_down`, `command_get_value_at`, `command_item_count` |
| `saola/data_table` | `data_table_simple` | `data_table_full` |
| `saola/dialog` | — | `dialog_full` |
| `saola/field` | `field_simple` | `field` |
| `saola/hover_card` | `hover_card_simple` | `hover_card_full` |
| `saola/input` | — | `input_full` |
| `saola/input_otp` | `input_otp_simple` | `input_otp_full` |
| `saola/label` | `label_for` | — |
| `saola/menubar` | `menubar_simple` | `menubar_full` |
| `saola/pagination` | `pagination_simple` | `pagination_full` |
| `saola/popover` | `popover_simple` | `popover_full` |
| `saola/progress` | `progress_simple` | `progress_full` |
| `saola/radio_group` | `radio_group_simple` | `radio_group_full` |
| `saola/resizable` | `resizable_simple` | `resizable_full` |
| `saola/scroll_area` | `scroll_area_simple` | `scroll_area_full` |
| `saola/select` | `select_simple` | `select_full` |
| `saola/separator` | `separator`, `separator_vertical` | — |
| `saola/sheet` | `sheet_simple` | `sheet_full` |
| `saola/sidebar` | `sidebar_simple` | `sidebar_full` |
| `saola/skeleton` | `skeleton_text`, `skeleton_circle` | `skeleton` |
| `saola/slider` | `slider_simple` | `slider_full` |
| `saola/switch` | `switch_simple` | `switch_full` |
| `saola/table` | `table_simple` | — |
| `saola/tabs` | `tabs_simple` | — |
| `saola/textarea` | — | `textarea_full` |
| `saola/toast` | `new_toast` (factory) | `toaster` (container) |
| `saola/toggle` | `toggle_simple` | `toggle_full` |
| `saola/toggle_group` | `toggle_group_simple` | `toggle_group_full` |
| `saola/tooltip` | `tooltip`, `tooltip_side` | `attr`, `side_attr` |

### Third-party widget wrappers

These wrappers ship as custom elements (`<script>` required separately):

| Module | Custom element | Dependency |
|--------|---------------|------------|
| `saola/codemirror_editor` | `<saola-codemirror-editor>` | CodeMirror 6 |
| `saola/monaco_editor` | `<saola-monaco-editor>` | Monaco / VS Code |
| `saola/d3_bar_chart` | `<saola-d3-bar-chart>` | D3.js v7 |

## Design principles

- **Stateless** — every widget is a pure `fn ... -> Element(msg)`. The consumer's `Model` owns all state.
- **External-state duality** — form widgets accept `InitValue(v)` (seed once) or `SyncValue(v)` (keep in sync with model).
- **Two-tier API** — each widget exposes a `_simple` shortcut for the common case and a `_full` function for complete control.
- **Typed, not stringly typed** — variants (`ButtonVariant`, `BadgeVariant`, …) are Gleam custom types, not magic strings.

## Running the preview app

```sh
just preview
```

Requires [Just](https://just.systems/) and [Bun](https://bun.sh/).

## Contributing

1. Clone the repo (includes `dev/basecoat` submodule — run `git submodule update --init`).
2. Run `gleam test` to verify all tests pass.
3. The live preview app lives in `dev/saola/preview/`; add a showcase page for any new widget.
4. Follow the rules in `CLAUDE.md` for widget API conventions.

## Licence

Apache-2.0
