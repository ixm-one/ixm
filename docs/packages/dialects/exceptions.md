---
title: Exceptions
---

# Exceptions

This component allows users to enable or disable exceptions for C++ source
files within a target.

> [!IMPORTANT]
> This component is currently only supported under GCC, Clang, and MSVC for
> C++.

## Targets

`Dialects::Exceptions::Off` {#dialects-exceptions-off}
: Turns exception features *off* for a dependency.
: Compilers will typically generate an error if language features requiring
  exceptions are encountered. This can cause issues with `constexpr` or
  `consteval` code.

`Dialects::Exceptions::On` {#dialects-exceptions-on}
: Turns exception features *on* for a dependency.
