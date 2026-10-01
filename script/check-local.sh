#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
failures=0

for tool in typst rg awk mktemp; do
  if ! command -v "$tool" > /dev/null; then
    printf 'FAIL [environment] required command: %s\n' "$tool" >&2
    exit 1
  fi
done

if ! tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/typst-templates-check.XXXXXX")"; then
  printf 'FAIL [environment] cannot create output directory under %s\n' "${TMPDIR:-/tmp}" >&2
  exit 1
fi
tmp_dir="$(cd "$tmp_dir" && pwd -P)"
printf 'Artifacts: %s\n' "$tmp_dir"
cd "$repo_root"

if ! typst --version > "$tmp_dir/version.txt" 2>&1 ||
   ! typst fonts > "$tmp_dir/fonts.txt" 2> "$tmp_dir/fonts.err"; then
  printf 'FAIL [environment] Typst startup/font discovery; see %s\n' "$tmp_dir" >&2
  exit 1
fi
cat "$tmp_dir/version.txt"
version="$(awk '{print $2}' "$tmp_dir/version.txt")"
if [[ ! "$version" =~ ^([0-9]+)\.([0-9]+)\. ]] ||
   (( BASH_REMATCH[1] == 0 && BASH_REMATCH[2] < 15 )); then
  printf 'FAIL [environment] Typst 0.15.0 or later is required\n' >&2
  exit 1
fi
for font in 'Libertinus Serif' IPAexMincho 'Liberation Sans' IPAexGothic \
  Cabin 'Noto Sans CJK JP' 'Latin Modern Math' 'Noto Sans Mono' 'Adobe Blank'; do
  if ! rg -Fx "$font" "$tmp_dir/fonts.txt" > /dev/null; then
    printf 'FAIL [environment] missing font: %s\n' "$font" >&2
    failures=$((failures + 1))
  fi
done
if (( failures )); then exit 1; fi

report_failure() {
  local target="$1" log="$2"
  local category="${3:-compile}"
  # Known execution prerequisites are distinct from source/semantic failures.
  # Leave other failures as "compile" rather than inferring their cause.
  if rg '^error:' "$log" | rg -qi 'failed to download|failed to fetch|network is unreachable|connection refused|certificate|no space left on device|permission denied'; then
    category=environment
  fi
  printf 'FAIL [%s] %s; log: %s\n' "$category" "$target" "$log" >&2
  failures=$((failures + 1))
}

compile_case() {
  local target="$1" input="$2" output="$3" root="$4"
  local purpose="${5:-compile}"
  local log="${output%.pdf}.log"
  if typst compile --root "$root" "$input" "$output" > "$log" 2>&1; then
    printf 'PASS [%s] %s\n' "$purpose" "$target"
  else
    report_failure "$target" "$log" "$purpose"
  fi
}

# The existing checker owns both portrait sources; do not compile them again.
if TMPDIR="$tmp_dir" bash "$repo_root/script/check-poster-portrait-takeaway-api.sh" \
  > "$tmp_dir/poster-api.log" 2>&1; then
  printf 'PASS [compile] examples/poster-portrait-takeaway.typ (poster API checker)\n'
  printf 'PASS [compile] starters/poster-portrait-takeaway.typ (poster API checker)\n'
  printf 'PASS [semantic] poster API diagnostics and BibTeX formats\n'
else
  report_failure 'poster API / portrait sources' "$tmp_dir/poster-api.log"
fi

for source in starters/document-jp.typ starters/slide.typ starters/poster-column.typ \
  examples/document-jp.typ examples/slide.typ examples/slide-speaker-notes.typ examples/poster-column.typ; do
  output="$tmp_dir/${source//\//-}"
  compile_case "$source" "$repo_root/$source" "${output%.typ}.pdf" "$repo_root"
done

