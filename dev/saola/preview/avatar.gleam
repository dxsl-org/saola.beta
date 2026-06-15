import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import saola/avatar
import saola/preview/model.{type Message}
import saola/preview/view/doc_page.{DocSection}

fn img(seed: String, alt: String, size: avatar.AvatarSize) -> Element(Message) {
  avatar.new()
  |> avatar.size(size)
  |> avatar.view(avatar.ImageSrc(
    "https://api.dicebear.com/7.x/avataaars/svg?seed=" <> seed,
    alt,
  ))
}

pub fn view() -> Element(Message) {
  doc_page.doc_page("Avatar", "User avatars with image and initials fallback.", [
    DocSection("initials", "Initials", [
      h.div([a.class("flex gap-4 items-center")], [
        avatar.new()
          |> avatar.size(avatar.Small)
          |> avatar.view(avatar.Initials("JD")),
        avatar.new()
          |> avatar.size(avatar.Medium)
          |> avatar.view(avatar.Initials("AB")),
        avatar.new()
          |> avatar.size(avatar.Large)
          |> avatar.view(avatar.Initials("XY")),
      ]),
    ]),
    DocSection("image", "Image", [
      h.div([a.class("flex gap-4 items-center")], [
        img("saola", "Saola avatar", avatar.Small),
        img("lustre", "Lustre avatar", avatar.Medium),
        img("gleam", "Gleam avatar", avatar.Large),
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
        "// Shortcuts (medium)",
        "avatar.avatar_initials(\"JD\")",
        "avatar.avatar_image(\"https://…/avatar.svg\", \"Alt text\")",
        "",
        "// Builder — config holds size/class; view takes the source",
        "avatar.new()",
        "|> avatar.size(avatar.Large)",
        "|> avatar.view(avatar.Initials(\"AB\"))",
      ]),
    ]),
  ])
}
