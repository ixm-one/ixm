---
title: Common
order: 1
---

# Common Commands

IXM's common commands handle several operations users might require as part of
their day to day routines when writing CMake commands.

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
