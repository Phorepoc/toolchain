# phorepoc-mesa: Mesa's generator tools on top of phorepoc-arm. meson configures a host build of the pinned Mesa only
# to run its generators (NIR / glapi / format tables, GLSL parsers, Lima algebraic passes) and to emit
# compile_commands.json; each needed source file is then compiled for ARM Symbian. Ubuntu 24.04's meson is too old
# for current Mesa, so it comes from pip.
ARG BASE=ghcr.io/phorepoc/arm:latest
FROM ${BASE}
RUN apt-get update && apt-get install -y --no-install-recommends \
        ninja-build python3-pip python3-mako python3-yaml python3-packaging python3-ply \
        libdrm-dev pkg-config bison flex \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --break-system-packages 'meson==1.6.1'
