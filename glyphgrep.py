"""Search font files to find those containing a particular glyph."""

import re
import argparse
import pathlib

from fontTools.ttLib import TTFont, TTCollection


def _find_glyph(path, glyph):
    if path.suffix == '.ttc':
        fonts = TTCollection(path)
    else:
        fonts = [TTFont(path)]
    for n, font in enumerate(fonts):
        def _inspect():
            for table in font['cmap'].tables:
                if glyph in table.cmap:
                    return (n,
                            (table.platformID, table.platEncID),
                            table.cmap[glyph])
        result = _inspect()
        if result is not None:
            yield result


def _parse_codepoint(string):
    lower = string.lower()
    if lower.startswith('u+'):
        _, hex_part = lower.split('+')
        return int(hex_part, base=16)
    elif re.match(r'[0-9]+', lower):
        return int(lower)
    elif len(lower) == 1:
        return ord(lower)
    else:
        raise argparse.ArgumentTypeError(
            f'Could not interpret codepoint: {string}')


def _main():
    parser = argparse.ArgumentParser(
        description='Search font files for a glyph')
    parser.add_argument('--recursive', '-R', action='store_true')
    parser.add_argument('codepoint', type=_parse_codepoint)
    parser.add_argument('file', nargs='+')
    args = parser.parse_args()

    to_scan = []
    for path in args.file:
        path = pathlib.Path(path)
        if path.is_dir():
            if args.recursive:
                for ext in ['*.ttf', '*.otf', '*.ttc']:
                    to_scan.extend(path.rglob(ext))
            else:
                raise Exception(f'Path is not a file: {path}')
        elif path.is_file():
            to_scan.append(path)

    for path in to_scan:
        for font_num, flavor, description in _find_glyph(path, args.codepoint):
            flavor_txt = f'platformID {flavor[0]}; platEncId {flavor[1]}'
            if path.suffix == '.ttc':
                print(f'{path} (font {font_num}; {flavor_txt}):',
                      '{description}')
            else:
                print(f'{path} ({flavor_txt}): {description}')


if __name__ == '__main__':
    try:
        _main()
    except KeyboardInterrupt:
        pass
