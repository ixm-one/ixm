---
title: ExtractAutoconfVersion
---
# ExtractAutoconfVersion

A common pattern found in older build system projects (e.g., `curl`) is that
users might need to interact with an older build system file. Typically this
results in a variety of scripts, functions, and copy pasted code to read the
`AC_INIT` value from a `configure.ac` file. This value is then set as the
project version when calling `project()`. This module instead provides a single
command, `extract_autoconf_version`, that can be used to automatically extract
said value and store the value as a cache variable.

This module is provided *specifically* for codebases that might finally be
migrating off of autotools in some manner and have selected CMake as their
build system.

## Commands

### `extract_autoconf_version`

Extract a version from a call to the `AC_INIT` macro in `configure.ac`. The
output variable will be cached and the `DOC` argument set as its documentation
string if provided.

#### Required Parameters {#extract_autoconf_version/required}

`output`
: Name of the output variable to store the value in.

#### Keyword Parameters {#extract_autoconf_version/keyword}

`ADVANCED`
: Mark the variable as `ADVANCED` so it does not appear in `ccmake` or
  `cmake-gui`'s cache variable list by default.

`FILE`
: File to read the `AC_INIT` macro from.
: By default this is `${CMAKE_CURRENT_SOURCE_DIR}/configure.ac`

`REGEX`
: Regular expression to extract the version value from.
: By default this is `^AC_INIT\\([^,]+,\\[([0-9]+)[.]([0-9]+)?[.]?([0-9]+)?\\].+$`

`DOC`
: Documentation string to set the cache variable to.
