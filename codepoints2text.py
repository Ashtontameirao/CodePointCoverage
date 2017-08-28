'''
cat a list of Unicode codepoints (one on each line, in U+XXXX
format) to get a string of actual text

'''

import sys

for line in sys.stdin:
    _, hx = line.strip().split('+')
    n = int(hx, base=16)
    char = unichr(n)
    sys.stdout.write(char.encode('utf-8'))

print
