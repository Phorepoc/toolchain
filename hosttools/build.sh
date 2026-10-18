#!/bin/sh
# build.sh <src-root> <out-dir> -- build the Symbian host tools from the 2010 source, unmodified, on Linux.
#   <src-root> holds the release packages as checked out from the Phorepoc forks:
#     oss.FCL.sftools.dev.build      (bintools/rcomp: the resource compiler)
#     oss.FCL.sf.mw.platformtools    (gfxconversion/mifconv: the icon compiler)
#     oss.FCL.sf.mw.uitools          (svgtencoder: the shipped 32-bit Linux SVG-T encoder, used as it is)
# rcomp uses the source's own Linux switches (__LINUX__, __TOOLS2__); it is 1990s code that is not 64-bit clean, so
# it is built 32-bit (-m32). mifconv uses a C++03 idiom C++11 broke, so it is built as C++98; two headers older compilers pulled in implicitly are force-included.
set -eu
SRC=$1
OUT=$2
mkdir -p "$OUT"

R=$SRC/oss.FCL.sftools.dev.build/bintools/rcomp
srcs=""
for f in main.cpp ARRAY.CPP ASTRING.CPP CCODES.CPP CTABLE.CPP DATATYPE.CPP ERRORHAN.CPP FILEACC.CPP FILELINE.CPP \
	INDEXTAB.CPP LINKLIST.CPP MEM.CPP NAMEIDMA.CPP NUMVAL.CPP RCBINSTR.CPP RCOSTRM.CPP RCSCAN.CPP RCSTACK.CPP \
	RESOURCE.CPP STACK.CPP STRINGAR.CPP STRUCTST.CPP UNICODE_COMPRESSOR.CPP localise.cpp QUALIFAR.CPP messages.cpp \
	rcompl.cpp rcomp.cpp; do
	srcs="$srcs $R/src/$f"
done
# shellcheck disable=SC2086
g++ -m32 -O2 -w -fpermissive -D__LINUX__ -D__TOOLS2__ -I"$R/inc" -I"$R/src" -o "$OUT/rcomp" $srcs
echo "rcomp built"

gcc -O2 -w -o "$OUT/uidcrc" "$(dirname "$0")/uidcrc.c"
echo "uidcrc built"

M=$SRC/oss.FCL.sf.mw.platformtools/gfxconversion/mifconv
# shellcheck disable=SC2046
g++ -m32 -O2 -w -std=gnu++98 -D__LINUX__ -include cstring -include cstdlib -I"$M/inc" -o "$OUT/mifconv" $(ls "$M"/src/*.cpp)
echo "mifconv built"

E=$SRC/oss.FCL.sf.mw.uitools/svgtencoder/svgtenc/standalone
cp "$E/binary/svgtbinencode" "$OUT/svgtbinencode"
cp "$E/lib_linux/libxercesenc-c.so.28" "$OUT/"
chmod +x "$OUT/svgtbinencode"
echo "svgtbinencode installed (shipped 32-bit binary + its xerces library)"
