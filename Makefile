ios_versions = 8.1 8.2 8.3 8.4 9.0 9.1 9.2 9.3 10.0 10.1 10.2 10.3 11.0 11.1 11.2 11.3 11.4 12.0 12.1 12.2
ios_latest = $(lastword $(ios_versions))
android_versions = 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
android_latest = $(lastword $(android_versions))
combos = $(foreach av,$(android_versions),$(ios_versions:%=ios%-android$(av)))
combo_latest = ios$(ios_latest)-android$(android_latest)

bintray_version = 20181031
ifneq ($(wildcard .bintray),)
	include .bintray
	export
endif

all_regex =  $(combos:%=dist/%-common-regex.txt)
all_codepoints = $(combos:%=dist/%-common-codepoints.txt)
raw_glyphs = $(ios_versions:%=work/ios%-glyphs.txt)
available_glyphs = $(ios_versions:%=work/ios%-glyphs-available.txt) \
	$(android_versions:%=work/android%-glyphs-available.txt)
tarballs = $(available_glyphs:%=%.tar.gz) $(raw_glyphs:%=%.tar.gz)
distfiles = $(all_regex) $(all_codepoints)

ios ?= $(ios_latest)
android ?= $(android_latest)
combo = ios$(ios)-android$(android)

.PHONY: default
default: ## Generate regex, codepoints for latest iOS and Android versions
default: regex codepoints

.PHONY: regex
regex: ## Generate regex for latest iOS and Android versions
regex: dist/$(combo)-common-regex.txt dist/$(combo)-common-codepoints.txt

.PHONY: codepoints
codepoints: ## Generate codepoints for latest iOS and Android versions
codepoints: dist/$(combo)-common-codepoints.txt dist/$(combo)-common-codepoints.txt

.PHONY: all
all: ## Generate regex and codepoints for all OS combinations
all: allRegex allCodepoints

.PHONY: allRegex
allRegex: ## Generate regex for all OS combinations
allRegex: $(all_regex)

.PHONY: allCodepoints
allCodepoints: ## Generate codepoints for all OS combinations
allCodepoints: $(all_codepoints)

dist work:
	mkdir -p $@

.PHONY: clean
clean: ## Clean temporary files
clean:
	rm -rf dist work

ios%-glyphs.txt:
	mkdir -p $(@D)
	cd $(@D); curl -sL \
		https://dl.bintray.com/amake/generic/$(bintray_version)/work/$(@F).tar.gz | \
		tar xvz > $(@F)

.PRECIOUS: work/ios%-glyphs-available.txt work/android%-glyphs-available.txt

.PHONY: available
available: ## Generate list of present glyphs for the current iOS version
available: $(available_glyphs)

.PHONY: iosGlyphs
iosGlyphs: ## Get full list of glyphs for the current iOS version
iosGlyphs: $(ios_versions:%=work/ios%-glyphs.txt)

.PHONY: tarballs
tarballs: ## Generate tarballs of iOS glyphs files for Bintray caching
tarballs: $(tarballs)

empty :=
space := $(empty) $(empty)
delim := ,
define BINTRAY_PUSH
curl -T "{$(subst $(space),$(delim),$1)}" \
	-u$$BINTRAY_USER:$$BINTRAY_KEY \
	https://api.bintray.com/content/$$BINTRAY_USER/generic/CodePointCoverage/$(bintray_version)/$(bintray_version)/$2/
endef

.PHONY: publish
publish: ## Publish tarballs and distfiles to Bintray
publish: $(tarballs) $(distfiles)
	$(call BINTRAY_PUSH,$(tarballs),work)
	$(call BINTRAY_PUSH,$(distfiles),dist)

work/%.tar.gz: work/%
	cd $(@D); tar zcvf $(@F) $(^F)

work/ios%-glyphs-available.txt: work/ios%-glyphs.txt
	grep -vE "lastresort(template|privateplane16|privateuse)|\(failed to get glyph name\)" $^ > $@

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

.PHONY: help
help: ## Show this help text
	$(info usage: make [target])
	$(info )
	$(info Available targets:)
	@awk -F ':.*?## *' '/^[^\t].+?:.*?##/ \
         {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
