#let normalize-author-entry(entry) = {
  (
    name: entry.at("name", default: []),
    affiliation: entry.at("affiliation", default: []),
    email: entry.at("email", default: []),
  )
}

#let normalize-authors(authors: ()) = {
  if type(authors) != array or not authors.all(entry => type(entry) == dictionary) {
    panic("metadata.authors must be an array of author dictionaries; replace content or tuple input with authors: ((name: [Alice], affiliation: [Institute], email: \"alice@example.com\"),), or use authors: () for no authors")
  }
  authors.map(normalize-author-entry)
}

#let normalize-metadata(config) = {
  if "author" in config {
    panic("metadata.author is no longer supported; replace author: [Alice] with authors: ((name: [Alice],),); add affiliation and email to the dictionary if needed")
  }
  config + (authors: normalize-authors(authors: config.at("authors", default: ())),)
}
