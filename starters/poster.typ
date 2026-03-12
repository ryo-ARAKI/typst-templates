#import "lib/presets/poster.typ": *

#show: poster-theme
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
