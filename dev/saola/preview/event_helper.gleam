import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import lustre/attribute.{type Attribute}
import lustre/event as e

/// Returns true when `event.target` is NOT contained within any element that
/// matches `selector`. Uses `Node.contains` rooted at each matched container.
@external(javascript, "./event_ffi.mjs", "isOutside")
fn is_outside_ffi(selector: String, event: Dynamic) -> Bool

/// An `on_click` attribute that only dispatches `msg` when the click target
/// is outside all elements matching `selector` on the page.
///
/// Attach this to a page-level wrapper div so that any click outside the
/// designated containers fires the given message.
pub fn on_click_outside(selector: String, msg: msg) -> Attribute(msg) {
  e.on(
    "click",
    decode.dynamic
      |> decode.then(fn(event) {
        case is_outside_ffi(selector, event) {
          True -> decode.success(msg)
          False -> decode.failure(msg, "inside " <> selector)
        }
      }),
  )
}
