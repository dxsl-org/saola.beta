import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/date_picker
import saola/preview/event_helper
import saola/preview/model.{
  type Message, type Model, DatePicker2DateSelected, DatePicker2MonthChanged,
  DatePicker2OpenChanged, DatePickerDateSelected, DatePickerMonthChanged,
  DatePickerOpenChanged, UserClickedOutside,
}
import saola/preview/view/doc_page.{DocSection}

pub fn view(model: Model) -> Element(Message) {
  // The click-outside handler must wrap the WHOLE page (incl. title and TOC)
  // so an open calendar dismisses on any click outside a .date-picker.
  h.div([event_helper.on_click_outside(".date-picker", UserClickedOutside)], [
    doc_page.doc_page(
      "Date Picker",
      "An input that opens a calendar popover to pick a date.",
      [
        DocSection("default", "Default", [
          h.div([a.class("grid gap-4 mt-4")], [
            date_picker.date_picker_simple(
              model.date_picker_selected,
              model.date_picker_open,
              model.date_picker_view_year,
              model.date_picker_view_month,
              DatePickerDateSelected,
              DatePickerMonthChanged,
              DatePickerOpenChanged,
            ),
          ]),
        ]),
        DocSection("custom-placeholder", "Custom placeholder", [
          h.div([a.class("grid gap-4 mt-4")], [
            date_picker.new()
            |> date_picker.placeholder("Select a date...")
            |> date_picker.view(
              model.date_picker_2_selected,
              model.date_picker_2_open,
              model.date_picker_2_view_year,
              model.date_picker_2_view_month,
              DatePicker2DateSelected,
              DatePicker2MonthChanged,
              DatePicker2OpenChanged,
            ),
          ]),
        ]),
        DocSection("usage", "Usage", [
          doc_page.snippet([
            "import saola/date_picker",
            "",
            "date_picker.date_picker_simple(",
            "  model.date_picker_selected,",
            "  model.date_picker_open,",
            "  model.date_picker_view_year,",
            "  model.date_picker_view_month,",
            "  DatePickerDateSelected,",
            "  DatePickerMonthChanged,",
            "  DatePickerOpenChanged,",
            ")",
          ]),
        ]),
      ],
    ),
  ])
}
