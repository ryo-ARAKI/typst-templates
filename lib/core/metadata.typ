#let empty-author = (
  name: [],
  affiliation: [],
  email: [],
)

#let normalize-author-entry(entry) = {
  if type(entry) == dictionary {
    (
      name: entry.at("name", default: []),
      affiliation: entry.at("affiliation", default: []),
      email: entry.at("email", default: []),
    )
  } else {
    (empty-author + (name: entry,))
  }
}

#let normalize-authors(authors: none, author: none) = {
  if authors != none {
    if type(authors) == array and authors.len() > 0 and type(authors.at(0)) == dictionary {
      authors.map(normalize-author-entry)
    } else if type(authors) == array and authors.len() == 3 and type(authors.at(0)) != dictionary {
      ((name: authors.at(0), affiliation: authors.at(1), email: authors.at(2)),)
    } else if type(authors) == content {
      ((name: authors,),)
    } else {
      (normalize-author-entry(authors),)
    }
  } else if author != none {
    ((name: author,),)
  } else {
    ()
  }
}

#let render-author-inline(entry) = {
  let parts = ()
  if entry.at("name", default: []) != [] { parts.push(entry.at("name", default: [])) }
  if entry.at("affiliation", default: []) != [] { parts.push(entry.at("affiliation", default: [])) }
  if entry.at("email", default: []) != [] { parts.push(entry.at("email", default: [])) }
  if parts.len() == 0 {
    []
  } else {
    parts.join($at$)
  }
}

#let render-author-poster-inline(entry) = {
  let poster-author-size = 44pt
  let poster-email-size = 34pt
  let base-parts = ()
  let name = entry.at("name", default: [])
  let affiliation = entry.at("affiliation", default: [])
  let email = entry.at("email", default: [])
  if name != [] { base-parts.push(name) }
  if affiliation != [] { base-parts.push(affiliation) }
  let base = if base-parts.len() == 0 {
    []
  } else {
    text(size: poster-author-size)[#base-parts.join($at$)]
  }
  if email == [] {
    base
  } else if base == [] {
    text(size: poster-email-size)[#email]
  } else {
    [#base #text(size: poster-email-size)[#email]]
  }
}

#let render-author-names(authors) = {
  let rendered = authors
    .map(author => author.at("name", default: []))
    .filter(part => part != [])
  if rendered.len() == 0 {
    []
  } else {
    rendered.join(linebreak())
  }
}

#let render-authors-inline(authors) = {
  let rendered = authors.map(render-author-inline).filter(part => part != [])
  if rendered.len() == 0 {
    []
  } else {
    rendered.join(linebreak())
  }
}

#let render-poster-authors-inline(authors) = {
  let rendered = authors.map(render-author-poster-inline).filter(part => part != [])
  if rendered.len() == 0 {
    []
  } else {
    rendered.join(" / ")
  }
}

#let render-author-affiliations(authors) = {
  let rendered = authors
    .map(author => author.at("affiliation", default: []))
    .filter(part => part != [])
  if rendered.len() == 0 {
    []
  } else {
    rendered.join(linebreak())
  }
}

#let render-author-emails(authors) = {
  let rendered = authors
    .map(author => author.at("email", default: []))
    .filter(part => part != [] and part != "")
  if rendered.len() == 0 {
    []
  } else {
    rendered.join(linebreak())
  }
}

#let authors-for-js(authors) = {
  let mapped = authors.map(author => (
    author.at("name", default: []),
    author.at("affiliation", default: []),
    author.at("email", default: []),
  ))
  if mapped.len() == 1 {
    mapped.at(0)
  } else {
    mapped
  }
}

#let normalize-metadata(config) = {
  let authors = normalize-authors(
    authors: config.at("authors", default: none),
    author: config.at("author", default: none),
  )

  (
    title: config.at("title", default: []),
    subtitle: config.at("subtitle", default: []),
    authors: authors,
    author-names: render-author-names(authors),
    authors-inline: render-authors-inline(authors),
    poster-authors-inline: render-poster-authors-inline(authors),
    affiliations-inline: render-author-affiliations(authors),
    author-emails-inline: render-author-emails(authors),
    authors-js: authors-for-js(authors),
    date: config.at("date", default: auto),
    summary: config.at("summary", default: []),
    abstract: config.at("abstract", default: []),
    venue: config.at("venue", default: []),
    logo: config.at("logo", default: []),
    logo-relative-width: config.at("logo-relative-width", default: none),
    bibliography: config.at("bibliography", default: none),
  )
}
