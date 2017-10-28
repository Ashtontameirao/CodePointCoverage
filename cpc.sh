#!/bin/bash

function diff() {
    f1=work/$1-glyphs-available.txt
    f2=work/$2-glyphs-available.txt
    make -s $f1 $f2
    cat $f1 $f2 | cut -d ' ' -f 1 | sort | uniq -u
}

function diffText() {
    diff $1 $2 | python codepoints2text.py
}

function available() {
    make -s available
    codepoints=$(echo $1 | python text2codepoints.py)
    result=$(_availableImpl $(echo a | python text2codepoints.py))
    for cp in $codepoints; do
        thisResult=$(_availableImpl $cp)
        result=$(echo $result $thisResult | tr ' ' '\n' | sort | uniq -d)
    done
    echo $result | tr ' ' '\n'
}

function _availableImpl() {
    for f in $(grep -l $1 work/*-available.txt); do
        f=${f##*/}
        f=${f%%-*}
        echo $f
    done
}

if [ -z "$1" ]; then
    cat <<EOF
Usage: $(basename $0) COMMAND [ARGS...]

Commands:
    diff PLATFORM1 PLATFORM2
         List codepoints available in just one of the specified platforms, in
         U+xxxxxx format
    diffText PLATFORM1 PLATFORM2
         List codepoints available in just one of the specified platforms, as
         plain text
    available TEXT
         List the platforms on which all codepoints in the specified text are
         available
EOF
fi

cmd=$1
shift
$cmd "$@"
