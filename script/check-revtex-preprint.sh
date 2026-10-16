#!/usr/bin/env bash
# Exercise the standalone public API with disposable manuscripts, never repo fixtures.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/revtex-preprint-check.XXXXXX")"
printf 'Validation artifacts: %s\n' "$tmp_dir"
cp "$repo_root/standalone/revtex-preprint.typ" "$tmp_dir/"
mkdir "$tmp_dir/packages" "$tmp_dir/cache"
compile() {
  typst compile --root "$tmp_dir" --ignore-system-fonts \
    --package-path "$tmp_dir/packages" --package-cache-path "$tmp_dir/cache" \
    "$tmp_dir/$1.typ" "$tmp_dir/$1.pdf" 2> "$tmp_dir/$1.err"
  if [[ -s "$tmp_dir/$1.err" ]]; then cat "$tmp_dir/$1.err" >&2; return 1; fi
  pdftotext -layout "$tmp_dir/$1.pdf" "$tmp_dir/$1.txt"
}

# Removing continuity at the appendix boundary must fail this contract.
cat > "$tmp_dir/global.typ" <<'TYP'
#import "revtex-preprint.typ": revtex-preprint, appendices
#show: revtex-preprint
= Mixed case heading <main>
$ x = 1 $ <eq-main>
#show: appendices
= Supplement <app>
$ y = 2 $ <eq-app>
MainRef: @eq-main. AppendixRef: @eq-app.
TYP
if ! compile global; then cat "$tmp_dir/global.err" >&2; exit 1; fi
python3 - "$tmp_dir" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
text = re.sub(r'\s+', ' ', (root / 'global.txt').read_text())
assert re.search(r'AppendixRef:.*?\(2\)', text), text
print('PASS: global equations continue into appendices')
PY

python3 - "$tmp_dir" <<'PY'
import json, pathlib, re, subprocess, sys, xml.etree.ElementTree as ET
root = pathlib.Path(sys.argv[1])
base = ['--root', str(root), '--ignore-system-fonts', '--package-path', str(root/'packages'),
        '--package-cache-path', str(root/'cache')]

def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout

def compile(name, source, error=None):
    path = root / (name + '.typ')
    path.write_text(source)
    result = subprocess.run(['typst', 'compile', *base, '--deps', str(root/(name+'.deps.json')),
                             str(path), str(root/(name+'.pdf'))], capture_output=True, text=True)
    (root/(name+'.err')).write_text(result.stderr)
    if error:
        diagnostics = '\n'.join(l for l in result.stderr.splitlines() if l.startswith('error:'))
        assert result.returncode != 0 and error in diagnostics, (name, result.stderr)
        return
    assert result.returncode == 0 and not result.stderr, (name, result.stderr)
    run('qpdf', '--check', str(root/(name+'.pdf')))
    text = run('pdftotext', '-layout', str(root/(name+'.pdf')), '-')
    (root/(name+'.txt')).write_text(text)
    return re.sub(r'\s+', ' ', re.sub(r'\xad\s*', '', text))

prefix = '#import "revtex-preprint.typ": revtex-preprint, appendices, draft\n'
(root/'refs.bib').write_text('''@article{sample, author={Jane Example}, title={Transport and information},
 journal={Physical Review E}, year={2025}, volume={111}, pages={012345}}''')
