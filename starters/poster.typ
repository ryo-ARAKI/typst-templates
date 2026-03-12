#import "../lib/presets/poster.typ": *

#setup-poster()
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

#poster-bottom-box()
