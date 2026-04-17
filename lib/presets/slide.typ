#import "@preview/cjk-spacer:0.2.0": cjk-spacer
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
  show: cjk-spacer
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
      authors: metadata.at("slide-title-authors"),
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
#let slide-title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config,
  )
  let info = self.info + args.named()
  let has-custom-title-authors = "authors" in info
  let title-authors = {
    let authors = if has-custom-title-authors {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let has-institution = info.institution != none and info.institution != [] and info.institution != ""
  let body = {
    if info.logo != none {
      place(right, text(fill: self.colors.primary, info.logo))
    }
    std.align(
      center + horizon,
      {
        block(
          inset: 0em,
          breakable: false,
          {
            text(size: 2em, fill: self.colors.primary, strong(info.title))
            if info.subtitle != none {
              parbreak()
              text(size: 1.2em, fill: self.colors.primary, info.subtitle)
            }
          },
        )
        set text(size: .8em)
        if has-custom-title-authors {
          stack(
            dir: ttb,
            spacing: .6em,
            ..title-authors.map(author => text(
              fill: self.colors.neutral-darkest,
              author,
            )),
          )
        } else {
          stack(
            dir: ttb,
            spacing: 1em,
            ..title-authors
              .chunks(3)
              .map(author-chunk => {
                grid(
                  columns: (1fr,) * author-chunk.len(),
                  column-gutter: 1em,
                  ..author-chunk.map(author => text(
                    fill: self.colors.neutral-darkest,
                    author,
                  ))
                )
              }),
          )
        }
        v(1em)
        if not has-custom-title-authors and has-institution {
          parbreak()
          text(size: .9em, info.institution)
        }
        if info.date != none {
          parbreak()
          text(size: .8em, utils.display-info-date(self))
        }
      },
    )
  }
  touying-slide(self: self, body)
})
