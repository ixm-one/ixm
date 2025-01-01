---
title: Environment Checks
order: 2
---

# Environment Checks

This section documents commands used for checking the status of the local
*build* environment (*not* your environment variables). Nearly every command in
here is a wrapper around some builtin CMake module, such as
`CheckCompilerFlag`. However, they each provide a more natural approach to
their operations such as automatically creating a variable name, properly
scoping arguments, and treating arguments in a uniform way.

## `ixm::check::option::compile`

Checks that the provided option is accepted by the compiler without a
diagnostic. This is a smarter wrapper around `check_compiler_flag`.

### Required Parameters {#option/compile/required}

`language`
: The language to check against. This language must be enabled beforehand or
  users will receive an error.

`flag`
: The compiler option that will be checked for validity.


### Keyword Parameters {#option/compile/keyword}

`OUTPUT_VARIABLE`
: *Type*: `identifier`
: *Default*: An identifier equal to `$<MAKE_C_IDENTIFIER:${flag}>`
: Variable to set the return value to. This variable will be stored in the
  CMake cache.

`COMPILE_OPTIONS`
: *Type*: `any[]`
: A list of additional options to pass to the compile command.
: > [!TIP]
  > Unlike `CHECK_REQUIRED_FLAGS`, this argument is a list and does not *need*
> to be a string.

`LINK_OPTIONS`
: *Type*: `any[]`
: A list of options to add to the link command.

## `ixm::check::option::link`

### Required Parameters {#option/link/required}

### Keyword Parameters {#option/link/keyword}

## `ixm::check::include`

Checks for the provided header file for a given language. This is a smarter
wrapper around `check_include_files`.

If this command does not meet your needs, use the `CMakePushCheckState` and
`CheckIncludeFiles` modules directly instead.

### Required Parameters {#include/required}

`header`
: *Type*: `path`
: Name of header file to check for existence. These are typically passed in
  unquoted.

### Keyword Parameters {#include/keyword}

`OUTPUT_VARIABLE`
: *Type*: `identifier`
: *Default*: An identifier equal to `$<UPPER_CASE:$<MAKE_C_IDENTIFIER:HAVE_${header}>>`

`LANGUAGE`
: *Type*: `identifier`
: *Default*: `C` if enabled. `CXX` if `C` has not been enabled.
: Which language's compiler to use for checks.

`INCLUDE_DIRECTORIES`
: *Type*: `path[]`
: A list of header search paths to pass to the compiler. Values set to the
  current directory's `INCLUDE_DIRECTORIES` property are ignored.

`COMPILE_DEFINITIONS`
: *Type*: `{string|define}[]`
: A list of compiler definitions. These can be in the form of a single unquoted
  string (e.g., `FOO`), a key-value pair (such as `FOO=bar`) or in the form of
  `-DFOO` or `-DFOO=bar`.

`COMPILE_OPTIONS`
: *Type*: `any[]`
: A space delimited list of quoted or unquoted strings to pass to the compiler.
: > [!TIP]
  > This is the main breakaway from `check_include_files`, which requires that
  > compile options be a single string, and not a list of arguments.

`LINK_OPTIONS`
: *Type*: `any[]`
: A list of options to add to the link command.

`LIBRARIES`
: *Type*: `{target|identifier|path}[]`
: A list of libraries to add to the link command. These can be system library
  names, filepaths to a full library, or `IMPORTED` targets.

`HEADERS`
: *Type*: `path[]`
: Additional header files to check for inclusion.

`QUIET`
: *Type*: `option`
: Suppresses status messages if set.

## `ixm::check::compiles`

`OUTPUT_VARIABLE`
: *Type*: `identifier`
: *Required*: YES

## `ixm::check::runs`

> [!CAUTION]
> There is no limit to what can be executed by `ixm::check::runs`, and this can
> constitute a security issue. For this reason, the command can be disabled by
> defining `IXM_DISABLE_CHECK_RUNS_COMMAND` prior to including CMake. The
> actual *value* of `IXM_DISABLE_CHECK_RUNS_COMMAND` does not matter. It just
> has to exist as a variable.
