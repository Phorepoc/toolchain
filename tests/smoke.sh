#!/bin/sh
# smoke.sh <base-image> -- the base image's tools start and do real work: compilers for both targets, the linker, and
# a round trip through the Symbian resource compiler (rcomp -> uidcrc).
set -eu
IMG=$1
docker run --rm -i "$IMG" sh -eu <<'EOF'
arm-none-eabi-g++ --version | head -1
echo 'int f(int a){return a*2;}' > /tmp/t.cpp
arm-none-eabi-g++ -mcpu=arm1136jf-s -c /tmp/t.cpp -o /tmp/t_arm.o
g++ -mx32 -c /tmp/t.cpp -o /tmp/t_x32.o
file /tmp/t_arm.o /tmp/t_x32.o
ld.lld --version
mkdir -p /tmp/r && cd /tmp/r
cat > t.rss <<'RSS'
STRUCT TEST { WORD value; LTEXT name; }
RESOURCE TEST r_test { value = 42; name = "phorepoc"; }
RSS
rcomp -u -ot.rsc -ht.rsg -st.rss -it.rss
test -s t.rsc && grep -q R_TEST t.rsg
od -An -tx1 t.rsc | head -2
mifconv 2>&1 | grep -q Mifconv
akn_skin_desc_compiler 2>&1 | grep -qi "skin"
echo "smoke: OK"
EOF
