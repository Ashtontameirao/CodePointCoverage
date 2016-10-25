'''
Call this with TrueType font filename arguments to output a list of
all Unicode characters covered by all fonts, e.g.

list_ttf_chars.py $ANDROID_HOME/platforms/android-XY/data/fonts/*.ttf

Requires FontTools: https://pypi.python.org/pypi/FontTools
'''

import sys

from fontTools.ttLib import TTFont
from fontTools.unicode import Unicode

chars = {}
for f in sys.argv[1:]:
    for table in TTFont(f)['cmap'].tables:
        chars.update(table.cmap)

print('\n'.join(['U+%06x %s' % (c, desc)
                 for c, desc in sorted(chars.items())]))

