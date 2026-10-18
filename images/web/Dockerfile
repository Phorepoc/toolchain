# phorepoc-web: the browser engine build (WebKit / JavaScriptCore, curl, codecs) on top of phorepoc-base, for amd64/x32
# and ARM alike (the Arm GNU toolchain in the base image carries its own newlib + libstdc++).
ARG BASE=ghcr.io/phorepoc/base:latest
FROM ${BASE}
RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake ninja-build ruby perl python3 gperf pkg-config libicu-dev unifdef libc6-dev-x32 \
    && rm -rf /var/lib/apt/lists/*
