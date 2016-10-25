'''
cat a list of Unicode codepoints (one on each line, in U+XXXX
format) to get a regex character class representing those characters
with contiguous ranges collapsed. Unicode literals will be in
Python-style notation (\uXXXX, \UXXXXXXXX).

'''

import sys

ranges = []

for line in sys.stdin:
    _, hx = line.strip().split('+')
    n = int(hx, base=16)
    start, end = ranges[-1] if ranges else (None, None)
    if n - 1 == end:
        ranges[-1] = (start, n)
    else:
        ranges.append((n, n))

regex_ranges = []

for r in ranges:
    range_tmpl = '\u%04x-\u%04x'
    char_tmpl = '\u%04x'
    if any(n > 0xffff for n in r):
        range_tmpl = '\U%08x-\U%08x'
        char_tmpl = '\U%08x'
    regex_ranges.append(range_tmpl % r if r[0] != r[1] else char_tmpl % r[0])

print('[%s]' % ''.join(regex_ranges))
