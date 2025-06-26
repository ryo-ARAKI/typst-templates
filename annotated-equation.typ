// ===========================================
// Equation annotation with pinit
// https://github.com/OrangeX4/typst-pinit/blob/main/examples/equation-desc.typ
// add `pos: right` and `pos: left`
// ===========================================
#import "@preview/pinit:0.2.2": *

#let pinit-highlight-equation-from(
  height: 0pt, // highlight height (ハイライトの高さ)
  arrow-length: 20pt, // arrow length (矢印の長さ)
  dx: 0pt, // x-offset for the entire annotation (矢印全体のx座標)
  dy: 0pt, // y-offset for the entire annotation (全体のy座標)
  line-offset-y: -1.5pt, // vertical offset for the line and arrow (矢印と枠線の位置調整)
  pos: "bottom", // position of the arrow (bottom, top, right, left) (矢印の位置)
  fill: rgb(0, 0, 0), // color of the arrow (矢印の色)
  stroke: auto, // color of the line under the text, defaults to `fill`
  inset: 0.25em, // inset for the text box (テキストのinset)
  pin1, // start pin for the highlight (highlightの始点)
  pin2, // end pin for the highlight (highlightの終点)
  body, // text content (テキスト)
) = {
  // Highlight the equation part
  pinit-highlight(pin1, pin2, dy: -dy - 18pt, extended-height: height, fill: rgb(
    ..fill.components().slice(0, -1),
    100,
  ))

  // Create the annotation text box
  let stroke-color = if stroke == auto { fill } else { stroke }
  let out-contents = box(stroke: (bottom: stroke-color + 0.12em), inset: (x: inset, y: 5pt), text(fill: fill)[#body])

  // Configurations for each arrow position
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
      arrow-end-dy: +34pt - dy - 50pt,
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

  // Place the annotation text
  pinit-place(config.pin, out-contents, dx: config.place-dx, dy: (config.place-dy)(config.text-dy))

  // Draw the arrow
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
