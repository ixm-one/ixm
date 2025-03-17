---
title: Common
order: 1
---

# Common Commands

IXM's common commands handle several operations users might require as part of
their day to day routines when writing CMake commands.

## `ixm_fallback`

Sets a default fallback value for a variable if it is not defined. The value
set is whatever is passed after the `variable` argument (i.e., [`ARGN`][argn]).

> [!IMPORTANT]
> This function's behavior is directly affected by [CMP0174][policy-174], as it
> checks if te given `variable` is `DEFINED` or not (i.e., if the variable is
> "unset", the values provided are assigned).

### Required Parameters {#fallback/required}

`variable`
: *Type*: `identifier`
: Name of the variable to store values in.

## `ixm_property`

Creates a generator expression for reading from a target property, as well as
ensuring that any resulting values from said generator expression are also
evaluated. Supports both the `$<TARGET_PROPERTY:target,property>` format, as
well as `$<TARGET_PROPERTY:property>`.

### Required Parameters {#property/required}

`property`
: *Type*: `identifier`
: Name of the property to create the generator expression for.


### Keyword Parameters {#property/keyword}

`CONTEXT`
: *Type*: `option`
: Use `TARGET_GENEX_EVAL` instead of `GENEX_EVAL` for the generator expression.

`TARGET`
: *Type*: `target`
: Name of target or a generator expression that evaluates to a target name.

`OUTPUT_VARIABLE`
: *Type*: `identifier`
: *Default: `${property}`
: Name of the variable to write the generator expression to.

`PREFIX`
: *Type*: `identifier[]`
: Any number of identifiers to prefix to the property. These are joined via the
  `_` character, and are most useful when the `OUTPUT_VARIABLE` argument isn't
  used and the user wishes to use the provided `property` instead.

### Example

```cmake
ixm_property(IMPORTED_LOCATION TARGET ccache::ccache)
set_property(TARGET ${PROJECT_NAME} PROPERTY
  CXX_COMPILER_LAUNCHER ${IMPORTED_LOCATION})
```

## `ixm::unimplemented`

This is a small helper function that simply prints a `FATAL_ERROR` with the
message "This command is not yet implemented". It is most useful when writing
stub functions that have yet to be implemented.

## `ixm::assert`

`ixm::assert` is able properly handle *condition syntax* used by commands like
`if()` or `while()` in CMake. If the assertion fails, a `FATAL_ERROR` message
is output. Conditions are passed to `ixm::assert` *as if* it were `if()` or
`while()`.

### Example

```cmake
cmake_language(CALL ixm::assert DEFINED VARIABLE_NAME)
```

## `ixm::hyperlink`

Creates a renderable hyperlink usable for the current interface that is
rendering CMake output. When using a hyperlink capable terminal, this will use
ANSI escape codes.

### Required Parameters {#hyperlink/required}

`output`
: Name of the output variable to store the value in.

### Keyword Parameters {#hyperlink/keyword}

`URL`
: The URL that the hyperlink will point to
: *Required*: YES

`TEXT`
: Text to render alongside the URL to give it a friendly name
: *Required*: YES

## `ixm::matches`

This command preserves the `CMAKE_MATCH_<N>` and `CMAKE_MATCH_COUNT` variables
as `MATCH{<N>}` and `MATCH{COUNT}`. This also replaces instances of
`CMAKE_MATCH_<N>` with the `MATCH{<N>}` equivalent in the calling scope.

This command is a holdover from early implementations of IXM. While it may not
currently be used by IXM, there is some value in rebinding the results of
`string(REGEX MATCH)` or the condition syntax usage of `MATCHES`.

[policy-174]: https://cmake.org/cmake/help/latest/policy/CMP0174.html
[argn]: https://cmake.org/cmake/help/latest/command/function.html#arguments
