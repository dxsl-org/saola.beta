import gleam/option.{None}
import lustre/element.{type Element}
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}
import saola/timeline

pub fn view() -> Element(Message) {
  let basic_items = [
    timeline.TimelineItem(
      time: "09:00",
      title: "Project kickoff",
      description: "Initial planning session with stakeholders.",
      icon: None,
      variant: timeline.Default,
    ),
    timeline.TimelineItem(
      time: "11:30",
      title: "Design review",
      description: "Reviewed wireframes and approved the design system.",
      icon: None,
      variant: timeline.Success,
    ),
    timeline.TimelineItem(
      time: "14:00",
      title: "Build phase",
      description: "Development started on core components.",
      icon: None,
      variant: timeline.Default,
    ),
    timeline.TimelineItem(
      time: "16:45",
      title: "Deploy failed",
      description: "CI pipeline encountered an unexpected error.",
      icon: None,
      variant: timeline.Error,
    ),
    timeline.TimelineItem(
      time: "18:00",
      title: "Hotfix deployed",
      description: "Issue resolved and system is back online.",
      icon: None,
      variant: timeline.Warning,
    ),
  ]

  doc_page.doc_page(
    "Timeline",
    "A vertical timeline widget for displaying ordered events with status variants.",
    [
      DocSection("basic", "Basic", [
        timeline.timeline_simple(basic_items),
      ]),
      DocSection("no-timestamps", "No Timestamps", [
        timeline.timeline_simple([
          timeline.TimelineItem(
            time: "",
            title: "Step one",
            description: "Create your account.",
            icon: None,
            variant: timeline.Success,
          ),
          timeline.TimelineItem(
            time: "",
            title: "Step two",
            description: "Configure your workspace.",
            icon: None,
            variant: timeline.Default,
          ),
          timeline.TimelineItem(
            time: "",
            title: "Step three",
            description: "Invite your team.",
            icon: None,
            variant: timeline.Default,
          ),
        ]),
      ]),
      DocSection("usage", "Usage", [
        doc_page.snippet([
          "import saola/timeline",
          "",
          "timeline.timeline_simple([",
          "  timeline.TimelineItem(",
          "    time: \"09:00\",",
          "    title: \"Project kickoff\",",
          "    description: \"Initial planning session.\",",
          "    icon: None,",
          "    variant: timeline.Default,",
          "  ),",
          "])",
        ]),
      ]),
    ],
  )
}
