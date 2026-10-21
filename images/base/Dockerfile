# phorepoc-base: everything a Phorepoc build needs on a Linux host.
#  - the amd64/x32 side: GCC 13 with the x32 runtime, LLVM's linker, QEMU (x86), GRUB + ISO tools
#  - the ARM side: Arm GNU Toolchain 14.2.rel1 (arm-none-eabi), checksum-verified
#  - the Symbian host tools, built from the 2010 source (hosttools/build.sh): rcomp, mifconv, uidcrc, akn_skin_desc_compiler
# Build context = the repository root:  docker build -f images/base/Dockerfile -t phorepoc-base .

FROM ubuntu:24.04 AS hosttools
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git g++-multilib \
    && rm -rf /var/lib/apt/lists/*
COPY hosttools/ /hosttools/
# the packages, each at its pinned commit, from the Phorepoc forks
RUN set -eu; grep -v '^#' /hosttools/sources.lock | while IFS="$(printf '\t')" read -r pkg commit; do \
        git init -q "/src/$pkg"; \
        git -C "/src/$pkg" fetch -q --depth 1 "https://github.com/Phorepoc/$pkg.git" "$commit"; \
        git -C "/src/$pkg" checkout -q FETCH_HEAD; \
    done \
    && sh /hosttools/build.sh /src /opt/symbian-hosttools

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends \
        build-essential g++-multilib libx32stdc++-13-dev libx32gcc-13-dev lld \
        libc6:i386 libstdc++6:i386 \
        python3 python3-fonttools python3-cryptography perl git ca-certificates curl xz-utils file \
        grub-pc-bin grub-common xorriso mtools qemu-system-x86 qemu-utils \
        gperf flex bison pkg-config libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Arm GNU Toolchain 14.2.rel1 (the compiler the ARM userland and kernel are built with)
ARG ARM_GNU=arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi
ARG ARM_GNU_SHA256=62a63b981fe391a9cbad7ef51b17e49aeaa3e7b0d029b36ca1e9c3b2a9b78823
RUN curl -fsSL -o /tmp/arm.tar.xz \
        "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/${ARM_GNU}.tar.xz" \
    && echo "${ARM_GNU_SHA256}  /tmp/arm.tar.xz" | sha256sum -c - \
    && mkdir -p /opt/arm-gnu && tar -xJf /tmp/arm.tar.xz -C /opt/arm-gnu --strip-components=1 \
    && rm /tmp/arm.tar.xz
ENV PATH=/opt/arm-gnu/bin:/opt/symbian-hosttools:$PATH \
    LD_LIBRARY_PATH=/opt/symbian-hosttools

COPY --from=hosttools /opt/symbian-hosttools /opt/symbian-hosttools
WORKDIR /work
