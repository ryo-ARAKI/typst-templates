#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
for tool in typst python3 pdftotext pdftoppm qpdf; do
  if ! command -v "$tool" > /dev/null; then
    printf 'FAIL [environment] required command: %s\n' "$tool" >&2
    exit 1
  fi
done
if ! tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/document-bibliography.XXXXXX")"; then
  printf 'FAIL [environment] cannot create temporary output directory\n' >&2
  exit 1
fi
printf 'Artifacts: %s\n' "$tmp_dir"

python3 - "$repo_root" "$tmp_dir" <<'PY'
import json
import pathlib
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

repo, artifacts = map(pathlib.Path, sys.argv[1:])
parent = artifacts / "parent"
caller = parent / "papers" / "deep"
caller.mkdir(parents=True)
shutil.copytree(repo / "lib", parent / "typst-templates" / "lib")
refs = parent / "refs"
refs.mkdir()
bib = '''@article{A, author={Alpha, Alice}, title={Cited Alpha Study},
  journal={Alpha Journal}, year={2020}, volume={1}, pages={1--9},
  doi={10.1000/alpha}}
@article{B, author={Zulu, Bob}, title={Uncited Beta Study},
  journal={Beta Journal}, year={2021}, volume={2}, pages={10--19}}
'''
(refs / "biblio.bib").write_text(bib)
# The unchanged default string is resolved at the adapter's standard call site.
(parent / "typst-templates/lib/adapters/biblio.bib").write_text(bib)
(refs / "invalid.bib").write_text("@article{ broken")
styles = caller / "styles"
styles.mkdir()
csl = '''<?xml version="1.0" encoding="utf-8"?>
<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" class="in-text">
  <info><title>Contract fixture</title>
    <id>https://example.org/contract-fixture</id>
    <updated>2026-10-17T00:00:00+00:00</updated></info>
  <citation><layout prefix="[" suffix="]">
    <text value="CUSTOM-"/><text variable="citation-number"/>
  </layout></citation>
  <bibliography><layout>
    <text value="CUSTOM "/><text variable="title"/>
  </layout></bibliography>
</style>
'''
(styles / "journal.csl").write_text(csl)
(styles / "invalid.csl").write_text("<not-a-style/>")
failures = []
environment = re.compile(
    r"failed to download|failed to fetch|network is unreachable|connection refused|"
    r"certificate|permission denied|no space left on device|unknown font family", re.I)


def run(args):
    return subprocess.run(list(map(str, args)), capture_output=True, text=True)


def check(condition, message):
    if not condition:
        raise AssertionError(message)


class CompileFailure(AssertionError):
    pass


def fail(name, category, detail):
    if isinstance(detail, CompileFailure):
        category = "compile"
    failures.append(name)
    print(f"FAIL [{category}] {name}: {detail}", flush=True)


def source(args, *, style=None, full=None, cite=True, before="", citation=None):
    assertions = ""
    if style is not None:
        assertions += f'assert.eq(b.style, {style})\n'
    if full is not None:
        assertions += f'assert.eq(b.full, {str(full).lower()})\n'
    return '''#import "../../typst-templates/lib/presets/document.typ": *
#set page(width: 420pt, height: 360pt, margin: 35pt)
#set text(font: "Libertinus Serif", lang: "en", size: 11pt)
''' + before + "\n" + (citation or '''FIRST #citep(<A>) END

AGAIN #citep(<A>) END
''') * cite + f'''
#pagebreak()
#bibliography-list-from({args})
#context {{
  let b = query(bibliography).first()
  {assertions}
}}
'''


def compile_case(name, text, *, root=parent, directory=caller, error=None):
    input_file = directory / f"{name}.typ"
    input_file.write_text(text)
    pdf = artifacts / f"{name}.pdf"
    result = run(["typst", "compile", "--root", root, "--creation-timestamp",
                  "1792195200", "--deps", artifacts / f"{name}.deps.json", input_file, pdf])
    log = artifacts / f"{name}.log"
    log.write_text(result.stdout + result.stderr)
    if environment.search(result.stderr):
        sys.exit(f"FAIL [environment] {name}; see {log}")
    if error is not None:
        errors = "\n".join(line for line in result.stderr.splitlines()
                           if line.startswith("error:"))
        check(result.returncode != 0 and re.search(error, errors, re.I),
              f"expected {error!r} diagnostic; see {log}")
        print(f"PASS [semantic] {name} diagnostic", flush=True)
        return None
    if result.returncode != 0:
        raise CompileFailure(f"see {log}")
    print(f"PASS [compile] {name}", flush=True)
    extracted = run(["pdftotext", "-layout", pdf, "-"])
    check(extracted.returncode == 0, extracted.stderr)
    (artifacts / f"{name}.txt").write_text(extracted.stdout)
    return extracted.stdout


