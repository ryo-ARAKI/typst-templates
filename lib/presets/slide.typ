#import "@preview/cjk-spacer:0.2.0": cjk-spacer
#import "../core/config.typ": slide-config
#import "../core/tokens.typ": slide-palette
#import "../core/locale.typ": apply-japanese-text
#import "../components/aligned-list.typ": aligned-items, aligned-enum
#import "../components/math.typ": apply-math-font, apply-inline-japanese-math-spacing, apply-block-equation-spacing, apply-referenced-only-equation-numbering
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

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  let header(self) = {
    set std.align(top)
    grid(
      rows: (auto, auto),
      row-gutter: 3mm,
      if self.store.progress-bar {
        components.progress-bar(
          height: 2pt,
          self.colors.primary,
          self.colors.tertiary,
        )
      },
      block(
        inset: (x: .5em),
        components.left-and-right(
          text(
            fill: self.colors.primary,
            weight: "bold",
            size: 1.2em,
            utils.call-or-display(self, self.store.header),
          ),
          text(fill: self.colors.primary.lighten(65%), utils.call-or-display(
            self,
            self.store.header-right,
          )),
        ),
      ),
    )
  }
  let footer(self) = {
    set std.align(center + bottom)
    set text(size: .4em)
    {
      let cell(..args, it) = components.cell(
        ..args,
        inset: 1mm,
        std.align(horizon, text(fill: white, it)),
      )
      show: block.with(width: 100%, height: auto)
      grid(
        columns: self.store.footer-columns,
        rows: 1.5em,
        cell(fill: self.colors.primary, utils.call-or-display(
          self,
          self.store.footer-a,
        )),
        cell(fill: self.colors.secondary, utils.call-or-display(
          self,
          self.store.footer-b,
        )),
        cell(fill: self.colors.tertiary, utils.call-or-display(
          self,
          self.store.footer-c,
        )),
      )
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  let slide-bodies = if self.at("equation-numbering", default: none) == "referenced-only" {
    bodies.pos().map(body => {
      show: apply-referenced-only-equation-numbering(
        numbering: self.at("equation-numbering-pattern", default: "(1)"),
      )
      body
    })
  } else {
    bodies.pos()
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..slide-bodies,
  )
})

#let slide-section-slide(
  config: (:),
  level: 1,
  numbered: false,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config)
  let body = args.pos().at(0, default: none)
  let title = if body == none or body == [] {
    utils.display-current-heading(level: level, numbered: numbered)
  } else {
    body
  }
  touying-slide(
    self: self,
    std.align(center + horizon)[
      #set text(size: 1.8em, fill: self.colors.primary, weight: "bold")
      #title
    ],
  )
})

#let footer-focus-slide(
  body,
  config: (:),
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config)
  touying-slide(
    self: self,
    std.align(center + horizon)[
      #set text(size: 1.7em, fill: self.colors.primary, weight: "bold")
      #body
    ],
  )
})

#let slide-theme(body, config: none) = {
  let resolved = slide-config(overrides: config)
  let metadata = resolved.at("metadata")
  let datetime-format = resolve-slide-datetime-format(resolved)
  show: cjk-spacer
  set text(font: resolved.at("text-font"))
  show raw: set text(font: resolved.at("code-font"))
  show raw.where(block: true): set block(
    fill: rgb("#f6f7f9"),
    stroke: rgb("#d9dde3"),
    inset: 0.65em,
    radius: 4pt,
    width: 100%,
  )
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
      logo-position: metadata.at("logo-position"),
      summary: metadata.at("summary"),
    ),
    config-common(
      datetime-format: datetime-format,
      equation-numbering: resolved.at("equation-numbering"),
      equation-numbering-pattern: resolved.at("equation-numbering-pattern"),
    ),
    config-common(new-section-slide-fn: slide-section-slide.with(numbered: false)),
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
      let logo-alignment = if info.logo-position == "right-top" {
        right + top
      } else if info.logo-position == "right-bottom" {
        right + bottom
      } else {
        panic("unsupported slide logo-position: " + repr(info.logo-position))
      }
      place(logo-alignment, text(fill: self.colors.primary, info.logo))
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

