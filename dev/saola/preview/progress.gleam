import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}
import saola/progress

pub fn view() -> Element(Message) {
  doc_page.doc_page(
    "Progress",
    "Accessible progress bars with ARIA attributes.",
    [
      DocSection("demo", "Demo", [
        h.div([a.class("grid gap-6")], [
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Default")]),
            progress.progress_simple(0),
            progress.progress_simple(30),
            progress.progress_simple(65),
            progress.progress_simple(100),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Variants")]),
            progress.new()
              |> progress.label("Loading…")
              |> progress.view(50),
            progress.new()
              |> progress.variant(progress.Success)
              |> progress.label("75% complete")
              |> progress.view(75),
            progress.new()
              |> progress.variant(progress.Destructive)
              |> progress.label("Error — 25% processed")
              |> progress.view(25),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Custom range (0–5 steps)")]),
            progress.new()
              |> progress.max(5)
              |> progress.label("Step 3 of 5")
              |> progress.view(3),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/progress",
          "",
          "progress.progress_simple(65)",
          "",
          "progress.new()",
          "|> progress.variant(progress.Success)",
          "|> progress.label(\"75% complete\")",
          "|> progress.view(75)",
        ]),
      ]),
    ],
  )
}
