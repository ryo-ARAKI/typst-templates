#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
for tool in typst python3 pdftotext pdftoppm qpdf fish; do
  command -v "$tool" >/dev/null || { printf 'FAIL [environment] required command: %s\n' "$tool" >&2; exit 1; }
done
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/slide-outputs.XXXXXX")"
printf 'Artifacts: %s\n' "$tmp_dir"
python3 - "$repo_root" "$tmp_dir" <<'PY'
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

if sys.version_info < (3, 9):
    sys.exit('FAIL [environment] Python 3.9 or later is required')
repo, artifacts = map(Path, sys.argv[1:])
source = repo / 'examples/slide-outputs.typ'
epoch = '1792195200'


def check(ok, message):
    if not ok:
        raise AssertionError(message)


def run(args, *, name=None, **kwargs):
    result = subprocess.run(list(map(str, args)), capture_output=True, text=True, **kwargs)
    if name:
        (artifacts / (name + '.log')).write_text(result.stdout + result.stderr)
    return result


def passed(result, context):
    if re.search(r'failed to download|failed to fetch|network is unreachable|connection refused|'
                 r'certificate|permission denied|no space left on device|unknown font family', result.stderr, re.I):
        sys.exit(f'FAIL [environment] {context}: {result.stderr}; artifacts: {artifacts}')
    check(result.returncode == 0, f'{context}: {result.stderr}')
    return result.stdout


def evidence_path(pdf, suffix):
    try:
        relative = pdf.relative_to(artifacts)
    except ValueError:
        relative = Path(pdf.parent.name) / pdf.name
    return artifacts / ('inspect-' + str(relative.with_suffix('')).replace('/', '__') + suffix)


def texts(pdf):
    text = passed(run(['pdftotext', '-layout', pdf, '-']), str(pdf))
    evidence_path(pdf, '.txt').write_text(text)
    return text.rstrip('\f\n').split('\f')


equations = {}


