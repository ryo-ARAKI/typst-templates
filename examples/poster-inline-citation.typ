#import "../lib/presets/poster.typ": *

#let metadata = (
  title: [*Poster Inline Citation Test*],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [],
    ),
  ),
  venue: [Local check],
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
    #pop.column-box(heading: [*Citation*])[
      @Tanogami2024_information
    ]
  ],
)

#v(1fr)
#poster-bottom-box()
