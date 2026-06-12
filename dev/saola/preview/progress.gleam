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
            progress.progress(
              50,
              progress.ProgressAttrs(
                ..progress.default_attrs,
                variant: progress.Default,
                label: "Loading…",
              ),
            ),
            progress.progress(
              75,
              progress.ProgressAttrs(
                ..progress.default_attrs,
                variant: progress.Success,
                label: "75% complete",
              ),
            ),
            progress.progress(
              25,
              progress.ProgressAttrs(
                ..progress.default_attrs,
                variant: progress.Destructive,
                label: "Error — 25% processed",
              ),
            ),
          ]),
          h.div([a.class("grid gap-4")], [
            h.h2([], [text("Custom range (0–5 steps)")]),
            progress.progress(
              3,
              progress.ProgressAttrs(
                min: 0,
                max: 5,
                variant: progress.Default,
                label: "Step 3 of 5",
                class: "",
              ),
            ),
          ]),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/progress",
          "",
          "progress.progress_simple(65)",
          "",
          "progress.progress(75, progress.ProgressAttrs(",
          "  ..progress.default_attrs,",
          "  variant: progress.Success,",
          "  label: \"75% complete\",",
          "))",
        ]),
      ]),
    ],
  )
}
