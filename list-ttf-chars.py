'''
Call this with TrueType font filename arguments to output a list of
all Unicode characters covered by all fonts, e.g.

list_ttf_chars.py $ANDROID_HOME/platforms/android-XY/data/fonts/*.ttf

Requires FontTools: https://pypi.python.org/pypi/FontTools
'''

import sys

from fontTools.ttLib import TTFont, TTCollection

chars = {}
for f in sys.argv[1:]:
    try:
        if f.endswith('.ttc'):
            fonts = TTCollection(f)
        else:
            fonts = [TTFont(f)]
        for font in fonts:
            for table in font['cmap'].tables:
                chars.update(table.cmap)
    except:
        print('Could not process arg:', f, file=sys.stderr)
        raise

for c, desc in sorted(chars.items()):
    print('U+%06x %s' % (c, desc))