front = '''
  title: [TitleMarker $ z = 0 $], pdf-title: "Transport study",
  authors: ((name: "Alice Example", affiliations: ("uni", "lab"), corresponding: true,
             email: "alice@example.org", orcid: "0000-0000-0000-0000"),
            (name: "Bob Example", affiliations: ("lab",), corresponding: true),
            (name: "Unaffiliated Example",)),
  affiliations: ((id: "uni", text: [UniversityMarker]), (id: "lab", text: [LaboratoryMarker])),
  abstract: [AbstractMarker describes the model. $ a = 0 $],
  keywords: ("KeywordMarker", "physics"),
'''
body = '''
= Mixed case heading <sec-one>
BodyMarker describes the result. ForwardRef: @eq-app. ForwardSection: @app.
$ x = 1 $ <eq-one>
== Small heading
$ x = 2 $ <eq-small>
#heading(numbering: none)[UnnumberedMarker]
$ x = 3 $ <eq-unnumbered-heading>
#math.equation(block: true, numbering: none)[$ x = 0 $]
$ x = 4 $ <eq-after-unnumbered>
= Second section <sec-two>
$ y = 1 $ <eq-two>
#figure(rect(width: 20mm, height: 5mm), caption: [CaptionMarker], alt: "A rectangle") <fig-one>
#figure(table(columns: 2, table.header([HeaderMarker], [Value]), [BodyCell], [1]), caption: [TableCaptionMarker]) <tab-one>
Footnote prose#footnote[FootnoteMarker] with a citation @sample.

#show: appendices
= Supplement <app>
AppendixMarker discusses @sec-one and @eq-one.
$ z = 1 $ <eq-app>
== Subappendix
$ z = 2 $ <eq-app-small>
= Second supplement
$ z = 3 $ <eq-app-two>
#figure(rect(width: 20mm, height: 5mm), caption: [Second figure]) <fig-two>
#figure(table(columns: 1, [Value]), caption: [Second table]) <tab-two>

MainRef: @eq-one. SmallRef: @eq-small. UnheadedRef: @eq-unnumbered-heading.
UnnumberedRef: @eq-after-unnumbered. SecondRef: @eq-two.
AppRef: @eq-app. AppSmallRef: @eq-app-small. AppTwoRef: @eq-app-two.
FigureRefs: @fig-one; @fig-two. TableRefs: @tab-one; @tab-two.
RomanRef: @sec-two. CustomRef: #ref(<eq-one>, supplement: [Formula]).
PageRef: #ref(<eq-one>, form: "page").
#bibliography("refs.bib")
'''
# A missing reset, reset at a subheading, or use of the reference-site context
# changes these independently specified public results.
for mode in ('global', 'section'):
    text = compile(mode+'-full', prefix + '#show: revtex-preprint.with(\n'+front+
                   f' equation-numbering: "{mode}", section-numbering: "I.1",\n)\n'+body)
    expected = ['1','2','3','4','5','6','7','8'] if mode == 'global' else ['1.1','1.2','1.3','1.4','2.1','A.1','A.2','B.1']
    for marker, number in zip(('MainRef','SmallRef','UnheadedRef','UnnumberedRef','SecondRef','AppRef','AppSmallRef','AppTwoRef'), expected):
        assert re.search(marker+r': Equation\s*\('+re.escape(number)+r'\)', text), (marker, text)
    assert 'RomanRef: Section II' in text, text
    assert 'ForwardSection: Appendix A' in text, text
    assert f'ForwardRef: Equation ({expected[5]})' in text, text
    assert 'FigureRefs: Figure 1; Figure 2' in text and 'TableRefs: Table 1; Table 2' in text, text
    assert f'CustomRef: Formula ({expected[0]})' in text, text
    assert 'PageRef: page ' in text, text
    assert 'Transport and information' in text, text
    assert 'with a citation (Example 2025).' in text, text
    query = json.loads(run('typst', 'query', *base, str(root/(mode+'-full.typ')), 'title'))
    assert len(query) == 1, query
print('PASS: numbering, forward/back refs, native title, figures/tables, bibliography')

# Check document metadata, semantic tags, outline titles and working link targets
# through the actual PDF rather than a snapshot of implementation source.
data = json.loads(run('qpdf', '--json', str(root/'global-full.pdf')))
objects = data['qpdf'][1]
values = [v['value'] for v in objects.values() if isinstance(v.get('value'), dict)]
info = next(v for v in values if v.get('/Creator','').startswith('u:Typst'))
assert info['/Title'] == 'u:Transport study' and 'Alice Example' in info['/Author'], info
assert 'KeywordMarker' in info['/Keywords'] and '/CreationDate' not in info, info
catalog = next(v for v in values if v.get('/Type') == '/Catalog')
assert catalog['/MarkInfo']['/Marked'] and catalog['/StructTreeRoot'], catalog
roles = {v.get('/S') for v in values if isinstance(v.get('/S'), str)}
assert {'/Title','/H1','/Formula','/Figure','/Table','/TH','/Link'}.issubset(roles), roles
page = next(v for v in values if v.get('/Type') == '/Page')
assert abs(page['/MediaBox'][2]-595.276)<0.01 and abs(page['/MediaBox'][3]-841.89)<0.01, page
outlines = [o['title'] for p in data['pages'] for o in p['outlines']]
assert 'I Mixed case heading' in outlines and 'A Supplement' in outlines, outlines
uris = [v['/A'].get('/URI','') for v in values if isinstance(v.get('/A'),dict)]
assert 'u:mailto:alice@example.org' in uris and 'u:https://orcid.org/0000-0000-0000-0000' in uris, uris
assert any('/Dest' in v for v in values if v.get('/Subtype') == '/Link'), 'no internal links'
# Superscript affiliation links must reach two distinct destinations.
affiliation_links = [v['/Dest'] for v in values if v.get('/Subtype') == '/Link' and v.get('/Contents') == 'u:page 1'][:3]
assert len(affiliation_links) == 3 and affiliation_links[0] != affiliation_links[1] == affiliation_links[2], affiliation_links
print('PASS: metadata, semantic tags, outlines, internal/external links')

