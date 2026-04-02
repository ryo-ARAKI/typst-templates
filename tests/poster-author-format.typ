#import "../lib/core/metadata.typ": normalize-metadata

#let poster-authors(authors) = normalize-metadata((authors: authors,)).at("poster-authors-inline")

#assert.eq(
  poster-authors((
    (
      name: [荒木亮],
      affiliation: [東京理科大学],
      email: [araki.ryo$at$rs.tus.ac.jp],
    ),
  )),
  [#[荒木亮$at$東京理科大学]（#[araki.ryo$at$rs.tus.ac.jp]）],
)

#assert.eq(
  poster-authors((
    (
      name: [橋本丈瑠],
      affiliation: [東京理科大学],
    ),
  )),
  [橋本丈瑠$at$東京理科大学],
)

#assert.eq(
  poster-authors((
    (
      name: [荒木亮],
      email: [araki.ryo$at$rs.tus.ac.jp],
    ),
  )),
  [#[荒木亮]（#[araki.ryo$at$rs.tus.ac.jp]）],
)
