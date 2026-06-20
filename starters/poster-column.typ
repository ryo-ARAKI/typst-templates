#import "../lib/presets/poster.typ": *

#let metadata = (
  title: [*Column Poster Starter*],
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
  bibliography: "/starters/biblio.bib",
)

#show: poster-column-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)
#poster-column-title()

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
#poster-column-bottom-box()
