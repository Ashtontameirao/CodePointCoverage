#!/bin/bash

set -euo pipefail

mkdir -p work
mkdir -p done

if [[ ! -d env ]]; then
    virtualenv env
    env/bin/pip install fonttools
fi

for IOS_GLYPHS in work/ios*-glyphs.txt; do
    echo "Filtering ${IOS_GLYPHS#work/}"
    grep -vE "lastresort(template|privateplane16|privateuse)" $IOS_GLYPHS > ${IOS_GLYPHS%.txt}-available.txt
done

for ANDROID_PLATFORM in $ANDROID_HOME/platforms/android-*; do
    PLATFORM_NAME=$(basename $ANDROID_PLATFORM)
    echo "Extracting $PLATFORM_NAME"
    OUTFILE=work/$(echo $PLATFORM_NAME | sed -e 's/-//g')-glyphs-available.txt
    env/bin/python list-ttf-chars.py $ANDROID_PLATFORM/data/fonts/*.ttf > $OUTFILE
done

for IOS_GLYPHS in work/ios*-glyphs-available.txt; do
    for ANDROID_GLYPHS in work/android*-glyphs-available.txt; do
        IOS_VER=$(basename ${IOS_GLYPHS%-glyphs-available.txt})
        ANDROID_VER=$(basename ${ANDROID_GLYPHS%-glyphs-available.txt})
        PLATFORMS=$IOS_VER-$ANDROID_VER
        echo "Outputting $PLATFORMS"
        cat $IOS_GLYPHS $ANDROID_GLYPHS \
            | cut -d ' ' -f 1 \
            | sort \
            | uniq -d \
            | tee done/$PLATFORMS-common-glyphs.txt \
            | env/bin/python glyphs2regex.py > done/$PLATFORMS-common-regex.txt
    done
done