def verify_pdf(pdf, mode):
    pages = texts(pdf)
    presentation = mode == 'presentation'
    check(len(pages) == (5 if presentation else 3), f'{mode}: page count')
    check('One source, three outputs' in pages[0], 'title')
    check([i + 1 for i, p in enumerate(pages) if 'Handout supplement:' in p] ==
          ([] if presentation else [2]), f'{mode}: supplement placement')
    for note in ('N1: Introduce the energy relation.', 'N2: Explain the final step.',
                 'N3: Compare with the earlier relation.'):
        check(all(note not in p for p in pages), f'{mode}: leaked note {note}')
    check(('Final step:' in pages[1]) == (not presentation), 'pause visibility')
    if presentation:
        check('Final step:' in pages[2], 'final A')
    # Display numbers sit alone at the right margin; reference numbers have words.
    numbers = [n for p in pages for n in re.findall(r' {10,}\((\d+)\)\s*$', p, re.M)]
    check(numbers == (['1', '1', '2', '2'] if presentation else ['1', '2']),
          f'{mode}: displayed equation numbers {numbers}')
    if mode not in equations:
        expression = '''query(math.equation.where(block: true)).filter(it => it.numbering != none).map(it => (
          number: std.numbering(it.numbering, ..counter(math.equation).at(it.location())),
          page: it.location().page(), x: it.location().position().x / 1pt,
          y: it.location().position().y / 1pt))'''
        result = run(['typst', 'eval', '--root', repo, '--creation-timestamp', epoch,
                      '--input', 'mode=' + mode, '--in', source, expression], name='query-' + mode)
        equations[mode] = json.loads(passed(result, 'equation query'))
        check([(e['number'], e['page']) for e in equations[mode]] ==
              ([('(1)', 2), ('(1)', 3), ('(2)', 4), ('(2)', 5)] if presentation else
               [('(1)', 2), ('(2)', 3)]), mode + ': public query numbers / physical pages')
        (artifacts / ('equations-' + mode + '.json')).write_text(json.dumps(equations[mode], indent=2))
    data = json.loads(passed(run(['qpdf', '--json', pdf]), 'qpdf'))
    evidence_path(pdf, '.qpdf.json').write_text(json.dumps(data, indent=2))
    objects = data['qpdf'][1]

    def deref(value):
        while isinstance(value, str) and 'obj:' + value in objects:
            value = objects['obj:' + value]['value']
        return value

    bbox = evidence_path(pdf, '.bbox.html')
    passed(run(['pdftotext', '-bbox', pdf, bbox]), 'bbox')
    xmlpages = ET.parse(bbox).findall('.//{*}page')
    refs = {p['object']: i + 1 for i, p in enumerate(data['pages'])}
    targets = {'(1)': 3 if presentation else 2, '(2)': 5 if presentation else 3}
    total = 0
    evidence = []
    for page_num, page in enumerate(data['pages'], 1):
        words = xmlpages[page_num - 1].findall('.//{*}word')
        visible_refs = []
        # Match each reference through its preceding marker, including repeats.
        for i, word in enumerate(words[:-1]):
            if word.text in ('Forward:', 'Again:', 'Backward:'):
                visible_refs.append(words[i + 1])
        annotations = [deref(a) for a in deref(page['object']).get('/Annots', [])]
        links = [a for a in annotations if a.get('/Subtype') == '/Link']
        check(len(links) == len(visible_refs), f'{mode} page {page_num}: reference links')
        height = float(xmlpages[page_num - 1].attrib['height'])
        for word in visible_refs:
            number = word.text.rstrip('.')
            a_pages = (2, 3) if presentation else (2,)
            check(number == ('(2)' if page_num in a_pages else '(1)'),
                  f'{mode} page {page_num}: forward/back/repeated reference must target the other equation')
            x = (float(word.attrib['xMin']) + float(word.attrib['xMax'])) / 2
            y = height - (float(word.attrib['yMin']) + float(word.attrib['yMax'])) / 2
            matches = [a for a in links if a['/Rect'][0] <= x <= a['/Rect'][2]
                       and a['/Rect'][1] <= y <= a['/Rect'][3]]
            check(len(matches) == 1, f'{mode}: annotation at reference word')
            dest = deref(matches[0].get('/Dest', matches[0].get('/A', {}).get('/D')))
            if isinstance(dest, str):
                # Typst uses named destinations in the PDF names tree.
                names = deref(deref(data['qpdf'][1]['trailer']['value']['/Root'])['/Names'])
                names = deref(names['/Dests'])
                def find_name(node):
                    node = deref(node)
                    entries = node.get('/Names', [])
                    for j in range(0, len(entries), 2):
                        if entries[j] == dest:
                            return deref(entries[j + 1])
                    for kid in node.get('/Kids', []):
                        found = find_name(kid)
                        if found is not None:
                            return found
                dest = find_name(names)
            if isinstance(dest, dict):
                dest = dest['/D']
            target = targets[number]
            check(dest is not None and refs[dest[0]] == target,
                  f'{mode}: {number} must point to physical page {target}: {dest}')
            target_words = xmlpages[target - 1].findall('.//{*}word')
            equation_number = [w for w in target_words if w.text == number and
                               float(w.attrib['xMin']) > float(xmlpages[target - 1].attrib['width']) * .8]
            check(len(equation_number) == 1, 'target equation number position')
            eq = equation_number[0]
            top = float(eq.attrib['yMin'])
            queried = next(e for e in equations[mode] if e['number'] == number and e['page'] == target)
            # Typst's XYZ includes a 10pt viewing margin above the target.
            # Match both the queried equation block and its visible number.
            check(dest[1] == '/XYZ' and dest[2] is not None and dest[3] is not None,
                  'equation XYZ destination')
            target_height = float(xmlpages[target - 1].attrib['height'])
            check(abs(target_height - dest[3] - top) < 12 and
                  abs(target_height - dest[3] - queried['y']) < 12 and
                  abs(dest[2] - queried['x']) < .5,
                  f'{mode}: destination must be at equation, not only correct page: {dest}, {eq.attrib}')
            evidence.append({'from_page': page_num, 'reference': word.text, 'destination': dest,
                             'target_page': target, 'queried_equation': queried, 'number_bbox': eq.attrib})
            total += 1
    check(total == (8 if presentation else 4), f'{mode}: all forward/back/repeated links ({total})')
    evidence_path(pdf, '.links.json').write_text(json.dumps(evidence, indent=2))
    print(f'PASS [semantic/link] {mode}: pages / text / equation numbers / destinations', flush=True)


