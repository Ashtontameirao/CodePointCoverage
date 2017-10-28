# Code Point Coverage

These are tools for determining which Unicode code points are "available" in a given environment. "Available" means that there is some font available that provides a glyph for that code point, or in the case of non-printing characters that the character is not considered "missing".

This is mostly interesting for mobile OSes where it is either impossible or very cumbersome to add fonts.

The output includes:

1. A list of available code points for each platform
2. A list of code points available on all platforms (the intersection of #1)
3. A Python-style (using 8-digit `\U` literals) regex matching #2

Pre-calculated output covering iOS 8.1–10.1 and Android SDK 7–25 is [available on Bintray](https://bintray.com/amake/generic/CodePointCoverage/1.0#files).

# Supported systems

Tools for iOS and Android are currently available.

# Requirements

- Running the iOS app requires iOS 8 or later
- Building the iOS app requires a Mac with Xcode 8 or later
- Python 2.7 or later (a "wide" build is required to make full use of the regex output)

# How To

## iOS Preparation

Pre-compiled data for iOS is available on Bintray and will be downloaded automatically as needed. To gather the data yourself, follow these instructions

1. Install and launch the GlyphTester app to a supported physical device or simulator
2. Tap the Go button
3. A sharing sheet will appear; send the file to yourself via AirDrop, etc.
  - On the simulator, look for a log message indicating the path to the file on your local machine, and copy it from there
4. Put the resulting `ios*-glyphs.txt` file in the `work` directory at the root of this repo

## Android Preparation

1. Install the Android SDK; make sure the `ANDROID_HOME` environment variable is set correctly
2. Use the Android SDK manager to install the "SDK Platform" package for all SDK versions you wish to analyze

## Creating the Output

1. Run `make` from the root of the repo to output common codepoints and regex for the latest platform versions. Results are in `dist`.
2. Run `make android=x ios=y` to specify the platform versions
3. Run `make all` to generate common codepoints and regex for all combinations of platforms (this takes a while; consider running it in parallel with e.g. `-j$(sysctl -n hw.ncpu)`).

## Querying the Output

The `cpc.sh` script allows you to query the data for the following. Run it without arguments to see help.

- `diff`: List codepoints differing in availability between two platforms, in `U+xxxxxx` format
- `diffText`: Same as `diff`, but the output is plain text
- `available`: List platforms on which all codepoints in some text are available

# License

MIT
