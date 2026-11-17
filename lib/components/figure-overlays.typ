#import "@preview/cetz:0.5.2": draw

// Overlay a label and optional erasing rectangles relative to a named image.
// Offsets, rectangle corners and padding use the current CeTZ canvas units.
#let cetz-axis-label(
  image-name,
  offset,
  body,
  anchor: "north-west",
  angle: 0deg,
  erase: (),
  size: 1em,
  font: auto,
  text-fill: black,
  background: white,
  padding: 0.08,
) = {
  let origin = image-name + "." + anchor
  let relative(position) = (rel: position, to: origin)
  for (a, b) in erase {
    draw.rect(relative(a), relative(b), fill: background, stroke: none)
  }
  let font-args = if font == auto { (:) } else { (font: font) }
  draw.content(
    relative(offset),
    text(size: size, fill: text-fill, ..font-args, body),
    angle: angle,
    frame: "rect",
    fill: background,
    stroke: none,
    padding: padding,
  )
}
