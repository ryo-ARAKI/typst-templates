#import "../lib/presets/slide.typ": *

#let metadata = (
  title: [Footer slide helpers],
  subtitle: [Section and focus slides],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [],
    ),
  ),
  date: datetime.today(),
  summary: [footer helpers],
  abstract: [],
  venue: [],
  logo: [],
  bibliography: none,
)

#show: slide-theme.with(config: metadata)
#slide-title-slide()

= Motivation

== Context

#slide[
  The default slide theme keeps its footer navigation and metadata.
]

= Main message

#footer-focus-slide[
  Use one slide for one important message.
]

#slide-section-slide[
  Explicit section divider
]
