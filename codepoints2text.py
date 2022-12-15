'''
cat a list of Unicode codepoints (one on each line, in U+XXXX
format) to get a string of actual text

'''

import sys

for line in sys.stdin:
    if line.startswith(('U+', 'u+')):
        _, hx = line.strip().split('+')
        n = int(hx, base=16)
        try:
            char = unichr(n)
            out = char.encode('utf-8')
        except NameError:
            out = chr(n)
    else:
        out = line
    try:
        sys.stdout.write(out)
    except UnicodeEncodeError as e:
        sys.stderr.write('\n' + str(e) + '\n')

print
