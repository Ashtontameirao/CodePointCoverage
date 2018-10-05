'''
cat a string of text to get its Unicode codepoints
(one on each line, in U+XXXX format)

'''

from __future__ import print_function
import sys

for line in sys.stdin:
    try:
        line = line.decode('utf-8')
    except AttributeError:
        pass
    for c in line.rstrip():
        cp = 'U+%06x' % ord(c)
        print(cp)
