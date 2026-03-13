#import "../lib/presets/poster.typ": *

#let metadata = (
  title: [*Poster Catalog*],
  subtitle: [],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [],
    ),
  ),
  date: [],
  summary: [],
  abstract: [],
  venue: [Template Showcase$at$Local Workspace, March 12, 2026],
  logo: [],
  bibliography: none,
)

#show: poster-theme.with(config: metadata)
#poster-title()

#columns(
  2,
  [
    #pop.column-box(heading: [*Section title*])[
      #question[Research question]
      #summary[Short summary]
    ]
    #colbreak()
    #pop.column-box(heading: [*Section title*])[
      Dummy text
    ]
  ],
)

#v(1fr)
#poster-bottom-box()