# Compile the published README block itself, so a broken example cannot drift
# independently of the existing annotation examples. Only its import path is
# resolved to this checkout; the remaining published code is used unchanged.
awk '
  /^```typ$/ { in_typ = 1; next }
  /^```$/ { if (capture) exit; in_typ = 0 }
  in_typ && /^#import "@preview\/physica:/ { capture = 1 }
  capture { print }
' "$repo_root/README.md" > "$tmp_dir/readme-annotation.typ"
if ! rg -q '^#pinit-highlight-equation-from' "$tmp_dir/readme-annotation.typ"; then
  printf 'FAIL [semantic] README annotation block was not found\n' >&2
  failures=$((failures + 1))
else
  # A temporary parent layout preserves the README's submodule-relative import.
  ln -s "$repo_root" "$tmp_dir/typst-templates"
  compile_case 'README annotation excerpt' "$tmp_dir/readme-annotation.typ" "$tmp_dir/readme-annotation.pdf" /
fi

# Existing titles cover ordinary structured authors. This grouped source adds
# the omitted/empty/one/many and string/content normalization boundaries.
cat > "$tmp_dir/authors-normalization.typ" <<EOF
#import "$repo_root/lib/core/metadata.typ": normalize-metadata
#import "$repo_root/lib/core/config.typ": document-config, slide-config, poster-config
#assert.eq(normalize-metadata((:)).authors, ())
#assert.eq(normalize-metadata((authors: (),)).authors, ())
#let one = (name: [Alice], affiliation: "Institute", email: "alice@example.com")
#assert.eq(normalize-metadata((authors: (one,),)).authors, (one,))
#let many = normalize-metadata((authors: ((name: "Alice", affiliation: [Institute], email: [alice@example.com]), (name: [Bob], affiliation: "Lab")),)).authors
#assert.eq(many.len(), 2)
#assert.eq(many.at(1), (name: [Bob], affiliation: "Lab", email: []))
#for preset in (document-config, slide-config, poster-config) {
  assert(preset().metadata.authors.len() > 0)
  assert.eq(preset(overrides: (authors: (),)).metadata.authors, ())
}
EOF
compile_case 'authors normalization assertions' "$tmp_dir/authors-normalization.typ" "$tmp_dir/authors-normalization.pdf" / semantic

# These actual title connections previously failed despite valid normalized
# authors. Group empty and multiple-content document titles in one input.
cat > "$tmp_dir/authors-document.typ" <<EOF
#import "$repo_root/lib/presets/document.typ": *
#show: setup-document
#let empty = (title: [No authors document], authors: (), date: [], abstract: [])
#document-title(config: empty)
Body.
#pagebreak()
#let many = (title: [Multiple authors document], authors: ((name: [*Alice*], affiliation: "Institute", email: "alice@example.com"), (name: "Bob", affiliation: [Lab])), date: [], abstract: [])
#document-title(config: many)
Body.
EOF
compile_case 'empty / content authors document titles' "$tmp_dir/authors-document.typ" "$tmp_dir/authors-document.pdf" /

cat > "$tmp_dir/authors-slide.typ" <<EOF
#import "$repo_root/lib/presets/slide.typ": *
#show: slide-theme.with(config: (title: [No authors slide], authors: (), subtitle: [], summary: []))
#slide-title-slide()
EOF
compile_case 'empty authors slide title' "$tmp_dir/authors-slide.typ" "$tmp_dir/authors-slide.pdf" /

