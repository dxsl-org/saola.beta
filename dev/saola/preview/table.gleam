import lustre/element.{type Element}
import saola/badge
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}
import saola/table

pub fn view() -> Element(Message) {
  let headers = ["Name", "Email", "Status", "Role"]
  let rows = [
    table.TableRow([
      table.TextCell("Alice Martin"),
      table.TextCell("alice@example.com"),
      table.ElementCell(badge.badge_default("Active")),
      table.TextCell("Admin"),
    ]),
    table.TableRow([
      table.TextCell("Bob Chen"),
      table.TextCell("bob@example.com"),
      table.ElementCell(badge.badge_secondary("Inactive")),
      table.TextCell("Member"),
    ]),
    table.TableRow([
      table.TextCell("Carol Kim"),
      table.TextCell("carol@example.com"),
      table.ElementCell(badge.badge_outline("Pending")),
      table.TextCell("Member"),
    ]),
  ]

  doc_page.doc_page(
    "Tables",
    "Data tables with typed cells and optional captions.",
    [
      DocSection("demo", "Demo", [
        table.table_simple(
          headers: headers,
          rows: rows,
          extra_attrs: table.TableExtraAttrs("Team members", ""),
        ),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/table",
          "",
          "table.table_simple(",
          "  headers: [\"Name\", \"Status\"],",
          "  rows: [",
          "    table.TableRow([",
          "      table.TextCell(\"Alice\"),",
          "      table.ElementCell(badge.badge_default(\"Active\")),",
          "    ]),",
          "  ],",
          "  extra_attrs: table.TableExtraAttrs(\"Caption\", \"\"),",
          ")",
        ]),
      ]),
    ],
  )
}
