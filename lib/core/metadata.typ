#let normalize-author-entry(entry) = {
  (
    name: entry.at("name", default: []),
    affiliation: entry.at("affiliation", default: []),
    email: entry.at("email", default: []),
  )
}

#let normalize-authors(authors: ()) = {
  if type(authors) != array or not authors.all(entry => type(entry) == dictionary) {
    panic("metadata.authors must be an array of author dictionaries")
  }
  authors.map(normalize-author-entry)
}

#let normalize-metadata(config) = config + (
  authors: normalize-authors(authors: config.at("authors", default: ())),
)