check_authors_diagnostic() {
  local name="$1" config="$2" scope="$3" reason="$4"
  local input="$tmp_dir/$name.typ" log="$tmp_dir/$name.log"
  printf '#import "%s/lib/core/config.typ": slide-config\n#slide-config(overrides: %s)\n' \
    "$repo_root" "$config" > "$input"
  if typst compile --root / "$input" "$tmp_dir/$name.pdf" > "$log" 2>&1; then
    printf 'FAIL [semantic] %s was accepted\n' "$name" >&2
    failures=$((failures + 1))
    return
  fi
  # Check only actual error lines for the public scope, reason and migration.
  # Do not match source excerpts, stack frames, line numbers or full messages.
  local diagnostic
  diagnostic="$(rg '^error:' "$log" || true)"
  if [[ "$diagnostic" == *"$scope"* && "$diagnostic" == *"$reason"* &&
        "$diagnostic" == *'authors:'* && "$diagnostic" == *'name:'* ]]; then
    printf 'PASS [semantic] %s diagnostic\n' "$name"
  else
    report_failure "$name diagnostic" "$log" semantic
  fi
}
check_authors_diagnostic legacy-author '(author: [Alice], authors: (),)' metadata.author 'no longer supported'
check_authors_diagnostic scalar-authors '(authors: [Alice],)' metadata.authors 'array of author dictionaries'
check_authors_diagnostic positional-authors '(authors: ([Alice], [Institute], [alice@example.com]),)' metadata.authors 'array of author dictionaries'

# One representative input protects referenced-only selection, display order,
# forward/back/repeated references and Touying pause/repeat. Inspect rendered
# bodies and display values through public Typst APIs, not helper internals.
cat > "$tmp_dir/equation-numbering.typ" <<EOF
#import "$repo_root/lib/presets/slide.typ": *
#show: slide-theme.with(config: (
  text-font: "Noto Sans CJK JP", cjk-font: "Noto Sans CJK JP",
  title: [Reference numbering], date: datetime(year: 2026, month: 10, day: 2),
  equation-numbering: "referenced-only",
  equation-numbering-pattern: sys.inputs.at("pattern", default: "(1)"),
))
== First equations
#slide[
  UNLABELED $ u = 0 $
  UNUSED $ v = 0 $ <unused>
  FIRST $ a = 1 $ <first>
  Forward: @second. Repeated: @second.
]
== Second equation
#slide[
  SECOND $ b = 2 $ <second>
  Backward: @first. Repeated: @first.
]
== Paused equation
#slide[
  THIRD $ c = 3 $ <third>
  #pause
  Paused reference: @third. Backward again: @first.
]
== After pause
#slide(repeat: 2)[
  FOURTH $ d = 4 $ <fourth>
  Reference: @fourth. Previous slide: @third.
  #context {
    let numbered = query(math.equation.where(block: true)).filter(it => it.numbering != none)
    let bodies = ($ a = 1 $.body, $ b = 2 $.body, $ c = 3 $.body, $ c = 3 $.body, $ d = 4 $.body, $ d = 4 $.body)
    assert.eq(numbered.map(it => it.body), bodies, message: "only referenced equations are numbered, in display order, including pause/repeat copies")
    let pattern = sys.inputs.at("pattern", default: "(1)")
    let displayed = numbered.map(it => std.numbering(it.numbering, ..counter(math.equation).at(it.location())))
    assert.eq(displayed, (1, 2, 3, 3, 4, 4).map(n => std.numbering(pattern, n)), message: "referenced equation numbers are contiguous and repeat consistently")
  }
]
EOF
compile_case 'referenced-only equation bodies / display numbers' "$tmp_dir/equation-numbering.typ" "$tmp_dir/equation-numbering.pdf" / semantic
if typst compile --root / --input 'pattern=[A]' "$tmp_dir/equation-numbering.typ" \
  "$tmp_dir/equation-numbering-pattern.pdf" > "$tmp_dir/equation-numbering-pattern.log" 2>&1; then
  printf 'PASS [semantic] referenced-only equation numbering pattern\n'
else
  report_failure 'referenced-only equation numbering pattern' "$tmp_dir/equation-numbering-pattern.log" semantic
fi
printf 'MANUAL [visual] inspect PDFs, including all 3 portrait pages and starter; see README\n'
printf 'Artifacts retained: %s\n' "$tmp_dir"
if (( failures )); then
  printf 'FAILED: %s check(s)\n' "$failures" >&2
  exit 1
fi
printf 'PASS: local compile / semantic checks (PDF visual and link review remain separate)\n'
