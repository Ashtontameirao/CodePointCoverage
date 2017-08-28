#!/bin/bash

cat $1 $2 | cut -d ' ' -f 1 | sort | uniq -u | python codepoints2text.py
