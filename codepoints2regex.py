r"""
Generate a regex character class representing the input.

cat a list of Unicode codepoints, one on each line in U+XXXX format. Unicode
literals will be in Python-style notation (\uXXXX, \UXXXXXXXX).
"""

import sys

is_javascript = 'js' in sys.argv


def _is_surrogate(codepoint):
    return 0xd800 <= codepoint and codepoint <= 0xdfff


ranges = []

for line in sys.stdin:
    _, hx = line.strip().split(maxsplit=1)[0].split('+')
    n = int(hx, base=16)
    if is_javascript and _is_surrogate(n):
        # Including surrogates gives false matches with JavaScript. A minimal
        # case is:
        #
        # /^[\udba1-\udbfe\udca1]$/u.test('\udc00') => true
        #
        # You would expect false, but \udbfe\udca1 is interpreted as \u{10f8a1}
        # so a much greater range is mistakenly covered.
        continue
    start, end = ranges[-1] if ranges else (None, None)
    if n - 1 == end:
        ranges[-1] = (start, n)
    else:
        ranges.append((n, n))

regex_ranges = []

# astral?
templates = ({True: r'\u{%x}', False: r'\u%04x'} if is_javascript
             else {True: r'\U%08x', False: r'\u%04x'})


for r in ranges:
    is_astral = any(n > 0xffff for n in r)
    tmpl = templates[is_astral]
    is_range = r[0] != r[1]
    if is_range:
        regex = '-'.join([tmpl % part for part in r])
    else:
        regex = tmpl % r[0]
    regex_ranges.append(regex)

print('[%s]' % ''.join(regex_ranges))
