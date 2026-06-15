//// Stepper (multi-step progress) widget — dual-style `Config` (uniform pattern):
////
//// ```gleam
//// stepper.stepper_simple(steps, model.step)                          // shortcut
//// stepper.new()
//// |> stepper.orientation(stepper.Vertical)
//// |> stepper.view(steps, model.step, Some(StepClicked))
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

pub type StepperOrientation {
  Horizontal
  Vertical
}

pub type StepStatus {
  Pending
  Active
  Complete
  Error
}

pub type StepItem {
  StepItem(label: String, description: String, status: StepStatus)
}

/// Presentation options for a stepper. Public for record-update syntax. The
/// `steps`/`active_step`/`on_step_click` are the required data (`view`).
pub type StepperConfig {
  StepperConfig(orientation: StepperOrientation, class: String)
}

/// Builder entry point. Defaults: Horizontal, no extra class.
pub fn new() -> StepperConfig {
  StepperConfig(orientation: Horizontal, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> StepperConfig {
  new()
}

/// Set the orientation (Horizontal — default, Vertical).
pub fn orientation(
  config: StepperConfig,
  orientation: StepperOrientation,
) -> StepperConfig {
  StepperConfig(..config, orientation: orientation)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: StepperConfig, class: String) -> StepperConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  StepperConfig(..config, class: merged)
}

/// Render the stepper. `active_step` is the 0-indexed current step. When
/// `on_step_click` is `Some`, completed steps are clickable.
pub fn view(
  config: StepperConfig,
  steps: List(StepItem),
  active_step: Int,
  on_step_click: Option(fn(Int) -> msg),
) -> Element(msg) {
  let orient_class = case config.orientation {
    Horizontal -> "stepper stepper-horizontal"
    Vertical -> "stepper stepper-vertical"
  }
  let root_class = case config.class {
    "" -> orient_class
    c -> orient_class <> " " <> c
  }
  let indexed = list.index_map(steps, fn(step, idx) { #(idx, step) })
  let total = list.length(steps)
  h.ol(
    [a.class(root_class), a.attribute("aria-label", "Progress")],
    list.map(indexed, fn(pair) {
      let #(idx, step) = pair
      let status = case step.status {
        Active -> Active
        Complete -> Complete
        Error -> Error
        Pending ->
          case idx == active_step {
            True -> Active
            False ->
              case idx < active_step {
                True -> Complete
                False -> Pending
              }
          }
      }
      let step_class = case status {
        Active -> "stepper-step stepper-step-active"
        Complete -> "stepper-step stepper-step-complete"
        Error -> "stepper-step stepper-step-error"
        Pending -> "stepper-step"
      }
      let indicator_text = case status {
        Complete -> "✓"
        Error -> "✕"
        _ -> int.to_string(idx + 1)
      }
      let click_attrs = case on_step_click, status {
        Some(f), Complete -> [e.on_click(f(idx))]
        _, _ -> []
      }
      let is_last = idx == total - 1
      h.li([a.class(step_class)], [
        h.button(
          list.flatten([
            [
              a.type_("button"),
              a.class("stepper-trigger"),
              a.attribute("aria-current", case status {
                Active -> "step"
                _ -> "false"
              }),
            ],
            click_attrs,
          ]),
          [
            h.span([a.class("stepper-indicator")], [h.text(indicator_text)]),
            h.span([a.class("stepper-content")], [
              h.span([a.class("stepper-label")], [h.text(step.label)]),
              case step.description {
                "" -> element.none()
                d -> h.span([a.class("stepper-description")], [h.text(d)])
              },
            ]),
          ],
        ),
        case is_last {
          True -> element.none()
          False -> h.div([a.class("stepper-separator")], [])
        },
      ])
    }),
  )
}

// --- Convenience shortcuts ---

pub fn stepper_simple(steps: List(StepItem), active_step: Int) -> Element(msg) {
  new() |> view(steps, active_step, None)
}
