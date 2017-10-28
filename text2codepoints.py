'''
cat a string of text to get its Unicode codepoints
(one on each line, in U+XXXX format)

'''

import sys

for line in sys.stdin:
    for c in line.decode('utf-8').rstrip():
        cp = 'U+%06x' % ord(c)
        print(cp.encode('utf-8'))
