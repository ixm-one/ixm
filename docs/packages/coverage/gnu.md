---
title: GNU
---

# `gcov` Based Code Coverage

`gcov` is a tool you can use in conjunction with GCC or Clang to test coverage.
More information can be found in `gcov`'s
[documentation](https://gcc.gnu.org/onlinedocs/gcc/Gcov.html)

> [!IMPORTANT]
> This component is *always* found as long as `gcov` can be found, but the
> `IMPORTED` library target it provides will have *no effect* unless you are
> using `Clang`, `AppleClang`, or `GNU` for the `OBJCXX`, `OBJC`, `CXX`, or `C`
> languages.
>
> This was done to speed up "finding" the component. Support for conditional
> flag detection might be added in the future. Additional compilers might be
> added or supported as well under some circumstances.

## Targets

The following `IMPORTED` targets are created when the GNU component is found.

`Coverage::GNU` {#coverage-gnu}
: Provides gcov compiler and linker options.
: This target is *always* available if the `gcov` tool is found, but only
affects dependents if the language for a given source file is `OBJCXX`, `OBJC`,
`CXX`, or `C` and if the `CMAKE_<LANG>_COMPILER_ID` is `GNU`, `AppleClang`, or
`Clang`.

`Coverage::GNU::Tool` {#coverage-gnu-tool}
: The `gcov` executable
: *Type*: PROGRAM
: *Required*: YES

## Properties

Some properties allow the modification of some code coverage information.

`COVERAGE_GNU_ABSOLUTE_PATHS`
: Pass `-fprofile-abs-path` to the compiler.
: By default, gcov uses relative paths from when the source code was compiled.
  With this flag enabled full filesystem paths are placed into the generated
  output.
: *Type*: `boolean`
: *Scopes*: `TARGET`
: Default: `NO`
