import lustre/element.{type Element}
import saola/card
import saola/code_editor
import saola/d3_bar_chart
import saola/lustre_bar_chart
import saola/monaco_editor
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn d3_charts() -> Element(Message) {
  doc_page.doc_page(
    "D3 Charts",
    "A blackbox Saola widget beside a pure Lustre SVG implementation.",
    [
      DocSection("demo", "Demo", [
        d3_card(),
        lustre_card(),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/d3_bar_chart",
          "import saola/lustre_bar_chart",
          "",
          "// D3 blackbox — rendered by D3 via a custom element",
          "d3_bar_chart.bar_chart(",
          "  [d3_bar_chart.ChartPoint(\"Q1\", 32.0), ...],",
          "  attrs: d3_bar_chart.BarChartAttrs(",
          "    ..d3_bar_chart.default_bar_chart_attrs,",
          "    title: \"Revenue\",",
          "    height: 320,",
          "  ),",
          ")",
          "",
          "// Pure Lustre SVG — no D3 runtime",
          "lustre_bar_chart.bar_chart(",
          "  [lustre_bar_chart.ChartPoint(\"Q1\", 32.0), ...],",
          "  attrs: lustre_bar_chart.BarChartAttrs(",
          "    ..lustre_bar_chart.default_bar_chart_attrs,",
          "    title: \"Revenue\",",
          "    height: 320,",
          "  ),",
          ")",
        ]),
      ]),
    ],
  )
}

pub fn monaco_editor() -> Element(Message) {
  doc_page.doc_page(
    "Code Editor",
    "Blackbox editor widgets. Saola renders a single custom element; the editor runtime owns keyboard interaction and text model.",
    [
      DocSection("demo", "Demo", [
        codemirror_card(),
        monaco_card(),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/code_editor",
          "import saola/monaco_editor",
          "",
          "// CodeMirror 6 — lightweight, fast startup",
          "code_editor.editor(",
          "  attrs: code_editor.EditorAttrs(",
          "    ..code_editor.default_editor_attrs,",
          "    value: \"pub fn main() { ... }\",",
          "    language: \"javascript\",",
          "    height: 300,",
          "  ),",
          ")",
          "",
          "// Monaco — VS Code engine with IntelliSense",
          "monaco_editor.editor(",
          "  attrs: monaco_editor.EditorAttrs(",
          "    ..monaco_editor.default_editor_attrs,",
          "    value: \"pub fn main() { ... }\",",
          "    language: \"javascript\",",
          "    height: 300,",
          "  ),",
          ")",
        ]),
      ]),
    ],
  )
}

fn codemirror_card() -> Element(Message) {
  card.new()
  |> card.title("CodeMirror 6")
  |> card.description("Lightweight editor — fast startup, tree-sitter grammar, and a small bundle footprint.")
  |> card.view([
    code_editor.editor(
      attrs: code_editor.EditorAttrs(
        ..code_editor.default_editor_attrs,
        value: "import gleam/io\n\npub fn main() {\n  io.println(\"Hello from Saola + CodeMirror\")\n}\n",
        language: "javascript",
        height: 300,
      ),
    ),
  ])
}

fn monaco_card() -> Element(Message) {
  card.new()
  |> card.title("Monaco Editor")
  |> card.description("VS Code's editor engine — IntelliSense, multi-cursor, diff view, and rich language support.")
  |> card.view([
    monaco_editor.editor(
      attrs: monaco_editor.EditorAttrs(
        ..monaco_editor.default_editor_attrs,
        value: "import gleam/io\n\npub fn main() {\n  io.println(\"Hello from Saola + Monaco\")\n}\n",
        language: "javascript",
        height: 300,
      ),
    ),
  ])
}

fn d3_card() -> Element(Message) {
  card.new()
  |> card.title("D3 blackbox")
  |> card.description("Rendered by D3, mounted through a Saola custom element.")
  |> card.view([
    d3_bar_chart.bar_chart(
      chart_data_d3(),
      attrs: d3_bar_chart.BarChartAttrs(
        ..d3_bar_chart.default_bar_chart_attrs,
        title: "Revenue",
        height: 320,
      ),
    ),
  ])
}

fn lustre_card() -> Element(Message) {
  card.new()
  |> card.title("Pure Lustre SVG")
  |> card.description("Rendered as regular Lustre SVG elements with no D3 runtime.")
  |> card.view([
    lustre_bar_chart.bar_chart(
      chart_data_lustre(),
      attrs: lustre_bar_chart.BarChartAttrs(
        ..lustre_bar_chart.default_bar_chart_attrs,
        title: "Revenue",
        height: 320,
      ),
    ),
  ])
}

fn chart_data_d3() -> List(d3_bar_chart.ChartPoint) {
  [
    d3_bar_chart.ChartPoint("Q1", 32.0),
    d3_bar_chart.ChartPoint("Q2", 48.0),
    d3_bar_chart.ChartPoint("Q3", 41.0),
    d3_bar_chart.ChartPoint("Q4", 64.0),
  ]
}

fn chart_data_lustre() -> List(lustre_bar_chart.ChartPoint) {
  [
    lustre_bar_chart.ChartPoint("Q1", 32.0),
    lustre_bar_chart.ChartPoint("Q2", 48.0),
    lustre_bar_chart.ChartPoint("Q3", 41.0),
    lustre_bar_chart.ChartPoint("Q4", 64.0),
  ]
}