def success(name, args, style, full, *, cite=True, before="", citation=None,
            supplement=False):
    try:
        text = compile_case(name, source(args, style=f'"{style}"', full=full,
                                        cite=cite, before=before, citation=citation))
        check(("Cited Alpha Study" in text) == (full or cite), "A membership")
        check(("Uncited Beta Study" in text) == full, "B membership")
        if cite:
            first = text.split("FIRST", 1)[1].split("END", 1)[0]
            if style == "ieee":
                check(re.search(r"\[1(?:,|\])", first), f"numeric citation: {first!r}")
                check(re.search(r"\[1\]\s+A\. Alpha", text.split("\f")[1]),
                      "bibliography number does not identify A")
            else:
                check("Alpha" in first and "2020" in first, f"author-year: {first!r}")
            if supplement:
                check("7" in first, "supplement missing")
        print(f"PASS [semantic] {name} style / membership / citation", flush=True)
    except AssertionError as exc:
        fail(name, "semantic", exc)


version = run(["typst", "--version"])
match = re.search(r"typst (\d+)\.(\d+)\.", version.stdout)
if version.returncode or not match or tuple(map(int, match.groups())) < (0, 15):
    sys.exit("FAIL [environment] Typst 0.15.0 or later is required")
print(version.stdout.strip(), flush=True)
harvard = "harvard-cite-them-right"
path_arg = 'path: "/refs/biblio.bib"'
success("legacy", path_arg, harvard, True)
success("default-path", "", harvard, True)
success("empty-config", path_arg + ", config: (:)", harvard, True)
success("config-file-ignored", path_arg + ', config: (bibliography: "/absent.bib",)', harvard, True)
for style in (harvard, "ieee"):
    for full in (True, False):
        args = path_arg + f', config: (bibliography-style: "{style}", bibliography-full: {str(full).lower()})'
        success(f"config-{style}-{full}", args, style, full)
        success(f"no-cite-{style}-{full}", args, style, full, cite=False)
success("style-only", path_arg + ', config: (bibliography-full: false,), style: "ieee"', "ieee", False)
success("full-only", path_arg + ', config: (bibliography-style: "ieee",), full: false', "ieee", False)
success("full-only-true", path_arg + ', config: (bibliography-style: "ieee", bibliography-full: false), full: true', "ieee", True)
success("override-both", path_arg + ', config: (bibliography-style: "ieee", bibliography-full: false), '
        f'style: "{harvard}", full: true', harvard, True)
success("explicit-auto", path_arg + ', config: (bibliography-style: "ieee", bibliography-full: false), '
        'style: auto, full: auto', "ieee", False)
success("overridden-invalid-config", path_arg + ', config: (bibliography-style: auto, bibliography-full: "bad"), '
        'style: "ieee", full: false', "ieee", False)
success("overridden-unknown-style", path_arg + ', config: (bibliography-style: "missing-style",), '
        'style: "ieee"', "ieee", True)
success("set-rules", path_arg, harvard, True,
        before='#set bibliography(style: "ieee", full: false, title: [Sources marker])\n#set cite(style: "ieee")')
success("no-implicit-config", path_arg, harvard, True,
        before='#show: setup-document.with(config: (bibliography-style: "ieee", bibliography-full: false))')
success("legacy-supplement", path_arg, harvard, True,
        citation='FIRST #citep(<A>, supplement: [p. 7]) END', supplement=True)
try:
    text = compile_case("explicit-cite-style", source(path_arg, citation=
                        'FIRST #citep(<A>, style: "ieee", supplement: [p. 7]) END'))
    first = text.split("FIRST", 1)[1].split("END", 1)[0]
    check("[1" in first and "7" in first and "Alpha" not in first, first)
    check("Sources marker" in (artifacts / "set-rules.txt").read_text(), "set title lost")
    print("PASS [semantic] explicit cite style / supplement / set title", flush=True)
except (AssertionError, FileNotFoundError) as exc:
    fail("explicit-cite-style", "semantic", exc)

# Each invalid value must reach Typst, rather than silently falling back.
invalid = [
    ("config-style-auto", ', config: (bibliography-style: auto,)', r"style|auto"),
    ("config-style-type", ', config: (bibliography-style: 42,)', r"expected.*(string|str|bytes|path)"),
    ("config-full-type", ', config: (bibliography-full: "bad",)', r"expected bool"),
    ("config-full-auto", ', config: (bibliography-full: auto,)', r"expected bool"),
    ("direct-style-type", ', style: false', r"expected.*(string|str|bytes|path)"),
    ("direct-full-type", ', full: 1', r"expected bool"),
    ("unknown-style", ', style: "missing-style"', r"unknown.*style"),
    ("missing-csl", ', style: "/styles/missing.csl"', r"file not found"),
    ("invalid-csl", ', style: path("styles/invalid.csl")', r"CSL|style|XML"),
    # A plain relative string must not be silently rebased to the caller.
    ("relative-csl", ', style: "styles/journal.csl"', r"file not found"),
    ("outside-root-csl", ', style: path("../../../outside.csl")', r"access denied|outside.*root"),
]
for name, suffix, error in invalid:
    try:
        compile_case(name, source(path_arg + suffix), error=error)
    except AssertionError as exc:
        fail(name, "semantic", exc)
