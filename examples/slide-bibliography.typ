#import "../lib/presets/slide.typ": *

#let metadata = (
  title: [Slide Bibliography],
  subtitle: [Minimal citation and reference slide],
  authors: (
    (
      name: [Ryo Araki],
      affiliation: [Typst Templates],
      email: [],
    ),
  ),
  date: datetime.today(),
  summary: [bibliography$at$slide],
  abstract: [],
  venue: [],
  logo: [],
  // Slides do not enable bibliography output by default. Set the BibTeX path
  // here and call Typst's standard bibliography function on a reference slide.
  bibliography: "/examples/biblio.bib",
)

#show: slide-theme.with(config: metadata)
#slide-title-slide()

== Cited Claim

#slide[
  Slides can cite work with Typst's standard reference syntax.

  The turbulent cascade has been studied from both physical
  and information-thermodynamic viewpoints @Frisch1995_turbulence
  @Tanogami2024_information.
]

== References

#slide[
  #bibliography(metadata.at("bibliography"), title: none)
]
