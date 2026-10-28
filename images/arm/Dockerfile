# phorepoc-arm: the ARM side on top of phorepoc-base -- ARM QEMU (the `virt` machine runs the board's
# kernel), the Linux cross compilers some boot pieces use, device-tree and U-Boot tools.
ARG BASE=ghcr.io/phorepoc/base:latest
FROM ${BASE}
RUN apt-get update && apt-get install -y --no-install-recommends \
        qemu-system-arm \
        g++-arm-linux-gnueabihf gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
        device-tree-compiler u-boot-tools \
    && rm -rf /var/lib/apt/lists/*