for name, args, citation, error in [
    ("missing-bib", 'path: "/refs/missing.bib"', None, r"file not found"),
    ("invalid-bib", 'path: "/refs/invalid.bib"', None, r"parse|bibliography"),
    ("missing-key", path_arg, 'FIRST #citep(<MISSING>) END', r"key.*not present"),
]:
    try:
        compile_case(name, source(args, citation=citation), error=error)
    except AssertionError as exc:
        fail(name, "semantic", exc)

# Values must survive forwarding without coercion. The caller is deliberately
# deeper than the adapter, with no CSL under the adapter's relative path.
custom_cases = []
for kind, value in [
    ("path", 'path("styles/journal.csl")'),
    ("root", '"/papers/deep/styles/journal.csl"'),
    ("bytes", 'read("styles/journal.csl", encoding: none)'),
]:
    for via in ("config", "direct"):
        name = f"custom-{kind}-{via}"
        arg = (f'config: (bibliography-style: {value},)' if via == "config"
               else f'style: {value}')
        text = source(path_arg + ", " + arg, full=True)
        custom_cases.append((name, text))
        try:
            output = compile_case(name, text)
            check(output.count("CUSTOM-1") == 2, "custom citation style lost")
            check("CUSTOM Cited Alpha Study" in output and
                  "CUSTOM Uncited Beta Study" in output, "custom bibliography style lost")
            print(f"PASS [semantic] {name} marker / membership", flush=True)
        except AssertionError as exc:
            fail(name, "semantic", exc)


def verify_links(name):
    """Match each body citation's visible words, annotation, and A's entry row."""
    pdf = artifacts / f"{name}.pdf"
    result = run(["qpdf", "--json", pdf])
    check(result.returncode == 0, result.stderr)
    (artifacts / f"{name}.qpdf.json").write_text(result.stdout)
    data = json.loads(result.stdout)
    objects = data["qpdf"][1]

    def dereference(value):
        while isinstance(value, str) and f"obj:{value}" in objects:
            value = objects[f"obj:{value}"]["value"]
        return value

    bbox = artifacts / f"{name}.bbox.html"
    result = run(["pdftotext", "-bbox", pdf, bbox])
    check(result.returncode == 0, result.stderr)
    pages = ET.parse(bbox).findall(".//{*}page")
    words = [page.findall(".//{*}word") for page in pages]
    # Titles are distinct and the cited A and uncited B occupy different rows.
    targets = {}
    for number, page_words in enumerate(words):
        for word in page_words:
            if "Cited" in (word.text or ""):
                targets["A"] = (number, float(word.attrib["yMin"]))
            if "Uncited" in (word.text or ""):
                targets["B"] = (number, float(word.attrib["yMin"]))
    check(set(targets) == {"A", "B"}, "cannot identify both bibliography entries")
    body = dereference(data["pages"][0]["object"])
    annotations = [dereference(it) for it in body.get("/Annots", [])]
    page_indices = {page["object"]: i for i, page in enumerate(data["pages"])}
    height = float(pages[0].attrib["height"])
    evidence = []
    for marker in ("FIRST", "AGAIN"):
        start = next(w for w in words[0] if w.text == marker)
        row = float(start.attrib["yMin"])
        end = next(w for w in words[0] if w.text == "END" and
                   abs(float(w.attrib["yMin"]) - row) < 1)
        citation_words = [w for w in words[0]
                          if abs(float(w.attrib["yMin"]) - row) < 1
                          and float(w.attrib["xMin"]) >= float(start.attrib["xMax"])
                          and float(w.attrib["xMax"]) <= float(end.attrib["xMin"])
                          and re.search(r"\w", w.text or "")]
        check(citation_words, f"{marker}: no visible citation words")
        matched = []
        for word in citation_words:
            x = (float(word.attrib["xMin"]) + float(word.attrib["xMax"])) / 2
            y = height - (float(word.attrib["yMin"]) + float(word.attrib["yMax"])) / 2
            covering = [a for a in annotations if a.get("/Subtype") == "/Link"
                        and a["/Rect"][0] <= x <= a["/Rect"][2]
                        and a["/Rect"][1] <= y <= a["/Rect"][3]]
            check(covering, f"{marker}: {word.text} has no PDF link")
            matched.extend(covering)
        for annotation in matched:
            # URI actions (e.g. A's DOI) are not bibliography destinations.
            dest = annotation.get("/Dest")
            if dest is None:
                action = dereference(annotation.get("/A", {}))
                check(action.get("/S") == "/GoTo", "citation points to external URI")
                dest = action.get("/D")
            dest = dereference(dest)
            check(isinstance(dest, list) and dest[1] == "/XYZ", f"unexpected destination: {dest}")
            target_page = page_indices[dest[0]]
            target_y = float(pages[target_page].attrib["height"]) - dest[3]
            a_page, a_y = targets["A"]
            b_page, b_y = targets["B"]
            check(target_page == a_page and abs(target_y - a_y) < 12,
                  f"{marker}: destination misses A: {dest}; A={targets['A']}")
            check(target_page != b_page or abs(target_y - a_y) < abs(target_y - b_y),
                  f"{marker}: destination is closer to uncited B")
            evidence.append({"citation": marker, "destination": dest,
                             "entry_A": targets["A"], "entry_B": targets["B"]})
    (artifacts / f"{name}.links.json").write_text(json.dumps(evidence, indent=2))
    print(f"PASS [link] {name}: FIRST / AGAIN words -> A entry page and coordinates", flush=True)


