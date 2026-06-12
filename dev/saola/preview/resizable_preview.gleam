import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/component/resizable_split.{Horizontal} as rp
import saola/preview/model.{type Message, type Model, ResizableSplitSizesChanged}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  let #(s1, s2) = case model.resizable_split_sizes {
    [a, b, ..] -> #(a, b)
    _ -> #(50.0, 50.0)
  }

  doc_page.doc_page("Resizable", "Drag-to-resize split panels.", [
    DocSection("demo", "Demo", [
      h.div([a.class("grid gap-8")], [
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("Horizontal (two panes)")]),
          h.div([a.style("height", "200px")], [
            rp.element(
              [
                a.class("resizable-root"),
                rp.direction(Horizontal),
                rp.on_resize(ResizableSplitSizesChanged),
              ],
              [
                rp.panel(
                  s1,
                  20.0,
                  h.div(
                    [a.class("flex items-center justify-center h-full text-sm")],
                    [text("Panel 1")],
                  ),
                ),
                rp.panel(
                  s2,
                  20.0,
                  h.div(
                    [a.class("flex items-center justify-center h-full text-sm")],
                    [text("Panel 2")],
                  ),
                ),
              ],
            ),
          ]),
        ]),
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("Three panes")]),
          h.div([a.style("height", "200px")], [
            rp.element(
              [
                a.class("resizable-root"),
                rp.direction(Horizontal),
                rp.on_resize(fn(sizes) { ResizableSplitSizesChanged(sizes) }),
              ],
              [
                rp.panel(
                  33.0,
                  15.0,
                  h.div(
                    [a.class("flex items-center justify-center h-full text-sm")],
                    [text("Left")],
                  ),
                ),
                rp.panel(
                  34.0,
                  15.0,
                  h.div(
                    [a.class("flex items-center justify-center h-full text-sm")],
                    [text("Center")],
                  ),
                ),
                rp.panel(
                  33.0,
                  15.0,
                  h.div(
                    [a.class("flex items-center justify-center h-full text-sm")],
                    [text("Right")],
                  ),
                ),
              ],
            ),
          ]),
        ]),
        h.div([a.class("grid gap-4")], [
          h.h2([], [text("Vertical")]),
          h.div([a.style("height", "300px")], [
            rp.element(
              [
                a.class("resizable-root"),
                rp.direction(rp.Vertical),
                rp.on_resize(fn(sizes) { ResizableSplitSizesChanged(sizes) }),
              ],
              [
                rp.panel(
                  40.0,
                  20.0,
                  h.div(
                    [a.class("flex items-center justify-center h-full text-sm")],
                    [text("Top")],
                  ),
                ),
                rp.panel(
                  60.0,
                  20.0,
                  h.div(
                    [a.class("flex items-center justify-center h-full text-sm")],
                    [text("Bottom")],
                  ),
                ),
              ],
            ),
          ]),
        ]),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/component/resizable_split.{Horizontal} as rp",
        "",
        "rp.element(",
        "  [a.class(\"resizable-root\"), rp.direction(Horizontal), rp.on_resize(OnResize)],",
        "  [",
        "    rp.panel(50.0, 20.0, h.div([], [text(\"Left\")])),",
        "    rp.panel(50.0, 20.0, h.div([], [text(\"Right\")])),",
        "  ],",
        ")",
      ]),
    ]),
  ])
}
