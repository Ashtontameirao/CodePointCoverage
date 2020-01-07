# Code Point Coverage

These are tools for determining which Unicode code points are "available" in a
given environment. "Available" means that there is some font available that
provides a glyph for that code point, or in the case of non-printing characters
that the character is not considered "missing".

This is mostly interesting for mobile OSes where it is either impossible or very
cumbersome to add fonts.

## Methodology

Coverage is determined by inspecting the font files that are bundled with the
OS. If there is at least one font providing a glyph (more specifically, with an
entry in the `cmap` table) for a given codepoint, that codepoint is considered
"covered".

For iOS, the fonts are taken from the iOS Simulator runtimes bundled with
various versions of Xcode. For Android, the fonts are taken from the Android
Emulator system images downloadable with the Android SDK.

## Data

Raw glyph lists are available in [data](data).

These are the kinds of data that can be generated:

```sh
% make help
usage: make [target]

Available targets:
  regex                    Generate regex for latest iOS and Android versions
  decimal                  Generate glyphs for all platforms in decimal format
  dart                     Generate Dart regex for all platforms
  clean                    Clean temporary files
  avd-fonts                Dump fonts from a running Android Virtual Device
  help                     Show this help text
```

## Querying

The `cpc` script allows you to query the data.

```sh
% ./cpc
Usage: cpc COMMAND [ARGS...]

Commands:
    diff PLATFORM1 PLATFORM2
         List glyphs available in just one of the specified platforms, in
         U+xxxxxx format
    diffText PLATFORM1 PLATFORM2
         List glyphs available in just one of the specified platforms, as
         plain text
    available TEXT
         List the platforms on which all codepoints in the specified text are
         available
```

## Other Applications

[Is It Tofu?](https://tofu.mobi) is a web app based on this data that analyzes a
block of text and shows compatibility information for iOS and Android.

# License

MIT