def verify_metadata(path):
    data = json.loads(path.read_text())
    check(data['pdfpcFormat'] == 2 and len(data['pages']) == 5, 'presentation metadata size')
    for i, (label, overlay, notes) in enumerate([
        ('1', 0, []), ('1', 0, ['N1']), ('1', 1, ['N1', 'N2']),
        ('2', 0, ['N3']), ('2', 1, ['N3']),
    ]):
        p = data['pages'][i]
        check(p['idx'] == i and p['label'] == label and p['overlay'] == overlay, f'page {i}: identity')
        check(p['forcedOverlay'] == (overlay > 0) and p['hidden'] is False, f'page {i}: flags')
        note = p.get('note', '')
        check([n for n in ('N1', 'N2', 'N3') if n in note] == notes, f'page {i}: notes {note!r}')
    print('PASS [semantic] pdfpc physical pages / overlays / notes', flush=True)


try:
    check(source.is_file(), 'representative source missing: examples/slide-outputs.typ')
    for mode in ('default', 'presentation', 'handout'):
        pdf = artifacts / f'{mode}.pdf'
        args = ['typst', 'compile', '--root', repo, '--creation-timestamp', epoch]
        if mode != 'default':
            args += ['--input', 'mode=' + mode]
        passed(run(args + [source, pdf], name=mode), mode + ' compile')
        verify_pdf(pdf, 'presentation' if mode == 'default' else mode)
    check(texts(artifacts / 'default.pdf') == texts(artifacts / 'presentation.pdf'), 'default mode')
    for value in ('typo', ''):
        result = run(['typst', 'compile', '--root', repo, '--input', 'mode=' + value,
                      source, artifacts / 'invalid.pdf'], name='invalid-mode-' + (value or 'empty'))
        errors = '\n'.join(l for l in result.stderr.splitlines() if l.startswith('error:'))
        check(result.returncode != 0 and all(x in errors for x in ('mode', 'presentation', 'handout')),
              'invalid mode diagnostic')
    result = run(['typst', 'eval', '--root', repo, '--input', 'mode=presentation',
                  '--creation-timestamp', epoch, '--in', source, 'query(<pdfpc-file>).first().value'], name='metadata')
    metadata = artifacts / 'presentation.pdfpc'
    metadata.write_text(passed(result, 'metadata eval'))
    verify_metadata(metadata)
except (AssertionError, OSError, ValueError, KeyError, TypeError) as exc:
    sys.exit(f'FAIL [semantic/link] {exc}; artifacts: {artifacts}')
print('PASS: slide output source contracts (V1–V3)', flush=True)

