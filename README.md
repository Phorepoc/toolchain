# Phorepoc toolchain

Linux build images for [Phorepoc](https://github.com/Phorepoc), a modern build of the 2010 Symbian open-source
release for amd64 (QEMU, VirtualBox) and the PinePhone. Every Phorepoc repository builds inside these images, in CI
and on your machine, so all it needs on the host is Docker.

| Image | Contents |
|---|---|
| `ghcr.io/phorepoc/base` | Ubuntu 24.04; GCC 13 with the x32 runtime (`-mx32`), LLVM `lld`; **Arm GNU Toolchain 14.2.rel1** (`arm-none-eabi`); QEMU (x86), GRUB and ISO tools; the Symbian host tools (below) |
| `ghcr.io/phorepoc/arm` | `base` + ARM QEMU, Linux cross compilers, device-tree and U-Boot tools |
| `ghcr.io/phorepoc/web` | `base` + what the browser engine build needs (CMake, Ninja, Ruby, ICU ...) |
| `ghcr.io/phorepoc/mesa` | `arm` + Mesa's generator tools (meson, Mako, ...) |

## Symbian host tools

Built from the 2010 release's own source, **unmodified**, taken from the Phorepoc forks at the commits in
[`hosttools/sources.lock`](hosttools/sources.lock) ([`hosttools/build.sh`](hosttools/build.sh)):

- `rcomp`, the resource compiler (`oss.FCL.sftools.dev.build`), using the source's own Linux build switches. Its output
  is byte-identical to the Windows build.
- `mifconv`, the icon compiler (`oss.FCL.sf.mw.platformtools`).
- `svgtbinencode`, the SVG-T encoder (`oss.FCL.sf.mw.uitools`). This is the 32-bit Linux binary the release ships,
  used as it is.
- `uidcrc`, a small reimplementation of the UID-checksum tool `rcomp` calls.

The 1990s-era tools are 32-bit, so the image carries the i386 runtime.

## Use

```sh
docker run --rm -v "$PWD:/work" ghcr.io/phorepoc/base:latest <command>
```

Tags: `latest` and `sha-<commit>` from `main`; `X.Y.Z` from release tags `vX.Y.Z`. Pin a version in your own
repository for reproducible builds.

## Build locally

```sh
docker build -f images/base/Dockerfile -t phorepoc/base:dev .
docker build -f images/arm/Dockerfile  --build-arg BASE=phorepoc/base:dev -t phorepoc/arm:dev  images/arm
docker build -f images/web/Dockerfile  --build-arg BASE=phorepoc/base:dev -t phorepoc/web:dev  images/web
docker build -f images/mesa/Dockerfile --build-arg BASE=phorepoc/arm:dev  -t phorepoc/mesa:dev images/mesa
sh tests/smoke.sh phorepoc/base:dev
```

## Licence

[EPL-1.0](LICENSE), the licence of the Symbian release. Third-party tools in the images keep their own licences.
