#!/usr/bin/env bash

# Check dependencies

# UNIX tools (assuming command & echo exist)
if ! command -v comm &>/dev/null; then echo "Please install 'comm'"; exit 1; fi
if ! command -v cut  &>/dev/null; then echo "Please install 'cut'";  exit 1; fi
if ! command -v find &>/dev/null; then echo "Please install 'find'"; exit 1; fi
if ! command -v grep &>/dev/null; then echo "Please install 'grep'"; exit 1; fi
if ! command -v rm   &>/dev/null; then echo "Please install 'rm'";   exit 1; fi
if ! command -v sort &>/dev/null; then echo "Please install 'sort'"; exit 1; fi
if ! command -v trap &>/dev/null; then echo "Please install 'trap'"; exit 1; fi
if ! command -v uniq &>/dev/null; then echo "Please install 'uniq'"; exit 1; fi
if ! command -v wc   &>/dev/null; then echo "Please install 'wc'";   exit 1; fi

# 3rd party
if ! command -v pdftotext &>/dev/null; then echo "Please install 'pdftotext' or 'poppler-utils'"; exit 1; fi

# Cleanup
TMPFILE=$(mktemp)
function cleanup {
    if [ -f $TMPFILE ]; then rm $TMPFILE; fi
}
trap cleanup ERR EXIT

# Find all pdfs
LIST=$(find . | grep pdf | sort -r)
ARRAY=($LIST)

# Linear algorithm to convert every pdf to text
for pdf in $LIST
do
    txt=${pdf/.pdf/.txt}
    if [ -f "$txt" ]; then continue; fi

    echo "Converting '$pdf' => '$txt'..."

    # Converts only the first page, may be not a good idea?
    pdftotext -q -nodiag -f 1 -l 1 -cropbox $pdf $txt
done

# Quadratic algorithm
for i in $(seq $((${#ARRAY[@]}-1)))
do
    FIRSTPDF="${ARRAY[$i]}"
    if ! [ -f "$FIRSTPDF" ]; then continue; fi

    FIRSTTXT=${FIRSTPDF/.pdf/.txt}

    # The number of lines in the first pdf
    A=$(wc -l "$FIRSTTXT" | cut -w -f 2)

    if [ $A -eq 0 ]; then continue; fi

    for j in $(seq $((i+1)) ${#ARRAY[@]})
    do
        SECONDPDF="${ARRAY[$j]}"
        if ! [ -f "$SECONDPDF" ]; then continue; fi

        SECONDTXT=${SECONDPDF/.pdf/.txt}

        # The number of lines in the second pdf
        B=$(wc -l "$SECONDTXT" | cut -w -f 2)

        if [ $B -eq 0 ]; then continue; fi

        # The number of common lines
        C=$(comm -12 "$FIRSTTXT" "$SECONDTXT" | wc -l | cut -w -f 2)

        MAX=$((A > B ? A : B))
        C=$((C > MAX ? MAX : C))

        SIM=$((100 * C / MAX))
        if [ $SIM -gt 30 ]
        then
            echo "$FIRSTPDF ~ $SECONDPDF by ${SIM}%"
            echo "$SECONDPDF" >> $TMPFILE
        fi
    done
done
sort -r $TMPFILE | uniq > duplicates.txt

DUP=$(wc -l duplicates.txt | cut -w -f 2)
echo "# PDFs       = ${#ARRAY[@]}"
echo "# Duplicates = $DUP"
