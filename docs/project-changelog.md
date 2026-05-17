# Saola Project Changelog

All notable changes to the Saola UI Kit are documented here.

## [2026-05-17] — Batch 9: Empty, Item Widgets

### Added

**New Widgets**
- **Empty** (`src/saola/empty.gleam`) — Empty-state panel for "no results", onboarding, error placeholders
  - Two media variants: Default, Icon (with rounded bg-muted wrapper)
  - Flat API: `empty_full(media, media_variant, title, description, content, attrs)`, `empty_simple(icon, title, description_text, action)`
  - Renders centered dashed-border container with optional header (media + title + description) and content area
  - Omits header/content sections when all sub-fields are empty
  - Pure-Gleam, no JS, stateless

- **Item** (`src/saola/item.gleam`) — Row-layout primitive for lists (settings rows, navigation, gallery)
  - 3 variants: Default, Outline, Muted; 2 sizes: Large (lg), Small (sm)
  - 3 media variants: Default, Icon (with border bg-muted), Image (with object-fit cover)
  - Flat API: `item_full(variant, size, media, media_variant, title, description, actions, attrs)`
  - Shortcut functions: `item_simple(title, description, action)`, `item_link(href, title, description, action, attrs)` (emits `<a>` root)
  - Group support: `item_group(children)` with `role="list"`, `item_separator()` with `role="separator"`
  - Pure-Gleam, no JS, stateless
  - Flexbox layout: media + content (title + description) + actions

### Modified

- `dev/saola/preview/model.gleam` — Added `Empties`, `Items` routes to Route ADT
- `dev/saola/preview.gleam` — Wired `/empties` and `/items` URL routes, sidebar nav links, main_pane dispatcher cases
- `dev/saola/preview/view.gleam` — Added 2 dispatch functions: `view_empties()`, `view_items()`

### Preview

- Created `dev/saola/preview/empty_preview.gleam` — 3 empty-state demos: bare, with icon, with action
- Created `dev/saola/preview/item_preview.gleam` — 5 demos: variants, sizes, media variants, grouped with separators, link-item

### Tests

- `test/new_widget_tests6.gleam` — New comprehensive test suite
  - 19 new tests covering Empty and Item widgets
  - Total suite now at **272 tests passing**
  - Coverage includes: variants, sizes, media variants, shortcut functions, role attributes, CSS classes, omission of empty sections

### CSS Changes

- Added ~90 lines of CSS (empty + item styles)
- **Empty** (`.empty-*` classes):
  - Root: dashed border, flex center, gap/padding rules
  - Header: centered max-width 24rem, sub-elements: media, title (h2), description (p)
  - Media: default transparent, icon variant with 2.5rem box + rounded corners + bg-muted
  - Description: text color muted-foreground, nested `<a>` with underline
  - Content: flex column, centered, 24rem max-width
- **Item** (`.item-*` classes):
  - Root: flex wrap, gap 1rem, border/border-radius, transition on hover
  - Variants: default (transparent), outline (border), muted (bg-muted)
  - Sizes: lg (1rem gap/padding), sm (0.625rem gap, 0.75rem/1rem padding)
  - Media: flex, shrink-0; icon variant (2rem box + border), image variant (2.5rem + object-fit)
  - Content: flex-1, flex-column, title + description (2-line clamp)
  - Actions: flex, gap 0.5rem
  - Group & Separator: flex-column layout, hr border-top only
- All styles use Basecoat design tokens (--color-muted, --color-border, --color-foreground, --color-muted-foreground, --radius-md, --radius-lg)

### Documentation

- Updated `docs/development-roadmap.md` — Marked Empty, Item as Complete; updated metrics (47 widgets, +2)
- Updated project metrics: Batch 9 in key milestones

## [2026-05-17] — Batch 8: Carousel, Combobox, Navigation Menu, Toast Enhancement

### Added

**New Widgets**
- **Carousel** (`src/saola/carousel.gleam`) — Horizontal/vertical scroll-snap carousel with prev/next navigation
  - Backed by `assets/saola-carousel.mjs` web component
  - Orientation support: Horizontal (default) or Vertical
  - Loop mode for infinite scrolling
  - Slide change detection via `slide-change` CustomEvent
  - Full API: `carousel_full`, `carousel_simple`
  - Responsive scroll-snap viewport

- **Combobox** (`src/saola/combobox.gleam`) — Searchable select with filterable option list
  - Case-insensitive substring filtering via `combobox_filter` helper
  - Query/value/open state managed by consumer
  - Check icon for selected option
  - Full API: `combobox_full`, `combobox_simple`
  - Keyboard accessible: role="combobox", role="listbox"

- **Navigation Menu** (`src/saola/navigation_menu.gleam`) — Click-driven top navigation with dropdowns
  - Link items with active state styling
  - Dropdown support with click-to-open/close
  - Two dropdown content modes: NavMenuSimple (list of links) or NavMenuRich (custom Element)
  - Full API: `navigation_menu_full`, `navigation_menu_simple`

### Modified