# Line numbering must follow prose only and remain continuous across page breaks.
line_body = '''
= HeadingMarker
BodyMarker describes this model.\n\n
AfterMarker continues the argument.#footnote[FootnoteMarker]
$ x = 1 $ <eq-one>
#figure(rect(width: 20mm, height: 5mm), caption: [CaptionMarker])
#figure(table(columns: 1, [CellMarker]), caption: [TableCaptionMarker])
#pagebreak()
#show: appendices
= AppendixHeadingMarker
AppendixMarker concludes. @sample
#bibliography("refs.bib")
'''
def words(name):
    xml = run('pdftotext', '-bbox', str(root/(name+'.pdf')), '-')
    tree = ET.fromstring(xml)
    ns = {'x':'http://www.w3.org/1999/xhtml'}
    return [[(w.text or '', {k:float(v) for k,v in w.attrib.items()}) for w in p.findall('.//x:word', ns)]
            for p in tree.findall('.//x:page', ns)]

# Inspect physical PDF pages, independently of the printed page counter and
# the figure's source anchor (which can precede its eventual float page).
def position(name, marker):
    hits = [(i+1,b) for i,p in enumerate(words(name)) for t,b in p if t == marker]
    assert len(hits) == 1, (name,marker,hits)
    return hits[0]

for kind, graphic in [('figure','rect(width: 30mm, height: 15mm)[FloatMarker]'),
                      ('table','table(columns: 1, [FloatMarker])')]:
    for placement in ('auto', 'top'):
        name = f'first-{kind}-{placement}'
        option = ', alt: "A test rectangle"' if kind == 'figure' else ''
        if placement == 'top': option += ', placement: top'
        compile(name, prefix+'''#show: revtex-preprint.with(title: [TitleMarker])
BodyMarker before the float.
#figure('''+graphic+', caption: [CaptionMarker]'+option+''') <f>
AfterMarker follows the float. Ref: @f.
''')
        page, floated = position(name, 'FloatMarker')
        assert page == 1 and floated['yMin'] > 600, (name,page,floated)
        assert position(name,'TitleMarker')[1]['yMax'] < floated['yMin'], name
        if placement == 'auto':
            placements = json.loads(run('typst','query',*base,str(root/(name+'.typ')),
                                        'figure','--field','placement'))
            assert placements == ['auto'], (name,placements)
        # Keeping the original figure/table must not duplicate native PDF tags.
        objects = json.loads(run('qpdf','--json',str(root/(name+'.pdf'))))['qpdf'][1]
        role = '/Figure' if kind == 'figure' else '/Table'
        assert sum(v.get('value',{}).get('/S') == role for v in objects.values()
                   if isinstance(v.get('value'),dict)) == 1, (name,role)

        name = f'later-{kind}-{placement}'
        compile(name, prefix+'''#show: revtex-preprint
FirstPageMarker
#pagebreak()
#counter(page).update(1)
LaterBodyMarker before the float.
#figure('''+graphic+', caption: [CaptionMarker]'+option+''')
''')
        page, floated = position(name,'FloatMarker')
        assert page == 2 and floated['yMin'] < position(name,'LaterBodyMarker')[1]['yMin'], (name,page,floated)

    name = f'deferred-{kind}'
    large = ('rect(width: 30mm, height: 100mm)[FloatMarker]' if kind == 'figure' else
             'table(columns: 1, [#block(height: 100mm)[FloatMarker]])')
    compile(name,prefix+'''#show: revtex-preprint
FirstPageMarker
#v(180mm)
#figure('''+large+''', caption: [CaptionMarker])
FollowingMarker
''')
    page, floated = position(name,'FloatMarker')
    assert page == 2 and floated['yMin'] < 120, (name,page,floated)

compile('auto-bottom',prefix+'''#show: revtex-preprint
FirstPageMarker
#pagebreak()
#v(150mm)
BottomBodyMarker
#figure(rect(width: 30mm, height: 10mm)[FloatMarker], caption: [CaptionMarker])
''')
page, floated = position('auto-bottom','FloatMarker')
assert page == 2 and floated['yMin'] > position('auto-bottom','BottomBodyMarker')[1]['yMax']+80
compile('inline-placement',prefix+'''#show: revtex-preprint
BeforeMarker
#figure(rect(width: 30mm, height: 10mm)[InlineMarker], caption: [CaptionMarker], placement: none)
AfterMarker
''')
assert position('inline-placement','BeforeMarker')[1]['yMax'] < position('inline-placement','InlineMarker')[1]['yMin']
assert position('inline-placement','InlineMarker')[1]['yMax'] < position('inline-placement','AfterMarker')[1]['yMin']
print('PASS: auto floats, first-page top exclusion, later top/bottom, deferral, explicit in-flow placement')

