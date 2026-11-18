#import "tokens.typ": document-defaults, slide-defaults, poster-defaults
#import "metadata.typ": normalize-metadata

#let merge-config(base, overrides: none) = {
  let patch = if overrides == none { (:)} else { overrides }
  base + patch
}

#let document-config(overrides: none) = normalize-metadata(merge-config(document-defaults, overrides: overrides))
#let slide-config(overrides: none) = normalize-metadata(merge-config(slide-defaults, overrides: overrides))
#let poster-config(overrides: none) = normalize-metadata(merge-config(poster-defaults, overrides: overrides))
