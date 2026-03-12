#import "tokens.typ": document-defaults, slide-defaults, poster-defaults

#let merge-config(base, overrides: none) = {
  let patch = if overrides == none { (:)} else { overrides }
  base + patch
}

#let document-config(overrides: none) = merge-config(document-defaults, overrides: overrides)
#let slide-config(overrides: none) = merge-config(slide-defaults, overrides: overrides)
#let poster-config(overrides: none) = merge-config(poster-defaults, overrides: overrides)
