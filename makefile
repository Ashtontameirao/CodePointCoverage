ios_versions = 8.1 8.2 8.3 8.4 9.0 9.1 9.2 9.3 10.0 10.1 10.2 10.3 11.0 11.1 11.2 11.3 11.4 12.0
ios_latest = $(lastword $(ios_versions))
android_versions = 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28
android_latest = $(lastword $(android_versions))
combos = $(foreach av,$(android_versions),$(ios_versions:%=ios%-android$(av)))
combo_latest = ios$(ios_latest)-android$(android_latest)

all_regex =  $(combos:%=dist/%-common-regex.txt)
all_codepoints = $(combos:%=dist/%-common-codepoints.txt)
available_glyphs = $(ios_versions:%=work/ios%-glyphs-available.txt) \
	$(android_versions:%=work/android%-glyphs-available.txt)

ios ?= $(ios_latest)
android ?= $(android_latest)
combo = ios$(ios)-android$(android)

.PHONY: all default regex codepoints allRegex allCodepoints clean available

default: regex codepoints

regex: dist/$(combo)-common-regex.txt dist/$(combo)-common-codepoints.txt

codepoints: dist/$(combo)-common-codepoints.txt dist/$(combo)-common-codepoints.txt

all: allRegex allCodepoints

allRegex: $(all_regex)

allCodepoints: $(all_codepoints)

dist work:
	mkdir -p $@

clean:
	rm -rf dist work

ios%-glyphs.txt:
	mkdir -p $(@D)
	cd $(@D); curl -sLO https://dl.bintray.com/amake/generic/20170828/work/$(@F)

.PRECIOUS: work/ios%-glyphs-available.txt work/android%-glyphs-available.txt

available: $(available_glyphs)

work/ios%-glyphs-available.txt: work/ios%-glyphs.txt
	grep -vE "lastresort(template|privateplane16|privateuse)" $^ > $@

work/android%-glyphs-available.txt: | $(ANDROID_HOME)/platforms/android-% .env
	.env/bin/python list-ttf-chars.py $(firstword $|)/data/fonts/*.ttf > $@

.env:
	virtualenv .env
	.env/bin/pip install FontTools

define GEN_CODEPOINTS
dist/ios%-android$1-common-codepoints.txt: work/ios%-glyphs-available.txt \
	work/android$1-glyphs-available.txt | dist .env
	cat $$^ | \
		cut -d ' ' -f 1 | \
		sort | \
		uniq -d > $$@
endef

$(foreach av,$(android_versions),$(eval $(call GEN_CODEPOINTS,$(av))))

define GEN_REGEX
dist/ios%-android$1-common-regex.txt: dist/ios%-android$1-common-codepoints.txt | dist .env
	< $$^ .env/bin/python codepoints2regex.py > $$@
endef

$(foreach av,$(android_versions),$(eval $(call GEN_REGEX,$(av))))