**Toast Enhancement** (`src/saola/toast.gleam`) — BREAKING CHANGE: Now generic over `msg`
  - Added variants: `Success`, `Warning`, `Info` (previous: Default, Destructive)
  - Added optional action buttons via `ToastAction(label, on_click)` 
  - Type signature changed from `Toast` → `Toast(msg)` (requires migration in consumers)
  - New convenience function `new_toast_simple` (no action)
  - CSS variants for new toast types (`toast-success`, `toast-warning`, `toast-info`)

### Migration Guide

For existing toast consumers:
- Change `List(toast.Toast)` → `List(toast.Toast(Msg))`
- Change `AddToast(toast.Toast)` → `AddToast(toast.Toast(Msg))`
- Replace `toast.new_toast(t, d, v)` with `toast.new_toast_simple(t, d, v)` OR use `toast.new_toast(t, d, v, Some(ToastAction(...)))`

### Preview

- Updated `dev/saola/preview/model.gleam` — Added Carousels, Comboboxes, NavigationMenus routes; migrated Toast to generic msg
- Updated `dev/saola/preview.gleam` — Wired all 3 new routes, init handlers, update branches, sidebar nav links, main_pane dispatchers
- Updated `dev/saola/preview/view.gleam` — Added 3 dispatch functions for new widgets
- Created `dev/saola/preview/carousel_preview.gleam` — Horizontal + vertical carousel demos
- Created `dev/saola/preview/combobox_preview.gleam` — Simple + full search combobox demos
- Created `dev/saola/preview/navigation_menu_preview.gleam` — Navigation menu with simple + rich dropdowns
- Migrated `dev/saola/preview/toast.gleam` — Added Success/Warning/Info/action button demos

### Tests

- `test/new_widget_tests5.gleam` — New comprehensive test suite
  - 27 new tests covering Carousel, Combobox, Navigation Menu, Toast variants & actions
  - Total suite now at 253 tests passing
  - Coverage includes: tag rendering, attribute presence, filter logic, open/closed states, variant classes, action button detection

### CSS Changes

- Added styles for `.carousel-root` (flex/overflow viewport)
- Added ~50 lines for combobox (trigger, panel, options, search, empty state)
- Added ~50 lines for navigation menu (menu, items, dropdowns, content panels)
- Added toast variant CSS: `.toast-success`, `.toast-warning`, `.toast-info` with appropriate colors
- All styles use Basecoat design tokens (--color-popover, --color-border, --radius-md, etc.)

### Documentation

- Updated `docs/development-roadmap.md` — Marked carousel, combobox, navigation_menu, toast as Complete
- Updated project metrics: 45 widgets complete, 253 total tests passing

## [2026-05-17] — Batch 7: Navigation, Layout & Data Widgets

### Added

**New Widgets**
- **Sidebar** (`src/saola/sidebar.gleam`) — Collapsible sidebar navigation panel
  - Side position control: Left (primary) or Right
  - Variant support: Default or Minimal
  - Collapsible state with toggle trigger
  - Sub-components: `sidebar_header`, `sidebar_footer`, `sidebar_content`, `sidebar_group`, `sidebar_menu_item`
  - Full API: `sidebar_full`, `sidebar_simple`
  - Accessible with proper ARIA labels and keyboard navigation

- **Command** (`src/saola/command.gleam`) — Command palette with search and keyboard navigation
  - Search input filtering
  - Keyboard navigation: ArrowUp/Down/Enter to select items
  - Grouped commands with labels
  - Keyboard shortcuts display
  - Disabled item state
  - Helper functions: `command_nav_up`, `command_nav_down`, `command_get_value_at`, `command_item_count`
  - Full API: `command_full`

- **Resizable** (`src/saola/resizable.gleam`) — Drag-to-resize panels for flexible layouts
  - Backed by `assets/saola-resizable-panels.mjs` web component
  - Horizontal (default) and vertical direction support
  - Smooth dragging with resize handles
  - Full API: `resizable_full`, `resizable_simple`

- **Data Table** (`src/saola/data_table.gleam`) — Generic typed column data table with sorting, filtering, pagination
  - Strongly-typed columns via `DataTableColumn(row, msg)` type
  - Sortable column headers with direction indicators
  - Global filter input with live filtering
  - Row pagination with jump-to-page capability
  - Row selection with multi-select checkboxes
  - Helpers: `toggle_sort`, `set_filter`, `set_page`, `toggle_row`, `total_pages`
  - Full API: `data_table_full`, `data_table_simple`

### Tests

- `test/new_widget_tests4.gleam` — New comprehensive test suite
  - 37 new tests covering Command, Sidebar, Resizable, Data Table
  - Total suite now at 230 tests passing
  - Coverage includes: default rendering, variants, keyboard navigation, state transitions, ARIA attributes

### Documentation

- Updated `README.md` — Added 4 new widgets to widget table with full/shortcut API references
- Updated `docs/development-roadmap.md` — Marked Sidebar, Command, Resizable, Data Table as Complete; updated phase status
- Updated project metrics: 41 widgets complete, 230 total tests passing

