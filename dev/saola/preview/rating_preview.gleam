import gleam/int
import gleam/option.{Some}
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message, type Model, RatingChanged}
import saola/preview/view/doc_page.{DocSection}
import saola/rating

pub fn view(model: Model) -> Element(Message) {
  doc_page.doc_page(
    "Rating",
    "A star rating widget with read-only and interactive modes.",
    [
      DocSection("readonly", "Read-only", [
        h.div([a.class("flex gap-4 mt-4")], [
          rating.rating_readonly(0),
          rating.rating_readonly(2),
          rating.rating_readonly(4),
          rating.rating_readonly(5),
        ]),
      ]),
      DocSection("interactive", "Interactive", [
        h.div([a.class("grid gap-4 mt-4")], [
          rating.rating_interactive(model.rating_value, RatingChanged),
        ]),
      ]),
      DocSection("custom-max", "Custom max (10 stars)", [
        h.div([a.class("grid gap-4 mt-4")], [
          rating.new()
            |> rating.max(10)
            |> rating.view(model.rating_value, rating.Interactive, Some(RatingChanged)),
          h.p([a.class("text-muted-foreground text-sm")], [
            text("Current value: " <> int.to_string(model.rating_value)),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/rating",
          "",
          "// Read-only",
          "rating.rating_readonly(4)",
          "",
          "// Interactive",
          "rating.rating_interactive(model.rating_value, RatingChanged)",
          "",
          "// Custom max",
          "rating.new()",
          "|> rating.max(10)",
          "|> rating.view(model.rating_value, rating.Interactive, Some(RatingChanged))",
        ]),
      ]),
    ],
  )
}
