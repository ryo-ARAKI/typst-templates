#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp_dir="${TMPDIR:-/tmp}/poster-portrait-takeaway-api-check"

mkdir -p "$tmp_dir"

compile_repo_doc() {
  local input="$1"
  local output="$2"
  typst compile --root "$repo_root" "$input" "$output"
}

compile_tmp_case() {
  local input="$1"
  local output="$2"
  typst compile --root / "$input" "$output"
}

write_case() {
  local path="$1"
  local body="$2"
  printf '%s\n' "$body" > "$path"
}

expect_fail() {
  local name="$1"
  local input="$2"
  local expected="$3"
  local output="$tmp_dir/$name.pdf"
  local stderr="$tmp_dir/$name.err"

  if compile_tmp_case "$input" "$output" 2> "$stderr"; then
    printf 'expected %s to fail, but it compiled\n' "$name" >&2
    printf '%s stderr:\n' "$name" >&2
    cat "$stderr" >&2
    exit 1
  fi

  # Match the actual diagnostic, not source excerpts or stack frames.
  if ! rg '^error:' "$stderr" | rg -- "$expected" > /dev/null; then
    printf 'expected %s error diagnostic to match: %s\n' "$name" "$expected" >&2
    printf '%s stderr:\n' "$name" >&2
    cat "$stderr" >&2
    exit 1
  fi
}

common_prefix=$(printf "%s\n" \
  "#import \"$repo_root/lib/presets/poster.typ\": *" \
  "" \
  "#let metadata = (" \
  "  text-font: \"Noto Sans CJK JP\"," \
  "  cjk-font: \"Noto Sans CJK JP\"," \
  "  title: [*API Check*]," \
  "  authors: ((name: [Ryo Araki], affiliation: [Typst Templates], email: []),)," \
  "  venue: [API Check]," \
  "  acknowledgements: []," \
  "  bibliography: none," \
  ")" \
  "" \
  "#show: poster-portrait-takeaway-theme.with(config: metadata)" \
)
valid_args='
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      title: [Upper],
      figure: [Upper figure],
      note: [Upper note],
      figure-side: left,
    ),
    (
      title: [Lower],
      figure: [Lower figure],
      note: [Lower note],
      figure-side: right,
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
'

write_case "$tmp_dir/valid-theme.typ" "$common_prefix
#poster-portrait-takeaway(
  theme: \"wine\",
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      title: [Upper],
      figure: [Upper figure],
      note: [Upper note],
      figure-side: left,
    ),
    (
      title: [Lower],
      figure: [Lower figure],
      note: [Lower note],
      figure-side: right,
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/valid-palette.typ" "$common_prefix
#poster-portrait-takeaway(
  palette: (structure: red),
  title-style: (
    height: 7%,
    title-size: 84pt,
    author-size: 44pt,
    author-email-size: 34pt,
    author-offset: -1.7cm,
    logo-gutter: 1cm,
  ),
  footer-style: (
    height: 2%,
    text-size: 30pt,
    gutter: 0.8cm,
  ),
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  note-style: (
    text-size: 34pt,
    leading: 0.72em,
    list-spacing: 0.60em,
  ),
  sections: (
    (
      title: [First],
      figure: [First figure],
      note: [
        #context { assert.eq(text.size, 42pt); assert.eq(par.leading, 0.72em); assert.eq(list.spacing, 0.70em) }
        - First list item wraps safely across lines.
        - First list item uses section-level note spacing.
      ],
      note-style: (text-size: 42pt, list-spacing: 0.70em,),
      figure-width: 1fr,
      note-width: 1fr,
    ),
    (
      title: [Second],
      figure: [Second figure],
      note: [
        #context { assert.eq(text.size, 34pt); assert.eq(par.leading, 0.72em); assert.eq(list.spacing, 0.60em) }
        - Second list item wraps safely across lines.
        - Second list item uses top-level note spacing.
      ],
      figure-width: 1.2fr,
      note-width: 0.8fr,
    ),
    (
      title: [Third],
      figure: [Third figure],
      note: [
        - Third list item wraps safely across lines.
        - Third list item uses top-level note spacing.
      ],
    ),
  ),
  figure-heights: (1fr, 1.2fr, 0.8fr),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-theme-palette.typ" "$common_prefix
#poster-portrait-takeaway(
  theme: \"wine\",
  palette: (structure: red),
  $valid_args
)
"

write_case "$tmp_dir/invalid-one-section.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      figure: [Only figure],
      note: [Only note],
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-figure-heights-length.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      figure: [Upper figure],
      note: [Upper note],
    ),
    (
      figure: [Lower figure],
      note: [Lower note],
    ),
  ),
  figure-heights: (1fr, 1fr, 1fr),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-missing-figure.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      note: [Upper note],
    ),
    (
      figure: [Lower figure],
      note: [Lower note],
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-figure-side.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      figure: [Upper figure],
      note: [Upper note],
      figure-side: top,
    ),
    (
      figure: [Lower figure],
      note: [Lower note],
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-title-style-key.typ" "$common_prefix
#poster-portrait-takeaway(
  title-style: (padding: 1cm),
  $valid_args
)
"

