// ===========================================
// Import necessary packages
// ===========================================
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/showybox:2.0.4": showybox // Colorful and customizable boxes
#import "@preview/physica:0.9.4": * // Math constructs for science and engineering
#import "@preview/pinit:0.2.2": * // Annotation
#import "@preview/cetz:0.3.2" // Draw figures
#import "@preview/theorion:0.3.2": * // theorem environment
#import "annotated-equation.typ": pinit-highlight-equation-from // Equation annotation

// ===========================================
// General settings
// ===========================================
// Add animation to CeTZ
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
// tcolorbox equivalent
#let showybox_focus = (
  border-color: white,
  body-color: red.lighten(50%),
)
// textbox
#let textbox(text, color) = box(
  fill: color.lighten(50%),
  outset: (x: 4pt, y: 10pt),
  radius: 5pt,
  text,
)

// ===========================================
// Configuration of theorion (theorem environment)
// ===========================================
#import cosmos.clouds: * // simple, rainbow, clouds, fancy
#show: show-theorion
#let (question-counter, question-box, question, show-question) = make-frame(
  "question",
  "Q.",
  render: render-fn.with(fill: rgb("#fece5a").lighten(70%)),
)
#let (summary-counter, summary-box, summary, show-summary) = make-frame(
  "summary",
  "まとめ",
  render: render-fn.with(fill: rgb("#f93d6e").lighten(70%)),
)
