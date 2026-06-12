import gleam/string
import lustre/element
import lustre/element/html as h
import saola/preview/view/doc_page.{DocSection}

pub fn doc_page_renders_title_and_description_test() {
  let html =
    doc_page.doc_page("Badges", "Inline labels.", [])
    |> element.to_string
  assert string.contains(html, "Badges")
  assert string.contains(html, "Inline labels.")
  assert string.contains(html, "doc-page")
}

pub fn doc_page_section_renders_anchored_heading_test() {
  let html =
    doc_page.doc_page("T", "D", [
      DocSection("demo", "Demo", [h.p([], [element.text("hello")])]),
    ])
    |> element.to_string
  assert string.contains(html, "id=\"demo\"")
  assert string.contains(html, "Demo")
  assert string.contains(html, "hello")
}

pub fn doc_page_toc_links_match_section_ids_test() {
  let html =
    doc_page.doc_page("T", "D", [
      DocSection("demo", "Demo", []),
      DocSection("usage", "Usage", []),
    ])
    |> element.to_string
  assert string.contains(html, "href=\"#demo\"")
  assert string.contains(html, "href=\"#usage\"")
  // modem must skip TOC links so native hash scroll works
  assert string.contains(html, "rel=\"external\"")
}

pub fn snippet_renders_pre_code_with_joined_lines_test() {
  let html =
    doc_page.snippet(["import saola/badge", "", "badge.badge_default(\"X\")"])
    |> element.to_string
  assert string.contains(html, "<pre class=\"doc-snippet\">")
  assert string.contains(html, "import saola/badge")
  assert string.contains(html, "badge.badge_default")
}
