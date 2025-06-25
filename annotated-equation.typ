// ===========================================
// Equation annotation with pinit
// https://github.com/OrangeX4/typst-pinit/blob/main/examples/equation-desc.typ
// add `pos: right`
// ===========================================
#import "@preview/pinit:0.2.2": *

#let pinit-highlight-equation-from(
  height: 0pt, //highlightの高さ
  arrow-length: 20pt, //矢印の長さ
  dx: 0pt, //矢印全体のx座標
  dy: 0pt, //全体のy座標
  dy-line: -1.5pt, // 矢印と枠線の位置調整
  pos: bottom, //矢印の位置（bottom, top, right）
  fill: rgb(0, 0, 0), //矢印の色
  inset: 0.25em, //テキストのinset
  pin1, //highlightの始点
  pin2, //highlightの終点
  body, //テキスト
) = {
  pinit-highlight(pin1, pin2, dy: -dy - 18pt, extended-height: height, fill: rgb(
    ..fill.components().slice(0, -1),
    100,
  )) // 153=255*6/10

  let out-contents = box(stroke: (bottom: fill + 0.12em), inset: (x: inset, y: 5pt), text(fill: fill)[#body])

  if pos == bottom {
    let text-dy = 0.85em
    pinit-place(pin1, out-contents, dx: dx + 20pt, dy: height - dy + arrow-length - 9pt - text-dy - dy-line)
    pinit-arrow(
      pin1,
      pin1,
      fill: fill,
      start-dy: height + arrow-length - dy,
      end-dy: height - dy - 20pt,
      start-dx: dx + 20pt,
      end-dx: dx + 20pt,
    )
  } else if pos == top {
    let text-dy = 0.70em
    pinit-place(pin1, out-contents, dx: dx + 20pt, dy: -dy - 10pt - arrow-length - 15pt - text-dy - dy-line)
    pinit-arrow(
      pin1,
      pin1,
      fill: fill,
      start-dy: -dy + 10pt - arrow-length - 24.8pt,
      end-dy: +34pt - dy - 50pt,
      start-dx: dx + 20pt,
      end-dx: dx + 20pt,
    )
  } else if pos == right {
    let text-dy = 0.76em
    pinit-place(pin2, out-contents, dx: arrow-length + dx, dy: -dy - 25.9pt + height / 2 - text-dy - dy-line)
    pinit-arrow(
      pin2,
      pin2,
      fill: fill,
      start-dx: arrow-length + dx,
      end-dx: 0pt,
      start-dy: -dy - 16pt + height / 2,
      end-dy: -dy - 16pt + height / 2,
    )
  } else if pos == left {
    let text-dy = 0.76em
    pinit-place(pin1, out-contents, dx: -arrow-length + dx, dy: -dy - 25.9pt + height / 2 - text-dy - dy-line)
    pinit-arrow(
      pin1,
      pin1,
      fill: fill,
      start-dx: -arrow-length + dx,
      end-dx: 0pt,
      start-dy: -dy - 16pt + height / 2,
      end-dy: -dy - 16pt + height / 2,
    )
  }
}