## [2026-05-17] — Batch 6: Specialized Widgets

### Added

**New Widgets**
- **Spinner** (`src/saola/spinner.gleam`) — Animated loading indicator
  - Three sizes: Small (1rem), Medium (1.5rem, default), Large (2rem)
  - CSS animation with configurable colors via CSS variables
  - Accessible with `role="status"` and `aria-label="Loading"`

- **Native Select** (`src/saola/native_select.gleam`) — Native HTML select wrapper
  - Styled dropdown with custom icon overlay
  - Support for `<optgroup>` hierarchies
  - Two sizes: Default (2rem), Small (1.75rem)
  - Disabled state with opacity reduction
  - Full keyboard accessibility

- **Button Group** (`src/saola/button_group.gleam`) — Fused button sets
  - Horizontal (default) and vertical orientations
  - CSS border fusion removes internal borders
  - Accessible with `role="group"`
  - Works with any button element

- **Input Group** (`src/saola/input_group.gleam`) — Compound input control
  - Prefix and suffix addon slots
  - Wraps input or textarea with visual grouping
  - `aria-invalid` propagation for error states
  - Works with saola/input and native textarea

- **Context Menu** (`src/saola/context_menu.gleam`) — Right-click menu system
  - Full menu item hierarchy: actions, destructive items, disabled items, separators, groups
  - Keyboard shortcut display
  - Automatic positioning via clientX/clientY event capture
  - Fixed positioning with backdrop
  - Nested group support with labels

- **Drawer** (`src/saola/drawer.gleam`) — Side/bottom slide-out panel
  - Four positions: Bottom (primary), Top, Left, Right
  - Handle bar for Bottom/Top (visual affordance)
  - Optional description and footer slots
  - Fixed positioning with backdrop dismiss
  - Configurable z-index stacking

### Modified

- `dev/saola/preview/model.gleam` — Added routes and model fields for new widgets
- `dev/saola/preview.gleam` — Added URL routes, update handlers, nav links
- `dev/saola/preview/view.gleam` — Added preview dispatchers for all 6 widgets
- `assets/app.css` — Added ~340 lines of CSS for all 6 widgets

### Tests

- `test/new_widget_tests3.gleam` — New comprehensive test suite
  - 193 total tests passing across all 6 widgets
  - Coverage includes: default rendering, size variants, disabled states, ARIA attributes, positioning, CSS classes
  - All tests in `gleam test` suite pass

### Documentation

- Created `docs/development-roadmap.md` — Project-wide widget progress tracking
- Created `docs/project-changelog.md` — Historical record of all changes

### CSS Changes

Added styles for:
- `.spinner`, `.spinner-sm`, `.spinner-md`, `.spinner-lg` with @keyframes spin animation
- `.native-select-wrapper`, `.native-select`, `.native-select-icon` with focus states
- `.button-group`, `.button-group-vertical` with border fusion rules
- `.input-group`, `.input-group-addon`, `.input-group-control` with grouped styling
- `.context-menu-*` classes for popup, items, shortcuts, separators, groups
- `.drawer`, `.drawer-bottom/top/left/right` with position-specific styles

## [2026-05-16] — Batch 5: Date/Time Widgets

### Added

- **Calendar** (`src/saola/calendar.gleam`) — Interactive month/year calendar grid
- **Date Picker** (`src/saola/date_picker.gleam`) — Date selection with calendar

### Modified

- `dev/saola/preview.gleam` — Routes and handlers for calendar/date picker

## Previous Releases

### Phase 1-3 Summary (29 widgets)

Core widgets through form controls, including:
- Button, Input, Textarea, Label, Badge, Alert, Card
- Checkbox, Radio, Switch
- Dropdown Menu, Select, Combobox, Dialog, Popover, Tooltip, Tabs, Accordion, Carousel
- Toast, Alert Dialog, Hover Card
- Form Field, Slider, Range Slider, Toggle Group, Segmented Control
- Breadcrumb, Pagination
- Radio Group (13-widget batch)
- Scroll Area, Aspect Ratio, Collapsible, Sheet, Menubar, Input OTP

---

## Metrics

| Metric | Value |
|--------|-------|
| Total widgets shipped | 47 |
| Test suite coverage | 272 tests passing |
| New tests (Batch 9) | 19 |
| New tests (Batch 8) | 27 |
| New tests (Batch 7) | 37 |
| Total phases | 6 |
| Completed phases | 2 (Phases 1-2) |
| In progress phases | 4 (Phases 3-6) |

## Notes

- All widgets follow Saola naming conventions: stateless design, full+shortcut pattern, CSS variable theming
- Widget tests use `gleam/html` element rendering with `a.to_string()` and string assertions
- Web components (Resizable) use Shadow DOM + property setters for structured data
- CSS uses Basecoat class names; no Tailwind or shadcn/ui class dependencies post-porting
- ARIA attributes explicit and uncoupled from Radix UI
- Data Table uses generic type parameters for fully-typed column definitions
