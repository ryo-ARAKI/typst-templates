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
    exit 1
  fi

  if ! rg -n -F "$expected" "$stderr" > /dev/null; then
    printf 'expected %s stderr to contain: %s\n' "$name" "$expected" >&2
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
      caption: [Upper caption],
      figure-side: left,
    ),
    (
      title: [Lower],
      figure: [Lower figure],
      caption: [Lower caption],
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
      caption: [Upper caption],
      figure-side: left,
    ),
    (
      title: [Lower],
      figure: [Lower figure],
      caption: [Lower caption],
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
  sections: (
    (
      title: [Upper],
      figure: [Upper figure],
      caption: [Upper caption],
      figure-side: left,
      figure-width: 1fr,
      caption-width: 1fr,
    ),
    (
      title: [Lower],
      figure: [Lower figure],
      caption: [Lower caption],
      figure-side: right,
      figure-width: 1.2fr,
      caption-width: 0.8fr,
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/valid-three-sections.typ" "$common_prefix
#poster-portrait-takeaway(
  theme: \"brewer-dark2-magenta\",
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      title: [First],
      figure: [First figure],
      caption: [First caption],
    ),
    (
      title: [Second],
      figure: [Second figure],
      caption: [Second caption],
    ),
    (
      title: [Third],
      figure: [Third figure],
      caption: [Third caption],
    ),
  ),
  figure-heights: (1fr, 1.2fr, 0.8fr),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/valid-auto-heights.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      figure: [Upper figure],
      caption: [Upper caption],
    ),
    (
      figure: [Lower figure],
      caption: [Lower caption],
    ),
  ),
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

write_case "$tmp_dir/invalid-palette-helper.typ" "$common_prefix
#let palette = poster-portrait-takeaway-palette(\"wine\")
#poster-portrait-takeaway(
  palette: palette,
  $valid_args
)
"

write_case "$tmp_dir/invalid-missing-sections.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-sections-type.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    figure: [Upper figure],
    caption: [Upper caption],
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-one-section.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      figure: [Only figure],
      caption: [Only caption],
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
      caption: [Upper caption],
    ),
    (
      figure: [Lower figure],
      caption: [Lower caption],
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
      caption: [Upper caption],
    ),
    (
      figure: [Lower figure],
      caption: [Lower caption],
    ),
  ),
  conclusion-takeaway: [Conclusion],
  conclusion-detail: [Detail],
)
"

write_case "$tmp_dir/invalid-widths.typ" "$common_prefix
#poster-portrait-takeaway(
  headline-takeaway: [Headline],
  headline-detail: [Detail],
  sections: (
    (
      figure: [Upper figure],
      caption: [Upper caption],
      widths: (1fr, 1fr),
    ),
    (
      figure: [Lower figure],
      caption: [Lower caption],
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
      caption: [Upper caption],
      figure-side: top,
    ),
    (
      figure: [Lower figure],
      caption: [Lower caption],
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

compile_repo_doc "examples/poster-portrait-takeaway.typ" "$tmp_dir/example.pdf"
compile_repo_doc "starters/poster-portrait-takeaway.typ" "$tmp_dir/starter.pdf"
compile_tmp_case "$tmp_dir/valid-theme.typ" "$tmp_dir/valid-theme.pdf"
compile_tmp_case "$tmp_dir/valid-palette.typ" "$tmp_dir/valid-palette.pdf"
compile_tmp_case "$tmp_dir/valid-three-sections.typ" "$tmp_dir/valid-three-sections.pdf"
compile_tmp_case "$tmp_dir/valid-auto-heights.typ" "$tmp_dir/valid-auto-heights.pdf"

expect_fail "invalid-theme-palette" "$tmp_dir/invalid-theme-palette.typ" "specify either theme or palette"
expect_fail "invalid-palette-helper" "$tmp_dir/invalid-palette-helper.typ" "unexpected argument"
expect_fail "invalid-missing-sections" "$tmp_dir/invalid-missing-sections.typ" "sections is required"
expect_fail "invalid-sections-type" "$tmp_dir/invalid-sections-type.typ" "sections must be an array"
expect_fail "invalid-one-section" "$tmp_dir/invalid-one-section.typ" "sections must contain at least two items"
expect_fail "invalid-figure-heights-length" "$tmp_dir/invalid-figure-heights-length.typ" "figure-heights length must match sections length"
expect_fail "invalid-missing-figure" "$tmp_dir/invalid-missing-figure.typ" "sections.at(0).figure is required"
expect_fail "invalid-widths" "$tmp_dir/invalid-widths.typ" "sections.at(0).widths is no longer supported"
expect_fail "invalid-figure-side" "$tmp_dir/invalid-figure-side.typ" 'figure-side must be `left` or `right`'
expect_fail "invalid-title-style-key" "$tmp_dir/invalid-title-style-key.typ" "unknown title-style key"