for name in ("legacy", "config-ieee-True", "custom-path-config"):
    try:
        verify_links(name)
    except (AssertionError, FileNotFoundError, KeyError, StopIteration) as exc:
        fail(name, "link", exc)
    try:
        result = run(["pdftoppm", "-scale-to", "1100", "-png",
                      artifacts / f"{name}.pdf", artifacts / name])
        check(result.returncode == 0, result.stderr)
        print(f"PASS [render] {name}", flush=True)
        print(f"MANUAL [visual] inspect {artifacts / name}-*.png", flush=True)
    except AssertionError as exc:
        fail(name, "render", exc)

# Use real copies and inspect actual input dependencies after moving the whole
# parent layout. No symlink or original checkout is available via compile root.
relocated = artifacts / "relocated-parent"
shutil.copytree(parent, relocated)
for name, text in custom_cases:
    try:
        output = compile_case("relocated-" + name, text, root=relocated,
                              directory=relocated / "papers/deep")
        deps = json.loads((artifacts / f"relocated-{name}.deps.json").read_text())["inputs"]
        deps = [pathlib.Path(p).resolve() for p in deps]
        check(not any(p.is_relative_to(parent) or p.is_relative_to(repo) for p in deps),
              "relocated document still reads original layout")
        check(relocated / "papers/deep/styles/journal.csl" in deps and
              relocated / "refs/biblio.bib" in deps, "relocated inputs not read")
        check(output == (artifacts / f"{name}.txt").read_text(), "relocated output changed")
        print(f"PASS [semantic] relocated-{name}: local dependencies / identical text", flush=True)
    except AssertionError as exc:
        fail("relocated-" + name, "semantic", exc)

# Extract the actual published complete blocks unchanged, in their documented
# parent/submodule layout. The explanatory CSL remains a runtime-only fixture.
readme_parent = artifacts / "readme-parent"
shutil.copytree(parent / "typst-templates", readme_parent / "typst-templates")
(readme_parent / "refs").mkdir()
shutil.copyfile(repo / "starters/biblio.bib", readme_parent / "refs/biblio.bib")
(readme_parent / "styles").mkdir()
(readme_parent / "styles/journal.csl").write_text(csl)
blocks = re.findall(r'<!-- document-bibliography-example: ([\w-]+) -->\n```typ\n(.*?)\n```',
                    (repo / "README.md").read_text(), re.S)
expected = {"default", "numeric", "override", "csl-path", "csl-root"}
if {name for name, _ in blocks} != expected or len(blocks) != len(expected):
    fail("README examples", "semantic", "missing or duplicate tagged complete blocks")
for name, text in blocks:
    try:
        output = compile_case("readme-" + name, text, root=readme_parent, directory=readme_parent)
        check("Information-thermodynamic" in output, "cited bibliography entry missing")
        if name == "numeric":
            check("[1]" in output and "Frisch" not in output, "numeric / cited-only contract")
        elif name in ("default", "override"):
            check("Tanogami と Araki, 2024" in output and "Frisch" in output,
                  "direct override / full contract")
        else:
            check("CUSTOM-1" in output and "Frisch" not in output, "custom CSL / cited-only contract")
        print(f"PASS [semantic] readme-{name} published example", flush=True)
    except AssertionError as exc:
        fail("readme-" + name, "semantic", exc)

if failures:
    print(f"FAILED: {len(failures)} check(s): {', '.join(failures)}")
    sys.exit(1)
print("PASS: document bibliography compile / semantic / link checks (visual review separate)")
PY
