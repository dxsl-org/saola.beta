import gleam/int
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message, SliderChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/slider

pub fn view(volume: Int, brightness: Int) -> Element(Message) {
  doc_page.doc_page(
    "Slider",
    "A range input for selecting a value within a numeric range.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("mt-4 grid gap-6")], [
          h.div([a.class("grid gap-2")], [
            h.label([a.class("label")], [
              text("Volume: " <> int.to_string(volume)),
            ]),
            slider.slider_simple(volume, fn(v) { SliderChanged("volume", v) }),
          ]),
          h.div([a.class("grid gap-2")], [
            h.label([a.class("label")], [
              text("Brightness: " <> int.to_string(brightness) <> "%"),
            ]),
            slider.new()
              |> slider.min(10)
              |> slider.step(10)
              |> slider.aria_label("Brightness")
              |> slider.view(
              slider.SyncValue(brightness),
              fn(v) { SliderChanged("brightness", v) },
            ),
          ]),
          h.div([a.class("grid gap-2")], [
            h.label([a.class("label")], [text("Disabled slider")]),
            slider.new()
              |> slider.disabled(True)
              |> slider.view(
              slider.SyncValue(40),
              fn(v) { SliderChanged("disabled", v) },
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/slider",
          "",
          "// Simple",
          "slider.slider_simple(model.volume, fn(v) { SliderChanged(\"volume\", v) })",
          "",
          "// Full — custom range and step",
          "slider.new()",
          "  |> slider.min(10)",
          "  |> slider.step(10)",
          "  |> slider.aria_label(\"Brightness\")",
          "  |> slider.view(slider.SyncValue(model.brightness), fn(v) { SliderChanged(\"brightness\", v) })",
        ]),
      ]),
    ],
  )
}
