#!/usr/bin/env bash
for pdf in $(cat duplicates.txt)
do
    if [ -f $pdf ]; then rm $pdf; fi
    txt=${pdf/.pdf/.txt}
    if [ -f $txt ]; then rm $txt; fi
done
