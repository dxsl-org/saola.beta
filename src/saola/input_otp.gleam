//// One-time-password input widget — dual-style `Config` (uniform Saola pattern):
////
//// ```gleam
//// input_otp.input_otp_simple(model.code, CodeChanged)               // shortcut (6 slots)
//// input_otp.new()
//// |> input_otp.length(4)
//// |> input_otp.view(model.code, CodeChanged)
//// ```

import gleam/int
import gleam/list
import gleam/result
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import lustre/event as e

/// Presentation options for an OTP input. Public for record-update syntax. The
/// `value` and `on_change` handler are the required data, passed to `view`.
pub type InputOtpConfig {
  InputOtpConfig(length: Int, disabled: Bool, class: String)
}

/// Builder entry point. Defaults: 6 slots, enabled, no extra class.
pub fn new() -> InputOtpConfig {
  InputOtpConfig(length: 6, disabled: False, class: "")
}

/// Config-style entry point — alias of `new` for record-update syntax.
pub fn default_config() -> InputOtpConfig {
  new()
}

/// Set the number of slots (default 6).
pub fn length(config: InputOtpConfig, length: Int) -> InputOtpConfig {
  InputOtpConfig(..config, length: length)
}

/// Set the disabled state.
pub fn disabled(config: InputOtpConfig, disabled: Bool) -> InputOtpConfig {
  InputOtpConfig(..config, disabled: disabled)
}

/// Append an extra CSS class on the root. Additive only.
pub fn add_class(config: InputOtpConfig, class: String) -> InputOtpConfig {
  let merged = case config.class {
    "" -> class
    existing -> existing <> " " <> class
  }
  InputOtpConfig(..config, class: merged)
}

fn slot_indices(length: Int) -> List(Int) {
  case length <= 0 {
    True -> []
    False -> slot_indices_from(0, length)
  }
}

fn slot_indices_from(current: Int, max: Int) -> List(Int) {
  case current >= max {
    True -> []
    False -> [current, ..slot_indices_from(current + 1, max)]
  }
}

fn char_at(chars: List(String), idx: Int) -> String {
  chars
  |> list.drop(idx)
  |> list.first
  |> result.unwrap("")
}

/// Render the OTP slot group. `value` is the current string (up to `length`
/// chars); `on_change` fires with the new string when any slot changes.
pub fn view(
  config: InputOtpConfig,
  value: String,
  on_change: fn(String) -> msg,
) -> Element(msg) {
  let chars = string.to_graphemes(value)
  let extra_class_attrs = case config.class {
    "" -> []
    c -> [a.class(c)]
  }
  let disabled_attrs = case config.disabled {
    True -> [a.disabled(True)]
    False -> []
  }
  let slots =
    slot_indices(config.length)
    |> list.map(fn(idx) {
      let slot_val = char_at(chars, idx)
      h.input(list.flatten([
        [
          a.type_("text"),
          a.class("input input-otp-slot"),
          a.id("otp-slot-" <> int.to_string(idx)),
          a.value(slot_val),
          a.attribute("maxlength", "1"),
          a.attribute("inputmode", "numeric"),
          a.attribute("autocomplete", "one-time-code"),
          a.attribute("aria-label", "Digit " <> int.to_string(idx + 1)),
        ],
        disabled_attrs,
        [
          e.on_input(fn(new_char) {
            let before = list.take(chars, idx)
            let after = list.drop(chars, idx + 1)
            let new_chars = list.flatten([before, [new_char], after])
            on_change(string.join(new_chars, ""))
          }),
        ],
      ]))
    })
  h.div(
    list.flatten([
      [a.class("input-otp"), a.attribute("aria-label", "One-time password")],
      extra_class_attrs,
    ]),
    slots,
  )
}

// --- Convenience shortcuts ---

pub fn input_otp_simple(
  value: String,
  on_change: fn(String) -> msg,
) -> Element(msg) {
  new() |> view(value, on_change)
}