# The real CLI is exercised from another cwd, then through bounded wrappers
# for failures that are otherwise timing-sensitive or require broken tools.
try:
    builder = repo / 'script/build-slide.sh'
    check(builder.is_file(), 'build entry missing: script/build-slide.sh')
    caller = artifacts / 'another cwd'
    caller.mkdir()
    external = artifacts / 'external root'
    external.mkdir()
    # A real mode-aware external manuscript with 2/1 pages proves the builder
    # has neither a repository-root assumption nor a five-page constraint.
    external_source = external / 'actual talk.typ'
    external_text = '''#let mode = sys.inputs.at("mode", default: "presentation")
#assert(mode in ("presentation", "handout"))
#set page(width: 300pt, height: 200pt)
External talk. #datetime.today().display()
#if mode == "presentation" { pagebreak(); [Second overlay.] }
#metadata((pdfpcFormat: 2, pages: range(if mode == "presentation" { 2 } else { 1 }).map(i => (idx: i,)))) <pdfpc-file>
'''
    external_source.write_text(external_text)
    env = os.environ.copy()
    env['SOURCE_DATE_EPOCH'] = epoch
    real_typst = shutil.which('typst')
    wrappers = artifacts / 'wrappers'
    wrappers.mkdir()
    trace = artifacts / 'calls.jsonl'
    wrapper = wrappers / 'typst'
    wrapper.write_text('#!' + sys.executable + '\n' + '''import json, os, pathlib, signal, subprocess, sys
args = sys.argv[1:]
with open(os.environ['TRACE'], 'a') as f:
    f.write(json.dumps(args) + '\\n')
fault = os.environ.get('FAULT', '')
if args == ['--version'] and fault in ('old', 'startup'):
    print('typst 0.14.2' if fault == 'old' else 'injected startup failure')
    sys.exit(0 if fault == 'old' else 1)
stage = args[0] if args else ''
mode = next((a for a in args if a.startswith('mode=')), '')
if (fault == 'presentation' and stage == 'compile' and mode == 'mode=presentation' or
    fault == 'handout' and stage == 'compile' and mode == 'mode=handout' or
    fault == 'eval' and stage == 'eval'):
    print('injected ' + fault + ' failure', file=sys.stderr)
    sys.exit(23)
if fault in ('interrupt', 'hangup') and stage == 'compile' and mode == 'mode=handout':
    os.kill(os.getppid(), signal.SIGTERM if fault == 'interrupt' else signal.SIGHUP)
    sys.exit(1)
result = subprocess.run([os.environ['REAL_TYPST']] + args)
if stage == 'eval' and result.returncode == 0 and fault.startswith('race-'):
    target = pathlib.Path(os.environ['RACE_TARGET'])
    kind = fault[5:]
    if kind in ('empty', 'nonempty'):
        target.mkdir()
        if kind == 'nonempty': (target / 'keep').write_text('KEEP')
    elif kind == 'file': target.write_text('KEEP')
    elif kind == 'symlink': target.symlink_to('absent-target')
sys.exit(result.returncode)
''')
    wrapper.chmod(0o755)
    env.update(PATH=str(wrappers) + os.pathsep + env['PATH'], TRACE=str(trace), REAL_TYPST=real_typst)
    sentinel = artifacts / '.build-slide-unrelated'
    sentinel.mkdir()
    (sentinel / 'keep').write_text('KEEP')

    def invoke(name, *, root=repo, src=source, output=None, args=None, extra=None, success=False):
        output = output if output is not None else artifacts / name
        case_env = dict(env, **(extra or {}))
        command = ['bash', builder] + (args if args is not None else ['--root', root, src, output])
        result = run(command, cwd=caller, env=case_env, name='build-' + name)
        if success:
            passed(result, name)
            stem = Path(src).stem
            check(sorted(p.name for p in output.iterdir()) == sorted([
                stem + '-presentation.pdf', stem + '-handout.pdf', stem + '-presentation.pdfpc']),
                name + ': exactly three outputs')
            check(epoch in result.stdout or 'SOURCE_DATE_EPOCH' in (extra or {}), name + ': timestamp report')
        else:
            check(result.returncode != 0 and result.stderr.strip(), name + ': nonzero with diagnostic')
            check('Created:' not in result.stdout, name + ': no success report')
            check(not output.exists() and not output.is_symlink(), name + ': no partial bundle')
        check(sorted(p.name for p in artifacts.glob('.build-slide-*')) == [sentinel.name],
              name + ': own temporary directory cleanup / unrelated preserved')
        check((sentinel / 'keep').read_text() == 'KEEP', 'unrelated temporary content')
        return result, output

    result, bundle = invoke('bundle', success=True)
    verify_pdf(bundle / 'slide-outputs-presentation.pdf', 'presentation')
    verify_pdf(bundle / 'slide-outputs-handout.pdf', 'handout')
    verify_metadata(bundle / 'slide-outputs-presentation.pdfpc')
    result, talk = invoke('external bundle', root='../external root', src='../external root/actual talk.typ',
                          output=artifacts / 'external bundle', success=True)
    check(len(texts(talk / 'actual talk-presentation.pdf')) == 2 and
          len(texts(talk / 'actual talk-handout.pdf')) == 1, 'external manuscript page counts')
    calls = [json.loads(line) for line in trace.read_text().splitlines()]
    calls = [c for c in calls if c[0] in ('compile', 'eval')]
    check([c[0] for c in calls] == ['compile', 'compile', 'eval'] * 2, 'sequential compile/compile/eval')
    for i, call in enumerate(calls):
        check(call[call.index('--creation-timestamp') + 1] == epoch, 'common timestamp')
        check('mode=' + ('handout' if i % 3 == 1 else 'presentation') in call, 'mode forwarding')
        check('--root' in call, 'explicit root forwarding')
    # Unset epoch: exactly one date call, used by all three Typst operations.
    date_trace = artifacts / 'date-calls'
    date_wrapper = wrappers / 'date'
    date_wrapper.write_text('#!/bin/bash\nprintf "called\\n" >> "$DATE_TRACE"\nprintf "1792195200\\n"\n')
    date_wrapper.chmod(0o755)
    unset_env = dict(env)
    unset_env.pop('SOURCE_DATE_EPOCH', None)
    before = len(trace.read_text().splitlines())
    result = run(['bash', builder, '--root', external, external_source, artifacts / 'clock bundle'],
                 cwd=caller, env=dict(unset_env, DATE_TRACE=str(date_trace)), name='build-clock')
    passed(result, 'unset epoch')
    check(date_trace.read_text() == 'called\n', 'start clock read once')
    clock_calls = [json.loads(l) for l in trace.read_text().splitlines()[before:]]
    check(all(c[c.index('--creation-timestamp') + 1] == epoch for c in clock_calls if c[0] != '--version'),
          'single captured clock forwarded')
    # Minimal PATH contains build dependencies, with no Python/PDF tools/exporter.
    minimal = artifacts / 'minimal-path'
    minimal.mkdir()
    for tool in ('bash', 'typst', 'realpath', 'dirname', 'basename', 'mktemp', 'mv', 'rm', 'date'):
        (minimal / tool).symlink_to(shutil.which(tool))
    invoke('minimal bundle', root=external, src=external_source, success=True, extra={'PATH': str(minimal)})
    print('PASS [build] V4: real CLI / external root / spaces / cwd / timestamp / minimal PATH', flush=True)

    for kind in ('empty', 'nonempty', 'file', 'symlink', 'live-symlink'):
        target = artifacts / ('existing-' + kind)
        if kind in ('empty', 'nonempty'):
            target.mkdir()
            if kind == 'nonempty': (target / 'keep').write_text('KEEP')
        elif kind == 'file': target.write_text('KEEP')
        else: target.symlink_to(sentinel if kind == 'live-symlink' else 'absent-target')
        result = run(['bash', builder, '--root', repo, source, target], env=env, name='existing-' + kind)
        check(result.returncode != 0 and 'exists' in result.stderr, kind + ': existing rejection')
        if 'symlink' in kind:
            check(target.is_symlink() and os.readlink(target) == (str(sentinel) if kind == 'live-symlink' else 'absent-target'),
                  kind + ': link preserved')
        elif kind == 'file': check(target.read_text() == 'KEEP', 'existing file preserved')
        else: check(sorted(p.name for p in target.iterdir()) == (['keep'] if kind == 'nonempty' else []), 'directory preserved')
    cases = [
        ('no-args', []), ('unknown', ['--unknown']), ('missing-root-value', ['--root']),
        ('missing-root', ['--root', artifacts / 'missing', source, artifacts / 'bad-root']),
        ('missing-source', ['--root', repo, repo / 'missing.typ', artifacts / 'bad-source']),
        ('outside-root', ['--root', external, source, artifacts / 'outside']),
        ('missing-parent', ['--root', repo, source, artifacts / 'no-parent/out']),
        ('extra-args', ['--root', repo, source, artifacts / 'extra', 'extra']),
    ]
    for name, args in cases:
        invoke(name, args=args)
    for i, value in enumerate(('', '-1', '1.5', 'tomorrow', '1\n2', '18446744073709551616', '253402300800')):
        result, _ = invoke('epoch-' + str(i), extra={'SOURCE_DATE_EPOCH': value})
        check('SOURCE_DATE_EPOCH' in result.stderr, 'epoch diagnosis')
    for fault in ('old', 'startup'):
        result, _ = invoke('dependency-' + fault, extra={'FAULT': fault})
        check('Typst' in result.stderr or 'typst' in result.stderr, 'dependency diagnosis')
    no_typst = artifacts / 'no-typst'
    no_typst.mkdir()
    for tool in minimal.iterdir():
        if tool.name != 'typst': (no_typst / tool.name).symlink_to(tool.resolve())
    result, _ = invoke('missing-typst', extra={'PATH': str(no_typst)})
    check('typst' in result.stderr.lower(), 'missing Typst diagnosis')
    print('PASS [build] V5: existing targets / inputs / dependencies / epoch', flush=True)

    for fault, expected in [('presentation', 'presentation compile'), ('handout', 'handout compile'),
                            ('eval', 'metadata eval'), ('interrupt', 'interrupted'), ('hangup', 'interrupted')]:
        result, _ = invoke('fault-' + fault, root=external, src=external_source, extra={'FAULT': fault})
        check(expected in result.stderr, fault + ': stage diagnosis')
    # Real Typst eval must reject malformed metadata; wrappers cannot bypass the
    # assertion expression under test. Each fixture is isolated under /tmp.
    for name, metadata_code in [
        ('missing', ''),
        ('multiple', '#metadata((pdfpcFormat: 2, pages: ((idx: 0,),))) <pdfpc-file>\n' * 2),
        ('format', '#metadata((pdfpcFormat: 1, pages: ((idx: 0,),))) <pdfpc-file>'),
        ('empty-pages', '#metadata((pdfpcFormat: 2, pages: ())) <pdfpc-file>'),
        ('idx-gap', '#metadata((pdfpcFormat: 2, pages: ((idx: 0,), (idx: 2,)))) <pdfpc-file>'),
        ('idx-float', '#metadata((pdfpcFormat: 2, pages: ((idx: 0.0,),))) <pdfpc-file>'),
        ('idx-bool', '#metadata((pdfpcFormat: 2, pages: ((idx: false,),))) <pdfpc-file>'),
        ('idx-missing', '#metadata((pdfpcFormat: 2, pages: ((label: "1",),))) <pdfpc-file>'),
        ('wrong-type', '#metadata("bad") <pdfpc-file>'),
    ]:
        invalid = external / (name + '.typ')
        invalid.write_text('Body.\n' + metadata_code)
        result, _ = invoke('metadata-' + name, root=external, src=invalid)
        check('metadata' in result.stderr, name + ': metadata diagnosis')
    for kind in ('empty', 'nonempty', 'file', 'symlink'):
        target = artifacts / ('race-' + kind)
        result = run(['bash', builder, '--root', external, external_source, target],
                     cwd=caller, env=dict(env, FAULT='race-' + kind, RACE_TARGET=str(target)), name='race-' + kind)
        check(result.returncode != 0 and 'finalize' in result.stderr, kind + ': finalize race diagnosis')
        if kind == 'symlink': check(target.is_symlink() and os.readlink(target) == 'absent-target', 'race link preserved')
        elif kind == 'file': check(target.read_text() == 'KEEP', 'race file preserved')
        else: check(sorted(p.name for p in target.iterdir()) == (['keep'] if kind == 'nonempty' else []), 'no directory nesting')
        check(sorted(p.name for p in artifacts.glob('.build-slide-*')) == [sentinel.name], 'race cleanup')
    mv = wrappers / 'mv'
    mv.write_text('#!/bin/bash\nprintf "injected Permission denied\\n" >&2\nexit 1\n')
    mv.chmod(0o755)
    result, _ = invoke('finalize-permission', root=external, src=external_source)
    check('finalize' in result.stderr and 'Permission denied' in result.stderr, 'finalize IO diagnosis')
    # A real read-only parent must fail before generating any completed output.
    readonly = artifacts / 'readonly'
    readonly.mkdir()
    readonly.chmod(0o555)
    try:
        if os.geteuid() != 0:
            result, _ = invoke('readonly-parent', root=external, src=external_source, output=readonly / 'out')
            check('temporary' in result.stderr, 'read-only parent diagnosis')
        else:
            sys.exit('FAIL [environment] read-only-parent check requires a non-root user')
    finally:
        readonly.chmod(0o755)
    print('PASS [build] V6: compile / eval / metadata / races / IO / signals / cleanup', flush=True)
    # Execute the published fish block verbatim and retain its mktemp location.
    readme = (repo / 'README.md').read_text()
    section = readme.split('### 同じ slide 原稿から発表版・配布版・pdfpc を生成する', 1)[1].split('\n### ', 1)[0]
    code = re.search(r'```fish\n(.*?)\n```', section, re.S).group(1)
    readme_script = artifacts / 'readme.fish'
    readme_script.write_text(code + '\nprintf "%s\\n" "$slide_output_parent"\n')
    result = run(['fish', readme_script], cwd=repo, name='readme-fish', env=os.environ.copy())
    output = passed(result, 'README fish commands')
    readme_parent = Path(output.splitlines()[-1])
    (artifacts / 'readme-artifacts.txt').write_text(str(readme_parent) + '\n')
    for mode in ('presentation', 'handout'):
        verify_pdf(readme_parent / ('slide-outputs-' + mode + '.pdf'), mode)
    verify_metadata(readme_parent / 'bundle/slide-outputs-presentation.pdfpc')
    help_text = passed(run(['bash', builder, '--help'], name='help'), 'help')
    for token in ('--root ROOT SOURCE.typ OUTPUT_DIR', 'presentation', 'handout', 'SOURCE_DATE_EPOCH', '0.15.0'):
        check(token in help_text and token in section, 'help / README contract: ' + token)
    result = run(['fish', '-c', 'bash script/build-slide.sh --root . examples/slide-outputs.typ ' +
                  "'" + str(readme_parent / 'bundle') + "'"], cwd=repo, name='readme-existing')
    check(result.returncode != 0 and 'exists' in result.stderr, 'README rerun diagnosis')
    print('PASS [build] V7: published fish commands / help / existing-output diagnosis', flush=True)
    # Render the real builder's bundle once; inspection files remain outside it.
    visual = artifacts / 'visual'
    visual.mkdir()
    for mode in ('presentation', 'handout'):
        pdf = bundle / ('slide-outputs-' + mode + '.pdf')
        passed(run(['pdftoppm', '-scale-to', '1100', '-png', pdf, visual / pdf.stem]), 'render ' + mode)
    check(len(list(bundle.iterdir())) == 3, 'inspection must preserve three-file bundle')
    print(f'MANUAL [visual] inspect all 5 presentation / 3 handout PNGs: {visual}', flush=True)
    print('PASS: slide output contracts (V1–V7; pdfpc UI remains optional)', flush=True)
except (AssertionError, OSError, ValueError, KeyError, TypeError, IndexError, AttributeError) as exc:
    sys.exit(f'FAIL [build] {exc}; artifacts: {artifacts}')
PY