# Abstract has its own centered, body-sized label, separate from section style.
front_words = words('global-full')[0]
abstract_label = next(b for t,b in front_words if t == 'Abstract')
abstract_prose = next(b for t,b in front_words if t == 'AbstractMarker')
assert abs((abstract_label['xMin']+abstract_label['xMax'])/2 - 595.276/2) < 1
assert abs((abstract_label['yMax']-abstract_label['yMin']) -
           (abstract_prose['yMax']-abstract_prose['yMin'])) < 0.05

def margin_numbers(pages):
    return [int(t) for p in pages for t,b in sorted(p, key=lambda word: word[1]['yMin'])
            if t.isdigit() and b['xMax'] < 69]

def check_lines(name, enabled):
    pages = words(name)
    numbers = margin_numbers(pages)
    assert bool(numbers) == enabled, (name, numbers)
    if not enabled: return
    assert numbers == list(range(1,len(numbers)+1)), (name,numbers)
    # Margin numbers must stay visually subordinate to the 12pt prose.
    assert all(7.5 < b['yMax']-b['yMin'] < 8.5 for p in pages for t,b in p
               if t.isdigit() and b['xMax'] < 69), name
    for marker in ('AbstractMarker','BodyMarker','AfterMarker','AppendixMarker','Transport'):
        hits = [(p,b) for p in pages for t,b in p if t == marker]
        assert hits, (name,marker)
        assert any(any(t.isdigit() and b['xMax'] < 69 and abs((b['yMin']+b['yMax'])/2-(mb['yMin']+mb['yMax'])/2)<5 for t,b in p) for p,mb in hits), (name,marker)
    for marker in ('TitleMarker','UniversityMarker','LaboratoryMarker','KeywordMarker,','HeadingMarker',
                   'CaptionMarker','TableCaptionMarker','CellMarker','FootnoteMarker','AppendixHeadingMarker'):
        hits = [(p,b) for p in pages for t,b in p if t == marker]
        assert hits, (name,marker)
        assert all(not any(t.isdigit() and b['xMax'] < 69 and abs((b['yMin']+b['yMax'])/2-(mb['yMin']+mb['yMax'])/2)<5 for t,b in p) for p,mb in hits), (name,marker)
    # Display equations and contact paragraphs also remain outside the counter.
    for p in pages:
        for t,mb in p:
            if t.rstrip(';') in ('(1)', 'alice@example.org', '0000-0000-0000-0000'):
                assert not any(tn.isdigit() and b['xMax'] < 69 and abs((b['yMin']+b['yMax'])/2-(mb['yMin']+mb['yMax'])/2)<5 for tn,b in p), (name,t)
    # Bibliography is on page 2 and its lines continue the first page's counter.
    assert any(t.isdigit() and b['xMax']<69 for t,b in pages[1]), name

for name, args, enabled in [('read','',False), ('review','mode: "review",',True),
                            ('read-lines','line-numbers: true,',True),
                            ('review-no-lines','mode: "review", line-numbers: false,',False)]:
    compile(name, prefix+'#show: revtex-preprint.with(\n'+front+args+'\n)\n'+line_body)
    check_lines(name, enabled)
# Check actual rendered number color; styling par.line itself does not style
# the numbers generated by its numbering function.
compile('line-style', prefix+'#show: revtex-preprint.with(mode: "review")\nLineMarker\n')
run('typst','compile',*base,'--format','svg',str(root/'line-style.typ'),str(root/'line-style.svg'))
svg = ET.parse(root/'line-style.svg')
assert any(e.attrib.get('fill') == '#808080' for e in svg.iter()), 'missing gray line number'
# Explicit leading overrides both presets; compare actual line separations.
for name,args in [('read-gap',''), ('review-gap','mode: "review",'),
                  ('override-gap','mode: "review", leading: 0.65em,')]:
    compile(name,prefix+'#show: revtex-preprint.with('+args+')\nGapOne \\\nGapTwo\n')
def gap(name):
    p = words(name)[0]
    return next(b['yMin'] for t,b in p if t == 'GapTwo') - next(b['yMin'] for t,b in p if t == 'GapOne')
assert gap('review-gap') > gap('read-gap') + 3
assert abs(gap('override-gap')-gap('read-gap')) < 0.01
print('PASS: mode overrides, leading, continuous prose-only line numbers')

