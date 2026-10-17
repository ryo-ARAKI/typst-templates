#import "../lib/presets/slide.typ": *

// CLI inputs belong to the manuscript, not to the shared preset.
#let mode = sys.inputs.at("mode", default: "presentation")
#assert(mode in ("presentation", "handout"),
  message: "invalid mode " + repr(mode) + "; use presentation or handout")
#let metadata = (
  title: [One source, three outputs],
  subtitle: [Presentation, handout, and speaker notes],
  authors: ((name: [Ryo Araki], affiliation: [Typst Templates], email: []),),
  date: datetime.today(),
  summary: [Slide outputs],
  handout: mode == "handout",
  equation-numbering: "referenced-only",
  equation-numbering-pattern: "(1)",
)

#show: slide-theme.with(config: metadata)
#slide-title-slide()

== A: Energy relation

#slide[
  The energy relation connects mass and energy.

  $ E = m c^2 $ <energy>

  Forward: @force. Again: @force.

  #speaker-note[N1: Introduce the energy relation.]
  #pause
  Final step: compare the two relations on the next slide.
  #speaker-note[N2: Explain the final step.]
  #handout-only[
    #parbreak()
    Handout supplement: keep both relations together when reviewing.
  ]
]

== B: Force relation

#slide(repeat: 2)[
  The force relation connects mass and acceleration.

  $ F = m a $ <force>

  Backward: @energy. Again: @energy.

  #speaker-note[N3: Compare with the earlier relation.]
]
