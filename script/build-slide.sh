#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'HELP'
Usage: bash script/build-slide.sh --root ROOT SOURCE.typ OUTPUT_DIR

Build a mode-aware manuscript with Typst >= 0.15.0:
  NAME-presentation.pdf, NAME-handout.pdf, NAME-presentation.pdfpc
SOURCE must be inside existing ROOT. All relative paths use the caller's cwd.
OUTPUT_DIR must not exist (including empty directories or dangling symlinks);
its parent must exist. Use a new output directory for each build.
The manuscript must accept mode=presentation / mode=handout and emit exactly
one <pdfpc-file>. Inputs and dependencies must stay unchanged during the build.
SOURCE_DATE_EPOCH: integer seconds in 0..253402300799; otherwise capture the
start time once. All three Typst operations use the same creation timestamp.
Requires Bash, Typst, and basic GNU coreutils (including mv -T -n, realpath).
PDF inspection tools, Python, pdfpc and touying-exporter are not build tools.
Failures diagnose the stage; only a complete three-file bundle is published.
HELP
}

fail() { printf 'build-slide [%s] %s\n' "$stage" "$*" >&2; exit 1; }
stage=input
if [[ $# == 1 && ( $1 == --help || $1 == -h ) ]]; then usage; exit 0; fi
[[ $# == 4 && $1 == --root ]] || fail 'expected --root ROOT SOURCE.typ OUTPUT_DIR (see --help)'
root_arg=$2 source_arg=$3 output_arg=$4
[[ -n $root_arg && -n $source_arg && -n $output_arg ]] || fail 'paths must not be empty'

stage=dependency
for tool in typst realpath dirname basename mktemp mv rm date; do
  command -v "$tool" >/dev/null || fail "required command missing: $tool"
done
if ! version=$(typst --version); then fail 'Typst startup failed'; fi
if [[ ! $version =~ ^typst\ ([0-9]+)\.([0-9]+)\.([0-9]+)(\ |$) ]] ||
   (( 10#${BASH_REMATCH[1]} == 0 && 10#${BASH_REMATCH[2]} < 15 )); then
  fail "Typst >= 0.15.0 required; found: $version"
fi

stage=input
[[ -d $root_arg ]] || fail "ROOT must be an existing directory: $root_arg"
root=$(realpath -e -- "$root_arg") || fail "cannot resolve ROOT: $root_arg"
[[ -f $source_arg && $source_arg == *.typ ]] || fail "SOURCE must be an existing .typ file: $source_arg"
source=$(realpath -e -- "$source_arg") || fail "cannot resolve SOURCE: $source_arg"
[[ $root == / || $source == "$root/"* ]] || fail "SOURCE must be inside ROOT: $source_arg"
name=$(basename -- "$source_arg" .typ)
[[ -n $name ]] || fail 'SOURCE stem must not be empty'
# Strip trailing slashes before testing symlinks, including dangling ones.
while [[ $output_arg == */ && $output_arg != / ]]; do output_arg=${output_arg%/}; done
[[ ! -e $output_arg && ! -L $output_arg ]] || fail "OUTPUT_DIR already exists: $output_arg"
parent_arg=$(dirname -- "$output_arg")
[[ -d $parent_arg ]] || fail "OUTPUT_DIR parent must exist: $parent_arg"
parent=$(realpath -e -- "$parent_arg") || fail "cannot resolve output parent: $parent_arg"
output="$parent/$(basename -- "$output_arg")"
[[ ! -e $output && ! -L $output ]] || fail "OUTPUT_DIR already exists: $output"

stage=timestamp
if [[ ${SOURCE_DATE_EPOCH+x} ]]; then
  epoch=$SOURCE_DATE_EPOCH
else
  epoch=$(date +%s) || fail 'cannot read start time'
fi
[[ $epoch =~ ^[0-9]+$ ]] || fail 'SOURCE_DATE_EPOCH must be integer seconds in 0..253402300799'
# Normalize leading zeros without arithmetic overflow or octal interpretation.
epoch=${epoch#"${epoch%%[!0]*}"}
epoch=${epoch:-0}
if (( ${#epoch} > 12 )) || { (( ${#epoch} == 12 )) && [[ $epoch > 253402300799 ]]; }; then
  fail 'SOURCE_DATE_EPOCH must be integer seconds in 0..253402300799'
fi

stage=temporary
work=''
cleanup() {
  local status=$?
  # The only removal target is the exact directory allocated by this process.
  if [[ -n $work && -d $work ]]; then rm -rf -- "$work" || printf 'build-slide [cleanup] cannot remove %s\n' "$work" >&2; fi
  return "$status"
}
trap cleanup EXIT
trap 'fail "interrupted (HUP)"' HUP
trap 'fail "interrupted (INT)"' INT
trap 'fail "interrupted (TERM)"' TERM
work=$(mktemp -d "$parent/.build-slide-XXXXXXXXXX") || fail "cannot create temporary directory in $parent"
common=(--root "$root" --creation-timestamp "$epoch")
presentation="$work/$name-presentation.pdf"
handout="$work/$name-handout.pdf"
pdfpc="$work/$name-presentation.pdfpc"

stage='presentation compile'
typst compile "${common[@]}" --input mode=presentation "$source" "$presentation" || fail 'Typst failed (see diagnostic above)'
[[ -s $presentation ]] || fail 'Typst did not produce a nonempty PDF'
stage='handout compile'
typst compile "${common[@]}" --input mode=handout "$source" "$handout" || fail 'Typst failed (see diagnostic above)'
[[ -s $handout ]] || fail 'Typst did not produce a nonempty PDF'

stage='metadata eval'
# Validate through Typst's public query API and serialize Touying's dictionary.
# No JSON parser/exporter or representative-example page count in this builder.
expression='{
  let matches = query(<pdfpc-file>)
  assert.eq(matches.len(), 1, message: "metadata: expected exactly one <pdfpc-file>")
  let data = matches.first().value
  assert(type(data) == dictionary, message: "metadata: expected dictionary")
  assert(data.at("pdfpcFormat", default: none) == 2, message: "metadata: pdfpcFormat must be 2")
  let pages = data.at("pages", default: none)
  assert(type(pages) == array, message: "metadata: pages must be an array")
  assert(pages.len() > 0, message: "metadata: pages must not be empty")
  for (i, page) in pages.enumerate() {
    assert(type(page) == dictionary, message: "metadata: page must be a dictionary")
    let idx = page.at("idx", default: none)
    assert(type(idx) == int and idx == i, message: "metadata: integer idx must be consecutive from zero")
  }
  data
}'
typst eval "${common[@]}" --input mode=presentation --in "$source" "$expression" > "$pdfpc" || fail 'Typst eval or metadata validation failed (see diagnostic above)'
[[ -s $pdfpc ]] || fail 'Typst did not produce nonempty metadata'

stage=finalize
# -T forbids nesting into an existing directory; -n forbids replacement, even
# if the destination appears after validation. A skipped move can return zero,
# so success also requires the owned temporary directory to have disappeared.
mv -T -n -- "$work" "$output" || fail "cannot finalize OUTPUT_DIR: $output"
[[ ! -e $work ]] || fail "OUTPUT_DIR already exists; cannot finalize: $output"
work=''
printf 'SOURCE_DATE_EPOCH=%s\n' "$epoch"
printf 'Created: %s\n' "$output/$name-presentation.pdf" "$output/$name-handout.pdf" "$output/$name-presentation.pdfpc"
