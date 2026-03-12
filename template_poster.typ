#import "lib/presets/poster.typ": *

#setup-poster()
#poster-title()

#columns(
  2,
  [
    #pop.column-box(heading: [*Section title*])[
      #question[Research question]
      #v(1em)
      #summary[Summary#h(1fr)#text(24pt)[Reference]]
    ]
    #colbreak()
    #pop.column-box(heading: [*Section title*])[
      Dummy text
    ]
  ],
)

#showybox(frame: (border-color: white, body-color: gray.lighten(50%)), [
  *Research Objective*:
])

#v(1fr)
#showybox(frame: (border-color: white, body-color: red.lighten(50%)), [
  #grid(
    columns: (75%, 25%),
    gutter: 20pt,
    [
      *Summary*:\
      *Future Plan*:
    ],
    [
      #cetz.canvas({
        import cetz.draw: *
        content((-10.2, 0), text(28pt)[*References*\ Araki, _Journal_ (2025)\ Araki, in prep.])
      })
    ],
  )
])

#poster-bottom-box()
