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
| `saola/multiselect` | `multiselect_simple` | `multiselect_full` |
| `saola/pagination` | `pagination_simple` | `pagination_full` |
| `saola/popover` | `popover_simple` | `popover_full` |
| `saola/progress` | `progress_simple` | `progress_full` |
| `saola/radio_group` | `radio_group_simple` | `radio_group_full` |
| `saola/rating` | `rating_readonly`, `rating_interactive` | `rating_full` |
| `saola/resizable` | `resizable_simple` | `resizable_full` |
| `saola/scroll_area` | `scroll_area_simple` | `scroll_area_full` |
| `saola/search` | `search_simple`, `search_clearable` | `search_full` |
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
| `saola/button_group` | `button_group_simple` | `button_group_full` |
| `saola/calendar` | — | `calendar_full` |
| `saola/carousel` | `carousel_simple` | `carousel_full` |
| `saola/combobox` | `combobox_simple` | `combobox_full` |
| `saola/context_menu` | — | `context_menu_full` |
| `saola/date_picker` | — | `date_picker_full` |
| `saola/drawer` | `drawer_simple` | `drawer_full` |
| `saola/empty` | `empty_simple` | `empty_full` |
| `saola/input_group` | `input_group_simple` | `input_group_full` |
| `saola/item` | `item_simple`, `item_link` | `item_full` |
| `saola/native_select` | `native_select_simple` | `native_select_full` |
| `saola/navigation_bar` | `nav_bar_simple`, `nav_bar_link` | `nav_bar_full` |
| `saola/navigation_menu` | `navigation_menu_simple` | `navigation_menu_full` |
| `saola/spinner` | `spinner_simple` | `spinner_full` |
| `saola/stepper` | `stepper_simple` | `stepper_full` |
| `saola/theme` | `theme_attr` | — |
| `saola/time_picker` | `time_picker_simple` | `time_picker_full` |
| `saola/timeline` | `timeline_simple` | `timeline_full` |
| `saola/toggle_group` | `toggle_group_simple` | `toggle_group_full` |
| `saola/tooltip` | `tooltip`, `tooltip_side` | `attr`, `side_attr` |
| `saola/tree_view` | `tree_view_simple` | `tree_view_full` |

### Third-party widget wrappers

These wrappers ship as custom elements (`<script>` required separately):

| Module | Custom element | Dependency |
|--------|---------------|------------|
| `saola/codemirror_editor` | `<saola-codemirror-editor>` | CodeMirror 6 |
| `saola/monaco_editor` | `<saola-monaco-editor>` | Monaco / VS Code |
| `saola/d3_bar_chart` | `<saola-d3-bar-chart>` | D3.js v7 |

## Dark Mode / Theming

Apply `theme_attr` to your root element:

```gleam
import saola/theme

fn view(model: Model) -> Element(Msg) {
  h.html([theme.theme_attr(model.theme)], [
    // ...
  ])
}
```

`Theme` variants: `theme.Light` (default) | `theme.Dark` | `theme.System` (follows OS preference).

Add this script to `<head>` to avoid flash-of-wrong-theme on load:

```html
<script>
  if (window.matchMedia('(prefers-color-scheme: dark)').matches)
    document.documentElement.classList.add('dark')
</script>
```

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
  input.input_full(input.Email, option.Some(input.SyncValue(model.email)),
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
