#!/bin/sh
# build.sh <src-root> <out-dir> -- build the Symbian host tools from the 2010 source, unmodified, on Linux.
#   <src-root> holds the release packages as checked out from the Phorepoc forks:
#     oss.FCL.sftools.dev.build      (bintools/rcomp: the resource compiler)
#     oss.FCL.sf.mw.platformtools    (gfxconversion/mifconv: the icon compiler)
#     oss.FCL.sf.mw.uiresources      (skins/AknSkins: the skin descriptor compiler; its BRANCH_RCL_3, the version of the
#                                     skin descriptor the Phorepoc skin is built from)
#     oss.FCL.sf.os.deviceplatformrelease (bldcodeline.hrh: the platform's feature switches the skin compiler is built with)
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

# the skin descriptor compiler (AknSkinDescCompiler in the release, which ships it for Windows only). The source has its
# own Linux path; it is built with the platform's feature switches (RD_ENHANCED_SKINNING ...: without them it refuses
# scalable skins), the lower-case header name its source includes, and three headers older compilers pulled in
# implicitly. 32-bit like rcomp, with 64-bit file offsets: a 32-bit stat() fails on file systems with 64-bit inode
# numbers (container bind mounts), and the compiler would think every bitmap was missing.
K=$SRC/oss.FCL.sf.mw.uiresources/skins/AknSkins
CFG=$SRC/oss.FCL.sf.os.deviceplatformrelease/foundation_system/sf_config/config/inc/bldcodeline.hrh
mkdir -p "$OUT/.skininc"
cp "$SRC/oss.FCL.sf.mw.uiresources/uiresources_pub/skins_api/inc/AknsConstants.hrh" "$OUT/.skininc/aknsconstants.hrh"
# shellcheck disable=SC2046
g++ -m32 -D_FILE_OFFSET_BITS=64 -O2 -w -include cstring -include cstdlib -include ctime -include "$CFG" \
	-I"$K/sdcinc" -I"$K/inc" -I"$OUT/.skininc" -o "$OUT/akn_skin_desc_compiler" $(ls "$K"/sdcsrc/*.cpp)
rm -rf "$OUT/.skininc"
echo "akn_skin_desc_compiler built"
