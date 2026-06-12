import gleam/list
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

/// One titled, anchorable block of a docs page. The same list drives both
/// the rendered content and the right-hand TOC — they cannot drift apart.
pub type DocSection(msg) {
  DocSection(id: String, heading: String, body: List(Element(msg)))
}

/// Standard docs-page scaffold: center content column + right TOC column.
/// The left sidebar is app chrome and lives outside this scaffold.
pub fn doc_page(
  title: String,
  description: String,
  sections: List(DocSection(msg)),
) -> Element(msg) {
  h.div([a.class("doc-page")], [
    h.div([a.class("doc-content")], [
      h.h1([a.class("page-title")], [element.text(title)]),
      h.p([a.class("page-description")], [element.text(description)]),
      ..list.map(sections, render_section)
    ]),
    toc(sections),
  ])
}

/// Static code block for usage examples. Deliberately not CodeMirror —
/// one editor instance per snippet is too heavy at 70 pages.
pub fn snippet(lines: List(String)) -> Element(msg) {
  h.pre([a.class("doc-snippet")], [
    h.code([], [element.text(string.join(lines, "\n"))]),
  ])
}

fn render_section(section: DocSection(msg)) -> Element(msg) {
  h.section([a.class("doc-section")], [
    h.h2([a.id(section.id), a.class("doc-section-heading")], [
      element.text(section.heading),
    ]),
    ..section.body
  ])
}

fn toc(sections: List(DocSection(msg))) -> Element(msg) {
  h.nav([a.class("toc-pane"), a.aria_label("On this page")], [
    h.h3([a.class("toc-title")], [element.text("On this page")]),
    // rel="external" stops modem from intercepting the click, so the
    // browser performs native same-page hash navigation (scroll).
    ..list.map(sections, fn(section) {
      h.a([a.href("#" <> section.id), a.rel("external"), a.class("toc-link")], [
        element.text(section.heading),
      ])
    })
  ])
}
