#let _max-width(contents) = {
  contents.map(x => measure(x).width).fold(0pt, (a, b) => if a > b { a } else { b })
}

#let aligned-items(
  items,
  bullet: [•],
  marker-width: 1.0em,
  marker-gap: 0.35em,
  col-gap: 0.8em,
  row-gap: 0.2em,
  marker-align: end,
) = context {
  let max-left = _max-width(items.map(pair => {
    let (left, _) = pair
    [#left]
  }))

  grid(
    columns: (marker-width, max-left, 1fr),
    column-gutter: (marker-gap, col-gap),
    row-gutter: row-gap,
    align: (marker-align, start, start),
    ..items
      .map(pair => {
        let (left, right) = pair
        (
          [#bullet],
          [#left],
          [#right],
        )
      })
      .flatten(),
  )
}

#let aligned-enum(
  items,
  numbering-pattern: "1.",
  marker-width: 1.6em,
  marker-gap: 0.35em,
  col-gap: 0.8em,
  row-gap: 0.2em,
  marker-align: end,
) = context {
  let max-left = _max-width(items.map(pair => {
    let (left, _) = pair
    [#left]
  }))

  grid(
    columns: (marker-width, max-left, 1fr),
    column-gutter: (marker-gap, col-gap),
    row-gutter: row-gap,
    align: (marker-align, start, start),
    ..items
      .enumerate()
      .map(((i, pair)) => {
        let (left, right) = pair
        (
          [#numbering(numbering-pattern, i + 1)],
          [#left],
          [#right],
        )
      })
      .flatten(),
  )
}
