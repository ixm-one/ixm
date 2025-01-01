---
title: Standard Library
---

# Standard Library

The `Library` component for the `Dialects` package provides a way to build a
C++ project without including the C++ standard library.

> [!TIP]
> It is safe to link against this library if you are not compiling C++. This
> library *only* affects C++ sources and C++ linkers.

## Targets

Unlike other components, this module provides only *one* target, which is to
force dependents to be built without compiling against or linking with the C++
standard library. It is not currently possible to "turn this on", due to
limitations with compiler and linker flags.

`Dialects::Library::Off` {#dialects-library-off}
: Forces a library's C++ source files to not compile with the C++ standard
  library available.
: Sets the linker to not link against the C++ standard library.
: > [!NOTE]
  > If the linker language used by your toolchain is *not* a C++ linker, this
  > target's linker flags will have *no* effect.
  > Examples of this use case include mixed-language tooling, such as compiling
  > C++ and Swift in the same library.
