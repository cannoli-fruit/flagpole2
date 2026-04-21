#!/bin/sh

# Stop on error
set -e

# -----------------------------
# Defaults
# -----------------------------

OPT_LEVEL=0
OUT=a.out
EXTRA_LIBS=""
KEEP_TEMP=0
EMIT_IR=0

# Flagpole frontend
LANG_COMPILER="/usr/lib/flagpole/fpcc"

# -----------------------------
# Argument Parsing
# -----------------------------

SRC=""

while [ $# -gt 0 ]; do
    case "$1" in
        -O0|-O1|-O2|-O3)
            OPT_LEVEL=`echo "$1" | sed 's/-O//'`
            shift
            ;;
        -o)
            OUT="$2"
            shift 2
            ;;
        -l*|-L*)
            EXTRA_LIBS="$EXTRA_LIBS $1"
            shift
            ;;
        --keep-temp)
            KEEP_TEMP=1
            shift
            ;;
        --emit-ir)
            EMIT_IR=1
            shift
            ;;
        *)
            SRC="$1"
            shift
            ;;
    esac
done

if [ -z "$SRC" ]; then
    echo "Usage:"
    echo "  fpc source.fp [-O0|-O1|-O2|-O3] [-o output] [-l<lib>] [--emit-ir]"
    exit 1
fi

BASE=`basename "$SRC"`
NAME=`echo "$BASE" | sed 's/\.[^.]*$//'`

IR_FILE="$NAME.ll"
OBJ_FILE="$NAME.o"

# -----------------------------
# Frontend → LLVM IR
# -----------------------------

"$LANG_COMPILER" < "$SRC" > "$IR_FILE"

opt "-O$OPT_LEVEL" -S "$IR_FILE" -o "$IR_FILE.opt"
mv "$IR_FILE.opt" "$IR_FILE"

# -----------------------------
# Emit IR only mode
# -----------------------------

if [ "$EMIT_IR" -eq 1 ]; then
    echo "IR emitted -> $IR_FILE"
    exit 0
fi

# -----------------------------
# LLVM → Object
# -----------------------------

llc -filetype=obj "-O$OPT_LEVEL" "$IR_FILE" -o "$OBJ_FILE"

# -----------------------------
# Link
# -----------------------------

cc "$OBJ_FILE" $EXTRA_LIBS -o "$OUT"

echo "Build successful -> $OUT"

# -----------------------------
# Cleanup
# -----------------------------

if [ "$KEEP_TEMP" -eq 0 ]; then
    rm -f "$IR_FILE" "$OBJ_FILE"
fi
