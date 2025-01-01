---
title: Coverage
---

# Code Coverage

IXM provides a `Coverage` package that allows users to link against an
`IMPORTED` `INTERFACE` library and automatically get the benefits to use a
specific compiler interface for code coverage. As of right now, only two
runtimes are supported:

 - GCC's [gcov][1]
 - LLVM's [Source Based Code Coverage][2]

This `find_package` module currently depends on the C++ language being enabled.
At a later date, a way to explicitly list which languages to use for checking
will be enabled.

> [!NOTE]
This module *does* perform some `try_compile` checks to make sure a compiler
supports a set of flags (as Clang can be easily modified to remove or change
this feature's behavior)

## Usage

To use this module properly, users must *explicitly* name the component they
wish to use. These components are [`GNU`](./gnu.md) and [`LLVM`](./llvm.md).
Additionally, a coverage *target* must be added to properly extract, combine,
and filter the results into a format that can be uploaded to a platform such
[codecov](https://codecov.io) *or* to be viewed via a separate tool such as
kcov. Each component has its own target and parameters for this use case.

Each component provides its own target, as well as some additional binary
targets that might be necessary for tooling. See each component's documentation
page for more information.

[1]: https://gcc.gnu.org/onlinedocs/gcc/Gcov-Intro.html
[2]: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
