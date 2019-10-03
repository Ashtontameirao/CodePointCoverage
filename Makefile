ios_versions := $(addprefix ios,8.1 8.2 8.3 8.4 9.0 9.1 9.2 9.3 10.0 10.1 10.2 10.3 11.0 11.1 11.2 11.3 11.4 12.0 12.1 12.2 12.3 12.4 13.0 13.1 13.2)
ios_latest := $(lastword $(ios_versions))
android_versions := $(addprefix android,2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29)
all_versions := $(ios_versions) $(android_versions)
android_latest := $(lastword $(android_versions))
combos := $(foreach _,$(android_versions),$(addsuffix -$(_),$(ios_versions)))
combo_latest := $(ios_latest)-$(android_latest)

bintray_version := 20181031
ifneq ($(wildcard .bintray),)
	include .bintray
	export
endif

combo_regex := $(combos:%=work/%-common-regex.txt)
single_regex := $(all_versions:%=work/%-regex.txt)
all_regex := $(combo_regex) $(single_regex)
all_glyphs := $(combos:%=work/%-common-glyphs.txt)
raw_glyphs := $(ios_versions:%=work/%-glyphs.txt)
available_glyphs := $(all_versions:%=work/%-glyphs-available.txt)
tarballs := $(available_glyphs:%=%.tar.gz) $(raw_glyphs:%=%.tar.gz)
distfiles := $(all_regex) $(all_glyphs)

ios ?= $(ios_latest)
android ?= $(android_latest)
combo := $(ios)-$(android)

.PHONY: default
default: ## Generate regex, glyphs for latest iOS and Android versions
default: regex glyphs

.PHONY: regex
regex: ## Generate regex for latest iOS and Android versions
regex: work/$(combo)-common-regex.txt

.PHONY: glyphs
glyphs: ## Generate glyphs for latest iOS and Android versions
glyphs: work/$(combo)-common-glyphs.txt

.PHONY: all
all: ## Generate regex and glyphs for all OS combinations
all: allRegex allGlyphs

.PHONY: allRegex
allRegex: ## Generate regex for all OS combinations
allRegex: $(all_regex)

.PHONY: allGlyphs
allGlyphs: ## Generate glyphs for all OS combinations
allGlyphs: $(all_glyphs)

dist work:
	mkdir -p $(@)

.PHONY: clean
clean: ## Clean temporary files
clean:
	rm -rf dist work

ios%-glyphs.txt:
	mkdir -p $(@D)
	cd $(@D); curl -sL \
		https://dl.bintray.com/amake/generic/$(bintray_version)/work/$(@F).tar.gz | \
		tar xvz > $(@F)

.PRECIOUS: work/%-glyphs-available.txt

.PHONY: available
available: ## Generate list of present glyphs for the current iOS version
available: $(available_glyphs)

.PHONY: iosGlyphs
iosGlyphs: ## Get full list of glyphs for the current iOS version
iosGlyphs: $(ios_versions:%=work/%-glyphs.txt)

.PHONY: tarballs
tarballs: ## Generate tarballs of iOS glyphs files for Bintray caching
tarballs: $(tarballs)

empty :=
space := $(empty) $(empty)
delim := ,
define BINTRAY_PUSH
curl -T "{$(subst $(space),$(delim),$(1))}" \
	-u$$BINTRAY_USER:$$BINTRAY_KEY \
	https://api.bintray.com/content/$$BINTRAY_USER/generic/CodePointCoverage/$(bintray_version)/$(bintray_version)/$(2)/
endef

.PHONY: publish
publish: ## Publish tarballs and distfiles to Bintray
publish: $(tarballs) $(distfiles)
	$(call BINTRAY_PUSH,$(tarballs),work)
	$(call BINTRAY_PUSH,$(distfiles),dist)

work/%.tar.gz: work/%
	cd $(@D); tar zcvf $(@F) $(^F)

ios%-glyphs-available.txt: ios%-glyphs.txt
	grep -vE "lastresort(template|privateplane16|privateuse)|\(failed to get glyph name\)" $(^) > $(@)

android%-glyphs-available.txt: | $(ANDROID_HOME)/platforms/android-% .env
	.env/bin/python list-ttf-chars.py $(firstword $(|))/data/fonts/*.ttf > $(@)

.env:
	virtualenv .env
	.env/bin/pip install FontTools

define GEN_GLYPHS
%-$(1)-common-glyphs.txt: %-glyphs-available.txt \
	$(1)-glyphs-available.txt | dist .env
	cat $$(^) | \
		cut -d ' ' -f 1 | \
		sort | \
		uniq -d > $$(@)
endef

$(foreach _,$(android_versions),$(eval $(call GEN_GLYPHS,$(_))))

%-regex.txt: %-glyphs-available.txt | .env
	< $(^) .env/bin/python codepoints2regex.py > $(@)


.PHONY: help
help: ## Show this help text
	$(info usage: make [target])
	$(info )
	$(info Available targets:)
	@awk -F ':.*?## *' '/^[^\t].+?:.*?##/ \
         {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
