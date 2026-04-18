/*
Normalizes custom marker width/alignment while keeping Typst's default
marker behavior when no explicit width is requested.
*/
#let _aligned-marker(marker, marker-width: auto, marker-align: end) = {
  if marker-width == auto {
    marker
  } else if marker-align == start {
    box(width: marker-width)[#marker]
  } else if marker-align == center {
    box(width: marker-width)[#h(1fr)#marker#h(1fr)]
  } else {
    box(width: marker-width)[#h(1fr)#marker]
  }
}

/*
Lays out the aligned "label + description" body with a hanging indent
derived from the measured width of the first column.
*/
#let _aligned-item-body(left, right, col-gap: 0.6em) = context {
  let hanging = measure([#left]).width + col-gap
  par(hanging-indent: hanging)[#left#h(col-gap, weak: true)#right]
}

/*
Bullet list whose outer marker/spacing follows Typst's standard list
behavior while the item body keeps the left column aligned.
*/
#let aligned-items(
  items,
  bullet: [•],
  marker-width: auto,
  marker-gap: 0.5em,
  col-gap: 0.6em,
  row-gap: auto,
  marker-align: end,
) = list(
  marker: _aligned-marker(
    bullet,
    marker-width: marker-width,
    marker-align: marker-align,
  ),
  body-indent: marker-gap,
  spacing: row-gap,
  ..items.map(pair => {
    let (left, right) = pair
    list.item(_aligned-item-body(left, right, col-gap: col-gap))
  }),
)

/*
Numbered list variant of `aligned-items` that keeps Typst's standard enum
behavior unless a custom marker width is explicitly requested.
*/
#let aligned-enum(
  items,
  numbering-pattern: "1.",
  marker-width: auto,
  marker-gap: 0.5em,
  col-gap: 0.6em,
  row-gap: auto,
  marker-align: end,
) = enum(
  numbering: if marker-width == auto {
    numbering-pattern
  } else {
    n => _aligned-marker(
      [#numbering(numbering-pattern, n)],
      marker-width: marker-width,
      marker-align: marker-align,
    )
  },
  body-indent: marker-gap,
  spacing: row-gap,
  number-align: if marker-width == auto { marker-align + top } else { start + top },
  ..items.map(pair => {
    let (left, right) = pair
    enum.item(_aligned-item-body(left, right, col-gap: col-gap))
  }),
)
