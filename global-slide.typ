// ===========================================
// Import necessary packages
// ===========================================
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/showybox:2.0.4": showybox // Colorful and customizable boxes
#import "@preview/physica:0.9.4": * // Math constructs for science and engineering
#import "@preview/pinit:0.2.2": * // Annotation
#import "@preview/cetz:0.3.2" // Draw figures
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
