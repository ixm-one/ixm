---
title: Math
---

Multiple C++ compilers provide several types of *floating point math dialects*.
The most famous of these is so-called *fast math*, which sometimes violates the
IEEE754 specification, but at the cost of improved runtime operations.

## Targets

`Dialects::Math::Precise`
: This dialect of floating point math operations is the default set of rules.
: > [!NOTE]
  > Due to limitations with the command line interface, this target can only be
  > used with Clang and MSVC. GCC does not currently provide an interface for
  > this feature.

`Dialects::Math::Strict`
: This dialect of floating point math operations enables strict rules regarding
  the IEEE754 specification, and typically raises floating point exceptions as
  soon as they occur.
: > [!NOTE]
  > This target has no effect on targets that use GCC.

`Dialects::Math::Fast`
: This dialect of floating point math turns on fast math optimizations for a
  given target.
: To keep behavior equivalent across all major compilers, the `__FAST_MATH__`
  macro is defined when using this target.
: > [!NOTE]
  > It is safe to link against this target even if you are not using C++, as it
  > currently only affects C++ source files.
