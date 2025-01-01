---
title: Compiler Launchers
---

# Compiler Launchers

Compiler Launchers are used within CMake to pass the path to a given language's
compiler to an executable. This is *most often* used to pass a C or C++
compiler to a tool that can cache the build in some manner. This is *most
typically* used in conjunction with [`ccache`](https://ccache.dev) or
[`sccache`](https://github.com/mozilla/sccache).

IXM provides `find_package` files for *both* of these. See each section for
more information on each launcher.
