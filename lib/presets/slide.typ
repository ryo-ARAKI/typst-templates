#import "../core/config.typ": slide-config
#import "../core/locale.typ": apply-japanese-text
#import "../components/math.typ": apply-math-font, apply-inline-japanese-math-spacing, apply-block-equation-spacing
#import "../adapters/touying.typ": *

#let slide-theme(body, config: none) = {
  let resolved = slide-config(overrides: config)
  let metadata = resolved.at("metadata")
  set text(font: resolved.at("text-font"))
  apply-math-font(font: resolved.at("math-font"))
  apply-japanese-text(cjk-font: resolved.at("cjk-font"))
  apply-inline-japanese-math-spacing()
  apply-block-equation-spacing()

  show: university-theme.with(
    header-right: "",
    footer-columns: resolved.at("footer-columns"),
    footer-a: self => {
      sym.section + " " + utils.display-current-heading(level: 1)
    },
    footer-b: self => {
      h(1fr)
      self.info.summary
      h(1fr)
      self.info.date.display(self.datetime-format)
      h(1fr)
    },
    footer-c: context utils.slide-counter.display() + " / " + utils.last-slide-number,
    config-info(
      title: metadata.at("title"),
      subtitle: metadata.at("subtitle"),
      author: metadata.at("authors-inline"),
      date: metadata.at("date"),
      institution: if resolved.at("institution") != [] {
        resolved.at("institution")
      } else {
        metadata.at("affiliations-inline")
      },
      logo: metadata.at("logo"),
      summary: metadata.at("summary"),
    ),
    config-common(datetime-format: resolved.at("datetime-format")),
    config-common(new-section-slide-fn: none),
    config-common(handout: resolved.at("handout")),
  )
  body
}

#let setup-slide(config: none) = [#show: slide-theme.with(config: config)]
#let slide-title-slide() = title-slide()