# Shared affiliation numbers disappear; multiple affiliations resolve to 1,2.
shared = prefix+'''#show: draft.with(title: "Plain title", authors: (
(name: "Alice", affiliations: ("uni",)), (name: "Bob", affiliations: ("uni",))),
affiliations: ((id: "uni", text: [Shared University]),))
Text.
'''
text=compile('shared',shared)
assert 'Alice and Bob' in text and not re.search(r'[12].*Shared University',text), text
multi_words=words('global-full')[0]
assert any(t=='1,2*' for t,b in multi_words), 'missing multiple affiliation superscripts'
text=compile('dated',prefix+'#show: revtex-preprint.with(date: datetime(year: 2026, month: 10, day: 16))\nDated prose.')
assert '2026-10-16' in text
assert '20261016' in run('qpdf','--json',str(root/'dated.pdf'))
compile('font',prefix+'#show: revtex-preprint.with(font: "Libertinus Serif")\n= Font test\nA different font. $ x = 1 $')
print('PASS: shared/multiple/no affiliations, alias, date, alternative font')

# Failures must be actionable diagnostics, not downstream crashes or swallowed errors.
invalid = [
 ('mode','mode: "typo"','mode must be'),
 ('equation-mode','equation-numbering: "typo"','equation-numbering must be'),
 ('date-time','date: datetime(hour: 12, minute: 0, second: 0)','date must include'),
 ('author-type','authors: ((name: 1,),)','author.name must be'),
 ('affiliation-type','affiliations: ((id: "x", text: "str"),)','affiliation.text must be'),
 ('duplicate-id','affiliations: ((id: "x", text: [X]), (id: "x", text: [X]))','duplicate affiliation id'),
 ('unused-id','affiliations: ((id: "x", text: [X]),)','unused affiliation id'),
 ('unknown-id','authors: ((name: "A", affiliations: ("x",)),)','unknown affiliation id'),
 ('refs-type','authors: ((name: "A", affiliations: "x"),)','author.affiliations must be'),
 ('corresponding-type','authors: ((name: "A", corresponding: "yes"),)','author.corresponding must be'),
 ('email','authors: ((name: "A", email: "broken"),)','invalid author.email'),
 ('orcid','authors: ((name: "A", orcid: "broken"),)','invalid author.orcid'),
]
for name,args,error in invalid:
    compile('invalid-'+name,prefix+'#show: revtex-preprint.with('+args+')\nText.',error)
for name,body,error in [
 ('before-section','$ x = 1 $','numbered level-1 heading first'),
 ('before-appendix','= Body\n$ x = 1 $\n#show: appendices\n$ y = 1 $','numbered level-1 heading first'),
 ('double-appendix','= Body\n#show: appendices\n= A\n#show: appendices\n= B','appendices may only be used once')]:
    compile('invalid-'+name,prefix+'#show: revtex-preprint.with(equation-numbering: "section")\n'+body,error)
print('PASS: input diagnostics and section/appendix boundaries')

# A normal document may change native supplements, float placement and CSL.
text=compile('native-overrides',prefix+'''#show: revtex-preprint
#set figure(supplement: [Diagram])
#set bibliography(style: "apa")
= Native configuration
#figure(rect(width: 20mm, height: 5mm), caption: [Top float], placement: top) <f>
#figure(table(columns: 1, [X]), caption: [Bottom float], placement: bottom, supplement: [Data]) <t>
NativeRefs: @f; @t. @sample
#bibliography("refs.bib")
''')
assert 'NativeRefs: Diagram 1; Data 1' in text and 'Example, 2025' in text, text
text=compile('caption-override',prefix+'''#show: revtex-preprint
#show figure.where(kind: table): set figure.caption(position: bottom)
#set figure.caption(separator: [ — ])
#figure(table(columns: 1, [CellMarker]), caption: [CaptionMarker])
''')
assert text.index('CellMarker') < text.index('CaptionMarker') and 'Table 1 — CaptionMarker' in text, text
# Every dependency must belong to the copied manuscript bundle; no repo files,
# packages or system fonts may be needed. The package directories stay empty.
deps=json.loads((root/'global-full.deps.json').read_text())['inputs']
assert {pathlib.Path(p).name for p in deps} == {'global-full.typ','revtex-preprint.typ','refs.bib'}, deps
assert all(pathlib.Path(p).resolve().is_relative_to(root) for p in deps),deps
assert not list((root/'packages').iterdir()) and not list((root/'cache').iterdir())
print('PASS: native configuration/CSL and isolated standalone dependencies')
print('All RevTeX preprint contracts passed.')
PY
