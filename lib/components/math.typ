#import "@preview/pinit:0.2.2": *
#import "../core/locale.typ": jp-spacing

#let colormath(math, color) = text(fill: color, math)

#let apply-math-font(font: "Latin Modern Math") = {
  show math.equation: set text(font: font)
}

#let apply-block-equation-spacing(spacing: 0.7em) = {
  show math.equation.where(block: true): set block(spacing: spacing)
}

#let apply-inline-japanese-math-spacing() = {
  show math.equation.where(block: false): it => jp-spacing(it)
}

#let pinit-highlight-equation-from(
  height: 0pt,
  arrow-length: 20pt,
  dx: 0pt,
  dy: 0pt,
  line-offset-y: -1.5pt,
  pos: "bottom",
  fill: rgb(0, 0, 0),
  stroke: auto,
  inset: 0.25em,
  pin1,
  pin2,
  body,
) = {
  pinit-highlight(pin1, pin2, dx: dx, dy: -dy - 18pt, extended-height: height, fill: rgb(
    ..fill.components().slice(0, -1),
    100,
  ))

  let stroke-color = if stroke == auto { fill } else { stroke }
  let out-contents = box(
    stroke: (bottom: stroke-color + 0.12em),
    inset: (x: inset, y: 5pt),
    text(fill: fill)[#body],
  )

  let pos-configs = (
    "bottom": (
      pin: pin1,
      text-dy: 0.85em,
      place-dx: dx + 20pt,
      place-dy: text-dy => height - dy + arrow-length - 9pt - text-dy - line-offset-y,
      arrow-pin: pin1,
      arrow-start-dx: dx + 20pt,
      arrow-end-dx: dx + 20pt,
      arrow-start-dy: height + arrow-length - dy,
      arrow-end-dy: height - dy - 20pt,
    ),
    "top": (
      pin: pin1,
      text-dy: 0.70em,
      place-dx: dx + 20pt,
      place-dy: text-dy => -dy - 10pt - arrow-length - 15pt - text-dy - line-offset-y,
      arrow-pin: pin1,
      arrow-start-dx: dx + 20pt,
      arrow-end-dx: dx + 20pt,
      arrow-start-dy: -dy + 10pt - arrow-length - 24.8pt,
      arrow-end-dy: 34pt - dy - 50pt,
    ),
    "right": (
      pin: pin2,
      text-dy: 0.76em,
      place-dx: arrow-length + dx,
      place-dy: text-dy => -dy - 25.9pt + height / 2 - text-dy - line-offset-y,
      arrow-pin: pin2,
      arrow-start-dx: arrow-length + dx,
      arrow-end-dx: 0pt,
      arrow-start-dy: -dy - 16pt + height / 2,
      arrow-end-dy: -dy - 16pt + height / 2,
    ),
    "left": (
      pin: pin1,
      text-dy: 0.76em,
      place-dx: -arrow-length + dx,
      place-dy: text-dy => -dy - 25.9pt + height / 2 - text-dy - line-offset-y,
      arrow-pin: pin1,
      arrow-start-dx: -arrow-length + dx,
      arrow-end-dx: 0pt,
      arrow-start-dy: -dy - 16pt + height / 2,
      arrow-end-dy: -dy - 16pt + height / 2,
    ),
  )

  let config = pos-configs.at(pos)
  pinit-place(config.pin, out-contents, dx: config.place-dx, dy: (config.place-dy)(config.text-dy))
  pinit-arrow(
    config.arrow-pin,
    config.arrow-pin,
    fill: fill,
    start-dx: config.arrow-start-dx,
    end-dx: config.arrow-end-dx,
    start-dy: config.arrow-start-dy,
    end-dy: config.arrow-end-dy,
  )
}