write_case "$tmp_dir/invalid-section-note-style-key.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      figure: [Upper figure],
      note: [Upper note],
      note-style: (padding: 1cm),
    ),
    (
      figure: [Lower figure],
      note: [Lower note],
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

# Exercise the required note contract through the public layout.
for value in missing auto none empty; do
  case "$value" in
    missing) note_arg='' ;;
    auto) note_arg='note: auto,' ;;
    none) note_arg='note: none,' ;;
    empty) note_arg='note: [],' ;;
  esac
  write_case "$tmp_dir/invalid-note-$value.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline], headline-detail: [Detail],
  sections: ((figure: [Figure], $note_arg), (figure: [Figure], note: [Note])),
  conclusion-takeaway: [Conclusion], conclusion-detail: [Detail],
)
"
done
write_case "$tmp_dir/invalid-note-style-key.typ" "$common_prefix
#poster-portrait-takeaway(note-style: (padding: 1cm), $valid_args)
"
# Minimal rendered content also distinguishes the figure heading from note text.
write_case "$tmp_dir/note-content.typ" "
#import \"$repo_root/lib/presets/poster.typ\": *
#set page(width: 30cm, height: 12cm, margin: 1cm)
#poster-portrait-figure-row((title: [FigureHeading], figure: [FigureBody], note: [NoteBody]), poster-portrait-takeaway-palette())
"

# One citation fixture combines equivalent formatting, multiline values and nesting.
cat > "$tmp_dir/citation-formats.bib" <<'BIB'
% Leading comments must not become entries: @article{ignored, year={2000}}
@article{lines,
  author = {Jane Smith and John Doe},
  % Field comments do not end the entry: }
  title = {A {Nested {Title}}, with punctuation},
  journal = {Journal of Fluid Mechanics},
  volume = {42},
  year = {2024}
}
@article{compact, author={Jane Smith and John Doe}, title={A {Nested {Title}}, with punctuation}, journal={Journal of Fluid Mechanics}, volume={42}, year={2024}}
@article{multiline,
  author = {Jane Smith
    and John Doe},
  title = {A {Nested
    {Title}}, with punctuation},
  journal = "Journal of
    Fluid Mechanics",
  volume = 42, year = {2024}}
@article{no-volume, author={Jane Smith}, title={Test}, journal={Journal of Fluid Mechanics}, year={2024}}
BIB

write_case "$tmp_dir/valid-bibliography-comments.typ" "
#import \"$repo_root/lib/presets/poster.typ\": *
#let existing = \"$repo_root/examples/biblio.bib\"
#let formats = \"$tmp_dir/citation-formats.bib\"
#assert(poster-has-citation-entry(\"Tanogami2024_information\", existing))
#assert(not poster-has-citation-entry(\"ignored\", formats))
#let expected = (
  kind: \"article\", author: \"Jane Smith and John Doe\",
  title: \"A {Nested {Title}}, with punctuation\",
  journal: \"Journal of Fluid Mechanics\", volume: \"42\", year: \"2024\",
)
#for key in (\"lines\", \"compact\", \"multiline\") {
  assert(poster-has-citation-entry(key, formats))
  assert.eq(poster-citation-entry(key, formats), expected)
}
#let config = (bibliography: formats,)
#show ref: poster-citation-ref.with(config: config)
#set heading(numbering: \"1\")
= Citation formats <ordinary-label>
#assert(not poster-has-citation-entry(\"ordinary-label\", formats))
@ordinary-label

@lines / #poster-cite(\"lines\", config: config)

@compact / #poster-cite(\"compact\", config: config)

@multiline / #poster-cite(\"multiline\", config: config)

@no-volume

#poster-cite(\"Frisch1995_turbulence\", config: (bibliography: existing,))

#poster-cite(\"Araki2023_temporal\", config: (bibliography: existing,))

// Native bibliography validates the same input independently of short citations.
#bibliography(formats, full: true)
"

compile_repo_doc "examples/poster-portrait-takeaway.typ" "$tmp_dir/example.pdf"
compile_repo_doc "starters/poster-portrait-takeaway.typ" "$tmp_dir/starter.pdf"
compile_tmp_case "$tmp_dir/valid-bibliography-comments.typ" "$tmp_dir/valid-bibliography-comments.pdf"
compile_tmp_case "$tmp_dir/valid-theme.typ" "$tmp_dir/valid-theme.pdf"
compile_tmp_case "$tmp_dir/valid-palette.typ" "$tmp_dir/valid-palette.pdf"

expect_fail "invalid-theme-palette" "$tmp_dir/invalid-theme-palette.typ" "specify either theme or palette"
expect_fail "invalid-one-section" "$tmp_dir/invalid-one-section.typ" "sections must contain at least two items"
expect_fail "invalid-figure-heights-length" "$tmp_dir/invalid-figure-heights-length.typ" "figure-heights length must match sections length"
expect_fail "invalid-missing-figure" "$tmp_dir/invalid-missing-figure.typ" "sections.*figure is required"
expect_fail "invalid-figure-side" "$tmp_dir/invalid-figure-side.typ" 'figure-side must be `left` or `right`'
expect_fail "invalid-title-style-key" "$tmp_dir/invalid-title-style-key.typ" "unknown title-style key"
expect_fail "invalid-section-note-style-key" "$tmp_dir/invalid-section-note-style-key.typ" "unknown sections.*note-style key"

for value in missing auto none empty; do
  expect_fail "invalid-note-$value" "$tmp_dir/invalid-note-$value.typ" 'sections.at\(0\).note is required'
done
expect_fail "invalid-note-style-key" "$tmp_dir/invalid-note-style-key.typ" 'unknown note-style key'
compile_tmp_case "$tmp_dir/note-content.typ" "$tmp_dir/note-content.pdf"
pdftotext -layout "$tmp_dir/note-content.pdf" "$tmp_dir/note-content.txt"
for word in FigureHeading FigureBody NoteBody; do
  [[ $(grep -o "$word" "$tmp_dir/note-content.txt" | wc -l) -eq 1 ]]
done
if rg -q 'Guide' "$tmp_dir/note-content.txt"; then
  printf 'unexpected generated note heading\n' >&2
  exit 1
fi
