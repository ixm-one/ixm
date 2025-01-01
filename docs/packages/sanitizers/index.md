---
title: Sanitizer
---

# Sanitizer

IXM provides a `Sanitizer` package that allows users to link against an
`IMPORTED` `INTERFACE` library to enable compiler runtime sanitizers, such as
<abbr title="Address Sanitizer">ASan</abbr>, <abbr title="Undefined Behavior
Sanitizer">UBSan</abbr>, <abbr title="Thread Sanitizer">TSan</abbr>, and
lesser known sanitizers, such as <abbr title="Control Flow Integrity">
CFI</abbr>.

This `find_package` module does *not* depend on any specific language being
enabled. However, the module attempts to check if `CXX`, `C`, `OBJCXX`, and
`OBJC` are enabled (in that order). To force checking against a particular
language (and thus a particular compiler), users can set the
`Sanitizer_LANGUAGE_CHECK` variable before calling `find_package`

> [!CAUTION]
> This module *does* assume that the compiler for all the enabled compiler
> languages *and the linker language* are all the same. This module cannot
> support a rare case such as when MSVC is used for C, Clang is used for C++,
> and Swift is used as the linker.

This module provides several `COMPONENTS`, all of which are optional, and
nearly all of which have a specific alias name to make working with the
components easier. For example, [`UndefinedBehavior`](undefined.md) has the
alias component `UBSan`. Using either one will "find" the same component and
create the same `IMPORTED` targets.

Some sanitizers have support for tweaking their behavior via compile time
options. Support for these options is exposed via custom properties that are
documented in each sanitizer's section. Each property can be initialized by
setting the `IXM_<property-name>` variable prior to *setting* these properties.

> [!NOTE]
> Some components provided by this package do not contain the name "sanitizer"
> in their name. (e.g., [SafeStack](./safe-stack)). However, they use the same
> sanitizer machinery as well known sanitizers such as ASan, including compiler
> attributes such as `no_sanitize` and compiler and linker flags such as
> `-fsanitize=`. Any issues with these naming and organizational questions are
> outside the scope of IXM's purview, and should be raised with relevant
> upstream projects.


