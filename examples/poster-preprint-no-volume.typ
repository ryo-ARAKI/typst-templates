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
  bibliography: "/examples/biblio-preprint-no-volume.bib",
)

#show: poster-theme.with(config: metadata)
#setup-poster(config: metadata)
#show ref: poster-citation-ref.with(config: metadata)
#poster-title()

#columns(
  1,
  [
    #pop.column-box(heading: [*Regression*])[
      プレプリント引用: @Nakano2025_looking
    ]
  ],
)

#v(1fr)
#poster-bottom-box()
