import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub type ScrollAreaAttrs {
  ScrollAreaAttrs(
    height: String,
    width: String,
    class: String,
  )
}

pub const default_attrs = ScrollAreaAttrs(
  height: "200px",
  width: "100%",
  class: "",
)

pub fn scroll_area_full(
  content: Element(msg),
  attrs: ScrollAreaAttrs,
) -> Element(msg) {
  let extra_class = case attrs.class {
    "" -> a.none()
    c -> a.class(c)
  }
  h.div(
    [
      a.class("scroll-area"),
      extra_class,
      a.style("height", attrs.height),
      a.style("width", attrs.width),
      a.attribute("data-radix-scroll-area-root", ""),
    ],
    [
      h.div(
        [
          a.class("scroll-area-viewport"),
          a.attribute("tabindex", "0"),
        ],
        [content],
      ),
    ],
  )
}

pub fn scroll_area_simple(
  content: Element(msg),
  height: String,
) -> Element(msg) {
  scroll_area_full(content, ScrollAreaAttrs(..default_attrs, height: height))
}
