import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/input_otp
import saola/preview/model.{type Message, type Model, InputOtpChanged}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page("Input OTP", "An accessible one-time password input.", [
    DocSection("six-digit", "6-digit OTP", [
      h.div([a.class("grid gap-4 mt-4")], [
        input_otp.input_otp_simple(model.input_otp_value, InputOtpChanged),
        h.p(
          [
            a.style("font-size", "0.875rem"),
            a.style("color", "var(--color-muted-foreground, #6c757d)"),
          ],
          [
            text("Value: " <> model.input_otp_value),
          ],
        ),
      ]),
    ]),
    DocSection("four-digit", "4-digit PIN", [
      h.div([a.class("grid gap-4 mt-4")], [
        input_otp.input_otp(
          model.input_otp_value,
          InputOtpChanged,
          input_otp.InputOtpAttrs(..input_otp.default_attrs, length: 4),
        ),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/input_otp",
        "",
        "// 6-digit (default)",
        "input_otp.input_otp_simple(model.input_otp_value, InputOtpChanged)",
        "",
        "// 4-digit PIN",
        "input_otp.input_otp(",
        "  model.input_otp_value,",
        "  InputOtpChanged,",
        "  input_otp.InputOtpAttrs(..input_otp.default_attrs, length: 4),",
        ")",
      ]),
    ]),
  ])
}
