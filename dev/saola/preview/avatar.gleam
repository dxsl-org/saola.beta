import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/avatar
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

pub fn view() -> Element(Message) {
  doc_page.doc_page("Avatar", "User avatars with image and initials fallback.", [
    DocSection("initials", "Initials", [
      h.div([a.class("flex gap-4 items-center")], [
        avatar.avatar(avatar.Initials("JD"), avatar.Small, ""),
        avatar.avatar(avatar.Initials("AB"), avatar.Medium, ""),
        avatar.avatar(avatar.Initials("XY"), avatar.Large, ""),
      ]),
    ]),
    DocSection("image", "Image", [
      h.div([a.class("flex gap-4 items-center")], [
        avatar.avatar(
          avatar.ImageSrc(
            "https://api.dicebear.com/7.x/avataaars/svg?seed=saola",
            "Saola avatar",
          ),
          avatar.Small,
          "",
        ),
        avatar.avatar(
          avatar.ImageSrc(
            "https://api.dicebear.com/7.x/avataaars/svg?seed=lustre",
            "Lustre avatar",
          ),
          avatar.Medium,
          "",
        ),
        avatar.avatar(
          avatar.ImageSrc(
            "https://api.dicebear.com/7.x/avataaars/svg?seed=gleam",
            "Gleam avatar",
          ),
          avatar.Large,
          "",
        ),
      ]),
    ]),
    DocSection("shortcuts", "Shortcuts", [
      h.div([a.class("flex gap-4 items-center")], [
        avatar.avatar_initials("NG"),
        avatar.avatar_image(
          "https://api.dicebear.com/7.x/avataaars/svg?seed=ng",
          "User avatar",
        ),
      ]),
    ]),
    DocSection("usage", "Usage", [
      doc_page.snippet([
        "import saola/avatar",
        "",
        "avatar.avatar_initials(\"JD\")",
        "avatar.avatar_image(\"https://…/avatar.svg\", \"Alt text\")",
        "",
        "// Full control:",
        "avatar.avatar(avatar.Initials(\"AB\"), avatar.Medium, \"extra-class\")",
      ]),
    ]),
  ])
}
