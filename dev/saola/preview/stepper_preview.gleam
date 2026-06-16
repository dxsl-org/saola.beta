import gleam/option.{Some}
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, StepperStepClicked}
import saola/preview/view/doc_page.{DocSection}
import saola/stepper

pub fn view(model: Model) -> Element(Message) {
  let steps = [
    stepper.StepItem(
      label: "Account",
      description: "Enter your credentials",
      status: stepper.Pending,
    ),
    stepper.StepItem(
      label: "Profile",
      description: "Tell us about yourself",
      status: stepper.Pending,
    ),
    stepper.StepItem(
      label: "Payment",
      description: "Choose a plan",
      status: stepper.Pending,
    ),
    stepper.StepItem(
      label: "Confirm",
      description: "Review and submit",
      status: stepper.Pending,
    ),
  ]
  doc_page.doc_page(
    "Stepper",
    "A multi-step progress indicator with horizontal and vertical modes.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-8")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [h.text("Horizontal")]),
            stepper.new()
              |> stepper.view(
                steps,
                model.stepper_step,
                Some(StepperStepClicked),
              ),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [h.text("Vertical")]),
            stepper.new()
              |> stepper.orientation(stepper.Vertical)
              |> stepper.view(
                steps,
                model.stepper_step,
                Some(StepperStepClicked),
              ),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [h.text("With error state")]),
            stepper.stepper_simple(
              [
                stepper.StepItem(
                  label: "Account",
                  description: "",
                  status: stepper.Complete,
                ),
                stepper.StepItem(
                  label: "Verification",
                  description: "Email not verified",
                  status: stepper.Error,
                ),
                stepper.StepItem(
                  label: "Done",
                  description: "",
                  status: stepper.Pending,
                ),
              ],
              1,
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/stepper",
          "import gleam/option.{Some}",
          "",
          "// model.stepper_step : Int",
          "stepper.new()",
          "|> stepper.view(steps, model.stepper_step, Some(StepperStepClicked))",
          "",
          "// Vertical orientation",
          "stepper.new()",
          "|> stepper.orientation(stepper.Vertical)",
          "|> stepper.view(steps, model.stepper_step, Some(StepperStepClicked))",
        ]),
      ]),
    ],
  )
}
