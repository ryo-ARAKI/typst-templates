#import "../core/config.typ": slide-config
#import "../core/locale.typ": apply-japanese-text
#import "../components/math.typ": apply-math-font, apply-inline-japanese-math-spacing, apply-block-equation-spacing
#import "../adapters/touying.typ": *

#let slide-date-formats = (
  en: "[month repr:short]. [day], [year]",
  ja: "[year]年[month]月[day]日",
)

#let resolve-slide-datetime-format(config) = {
  let explicit-format = config.at("datetime-format", default: auto)
  if explicit-format != auto {
    explicit-format
  } else {
    let locale = config.at("date-locale", default: "en")
    slide-date-formats.at(locale, default: slide-date-formats.at("en"))
  }
}

#let slide-theme(body, config: none) = {
  let resolved = slide-config(overrides: config)
  let metadata = resolved.at("metadata")
  let datetime-format = resolve-slide-datetime-format(resolved)
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
      self.info.date.display(datetime-format)
      h(1fr)
    },
    footer-c: context utils.slide-counter.display() + " / " + utils.last-slide-number,
    config-info(
      title: metadata.at("title"),
      subtitle: metadata.at("subtitle"),
      author: metadata.at("author-names"),
      date: metadata.at("date"),
      institution: if resolved.at("institution") != [] {
        resolved.at("institution")
      } else {
        metadata.at("affiliations-inline")
      },
      logo: metadata.at("logo"),
      summary: metadata.at("summary"),
    ),
    config-common(datetime-format: datetime-format),
    config-common(new-section-slide-fn: none),
    config-common(handout: resolved.at("handout")),
  )
  body
}

#let setup-slide(config: none) = [#show: slide-theme.with(config: config)]
#let slide-title-slide() = title-slide()
