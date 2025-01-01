---
title: RTTI
next:
  text: Doxygen
  link: /packages/doxygen
---

# RTTI

This component allows users to enable or disable Run-Time Type Information for
C++ source files within a library.

> [!IMPORTANT]
> This component is only supported under GCC, Clang, and MSVC for C++.

## Interactions

This component can interact with the [`Exceptions`](./exceptions) component in
a surprising way. If RTTI is disabled, and Exceptions are enabled, runtime type
information is still generated for exceptions. This is a necessary requirement
by many compilers. To ensure that your project does not generate any runtime
type information, it is recommended to disable *both* RTTI and Exceptions.

## Targets

`Dialects::RTTI::Off` {#dialects-rtti-off}
: Turns RTTI code generation (including language features, such as `typeid` and
  `dynamic_cast`) *on* for a dependency.
: Compilers will typically generate an error if language features requiring
  RTTI are encountered.
: > [!TIP]
  > If `Dialects::Exceptions::On` is set, runtime type information *might still
  > be generated* due to C++ runtime implementation requirements. To ensure
  > that  your project does not generate *any* runtime type information in any
  > situation, it is recommended to disable *both* RTTI *and* Exceptions.

`Dialects::RTTI::On` {#dialects-rtti-on}
: Turns RTTI code generation (including language features, such as `typeid` and
  `dynamic_cast`) *on* for a dependency.
: > [!TIP]
  > If `Dialects::Exceptions::Off` is set, `dynamic_cast<T&>` calls will most
  > likely generate a compiler error.
