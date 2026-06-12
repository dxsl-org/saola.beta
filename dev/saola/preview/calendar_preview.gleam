import gleam/int
import gleam/option.{None, Some}
import gleam/time/calendar
import lustre/attribute as a
import lustre/element.{type Element, text}
import lustre/element/html as h
import saola/calendar as cal
import saola/preview/model.{
  type Message, type Model, CalendarDateSelected, CalendarMonthChanged,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  let #(prev_y, prev_m) =
    cal.prev_month(model.calendar_view_year, model.calendar_view_month)
  let #(next_y, next_m) =
    cal.next_month(model.calendar_view_year, model.calendar_view_month)
  doc_page.doc_page("Calendar", "A month-based date grid for selecting dates.", [
    DocSection("default", "Default", [
      h.div([a.class("grid gap-4 mt-4")], [
        cal.calendar_simple(
          model.calendar_selected,
          model.calendar_view_year,
          model.calendar_view_month,
          CalendarDateSelected,
          CalendarMonthChanged(prev_y, prev_m),
          CalendarMonthChanged(next_y, next_m),
        ),
        h.p(
          [
            a.style("font-size", "0.875rem"),
            a.style("color", "var(--color-muted-foreground, #6c757d)"),
          ],
          [
            text(case model.calendar_selected {
              None -> "No date selected"
              Some(d) ->
                "Selected: "
                <> calendar.month_to_string(d.month)
                <> " "
                <> int.to_string(d.day)
                <> ", "
                <> int.to_string(d.year)
            }),
          ],
        ),
      ]),
    ]),
    DocSection("today-highlighted", "With today highlighted", [
      h.div([a.class("grid gap-4 mt-4")], [
        cal.calendar(
          model.calendar_selected,
          model.calendar_view_year,
          model.calendar_view_month,
          CalendarDateSelected,
          CalendarMonthChanged(prev_y, prev_m),
          CalendarMonthChanged(next_y, next_m),
          cal.CalendarAttrs(..cal.default_attrs, today: Some(cal.today())),
        ),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/calendar as cal",
        "",
        "cal.calendar_simple(",
        "  model.calendar_selected,",
        "  model.calendar_view_year,",
        "  model.calendar_view_month,",
        "  CalendarDateSelected,",
        "  CalendarMonthChanged(prev_y, prev_m),",
        "  CalendarMonthChanged(next_y, next_m),",
        ")",
      ]),
    ]),
  ])
}
