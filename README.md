# Phorepoc toolchain

These are the Docker images every [Phorepoc](https://github.com/Phorepoc) repository is built in, both in CI and on your
own machine. That's why the only thing you need to install yourself is Docker.

- **`ghcr.io/phorepoc/base`** has everything for a PC build. That's Ubuntu 24.04, GCC 13 with x32 support, LLVM's
  linker, the Arm GNU Toolchain 14.2 for ARM, QEMU, the tools for bootable ISOs, and the Symbian tools described below.
- **`ghcr.io/phorepoc/arm`** adds ARM QEMU, Linux cross compilers and the device tree and U-Boot tools.
- **`ghcr.io/phorepoc/web`** adds what the WebKit build needs, such as CMake, Ninja, Ruby and ICU.
- **`ghcr.io/phorepoc/mesa`** adds Mesa's build tools, meson and Mako.

## The Symbian tools

A few tools from the 2010 release are needed to build Symbian at all, like the resource compiler. Nokia only ever
shipped most of them for Windows, so we build them from the release's own source, unchanged, at the commits in
[hosttools/sources.lock](hosttools/sources.lock).

- **`rcomp`** compiles resource files. Our Linux build gives exactly the same bytes as the Windows one.
- **`mifconv`** compiles icons.
- **`akn_skin_desc_compiler`** compiles skins. The release only had it for Windows. Its output matches the Windows
  build except for the package ID, which the compiler takes from the clock.
- **`uidcrc`** is a small rewrite of the UID checksum tool `rcomp` calls.

One tool is missing on purpose. The SVG icon encoder was only ever shipped as a binary, and the Linux one crashes on
current systems. The [pdk](https://github.com/Phorepoc/pdk) has a rewrite, `tools/svgtenc`, that produces the same
bytes.

The old tools are 32-bit, so the image includes the 32-bit runtime they need.

## Using them

```sh
docker run --rm -v "$PWD:/work" ghcr.io/phorepoc/base:latest <command>
```

`latest` and `sha-<commit>` are built from `main`, and every `vX.Y.Z` tag publishes `X.Y.Z`. Pin a version in your own
repository if you want builds you can repeat exactly.

## Building them yourself

```sh
docker build -f images/base/Dockerfile -t phorepoc/base:dev .
docker build -f images/arm/Dockerfile  --build-arg BASE=phorepoc/base:dev -t phorepoc/arm:dev  images/arm
docker build -f images/web/Dockerfile  --build-arg BASE=phorepoc/base:dev -t phorepoc/web:dev  images/web
docker build -f images/mesa/Dockerfile --build-arg BASE=phorepoc/arm:dev  -t phorepoc/mesa:dev images/mesa
sh tests/smoke.sh phorepoc/base:dev
```

## License

EPL-1.0, the license of the Symbian release. The other tools in the images keep their own licenses.
