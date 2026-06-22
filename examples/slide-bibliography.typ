#import "../lib/presets/slide.typ": *

#let metadata = (
  title: [Slide Bibliography],
  subtitle: [Multiple bibliography demo],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [],
    ),
  ),
  date: datetime.today(),
  summary: [#("bibliography")#sym.at#("slide")],
  abstract: [],
  venue: [],
  logo: [],
  // Slides do not enable bibliography output by default. Set the BibTeX path
  // here and call Typst's standard bibliography function on reference slides.
  bibliography: "/examples/biblio.bib",
)

#show: slide-theme.with(config: metadata)
#slide-title-slide()

== Physical Viewpoint

#slide[
  Slides can cite work with Typst's standard reference syntax and place a
  bibliography near the relevant section.

  The turbulent cascade has a long physical lineage, from classical
  turbulence phenomenology @Frisch1995_turbulence to coherent vortex
  hierarchy studies @Goto2017_hierarchy.
]

== Physical References

#slide[
  #bibliography(metadata.at("bibliography"), title: none)
]

== Information Viewpoint

#slide[
  A separate section can cite a different subset of sources before its own
  bibliography.

  Information-thermodynamic analyses of turbulent energy transfer build on
  recent cascade studies @Tanogami2024_information and related thesis work
  @Araki2023_temporal.
]

== Information References

#slide[
  #bibliography(metadata.at("bibliography"), title: none)
]
