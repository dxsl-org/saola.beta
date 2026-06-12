import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/carousel
import saola/preview/model.{type Message, type Model, CarouselChanged}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  let slides = [
    h.div([a.class("carousel-slide-demo")], [h.span([], [text("Slide 1")])]),
    h.div([a.class("carousel-slide-demo")], [h.span([], [text("Slide 2")])]),
    h.div([a.class("carousel-slide-demo")], [h.span([], [text("Slide 3")])]),
  ]

  doc_page.doc_page(
    "Carousel",
    "Scroll-snap carousel wrapping a web component. Swipe or scroll to navigate.",
    [
      DocSection("horizontal", "Horizontal (default)", [
        h.div([a.style("width", "400px")], [
          carousel.carousel_simple(
            slides,
            model.carousel_index,
            fn(idx, can_prev, can_next) {
              CarouselChanged(idx, can_prev, can_next)
            },
          ),
        ]),
        h.p([a.class("text-sm text-muted-foreground")], [
          text(
            "Current: "
            <> {
              case model.carousel_index {
                0 -> "Slide 1"
                1 -> "Slide 2"
                _ -> "Slide 3"
              }
            },
          ),
        ]),
      ]),
      DocSection("vertical", "Vertical", [
        h.div([a.style("width", "400px; height: 250px")], [
          carousel.carousel(
            slides,
            0,
            False,
            True,
            fn(idx, can_prev, can_next) {
              CarouselChanged(idx, can_prev, can_next)
            },
            carousel.CarouselAttrs(
              orientation: carousel.Vertical,
              loop: False,
              class: "",
            ),
          ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/carousel",
          "",
          "carousel.carousel_simple(",
          "  slides,",
          "  model.carousel_index,",
          "  fn(idx, can_prev, can_next) {",
          "    CarouselChanged(idx, can_prev, can_next)",
          "  },",
          ")",
        ]),
      ]),
    ],
  )
}
