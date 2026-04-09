#import "../lib/presets/poster.typ": *

#let metadata = (
  title: [*Poster Citation Regression*],
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
  venue: [Template Showcase$at$Local Workspace, 2026-04-09],
  logo: [],
  bibliography: "/examples/biblio.bib",
)

#show: poster-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)
#poster-title()

#columns(
  1,
  [
    #pop.column-box(heading: [*Regression*])[
      教科書: @Frisch1995_turbulence

      学位論文: @Araki2023_temporal

      misc: @田崎2023_非平衡統計力学入門
    ]
  ],
)

#v(1fr)
#poster-bottom-box()
