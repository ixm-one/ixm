---
title: sccache
---

# `sccache`

IXM provides an `sccache` package that allows user to use `sccache` as an
`IMPORTED` executable target. This can then be used to set the
`CMAKE_<LANG>_COMPILER_LAUNCHER` variable or a target's specific
`<LANG>_COMPILER_LAUNCHER`.

## Targets

This module only provides one `IMPORTED` executable target. If the `sccache`
executable cannot be found, this target is not available.

`sccache::sccache` {#target-sccache}
: The `sccache` executable (or a `sccache` compatible executable)

## Usage

To get the full usage out of `sccache`, a few extra operations must be
performed.

1. The `MSVC_DEBUG_INFORMATION_FORMAT` property MUST be set to `Embedded`,
   otherwise `sccache` will fail to cache and users will get inscrutable errors
   regarding PDB services.
2. `sccache` does *not* support C++ Modules at this time. It also does not
   support Clang C++ modules.
3. When using `sccache` and multiple values for `CMAKE_OSX_ARCHITECTURES`,
   users will need to set `SCCACHE_CACHE_MULTIARCH` to `true`. Additionally,
   users might need to also change to a so-called "direct mode" and rely on
   hashing of the command line arguments instead of the preprocessed source.

## Example

One way to use `sccache` is to simply require users to have it exist on their
system.

```cmake
find_package(sccache REQUIRED)

set(sccache-location $<TARGET_PROPERTY:sccache::sccache,IMPORTED_LOCATION>)
set(CMAKE_CXX_COMPILER_LAUNCHER ${sccache-location})
set(CMAKE_C_COMPILER_LAUNCHER ${sccache-location})
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT Embedded)
```

However, this approach is not flexible for use cases where it is not always
possible to rely on `sccache` existing on a given system. Thus, it is better to
use a more fallible approach.

```cmake
find_package(sccache)

if (TARGET sccache::sccache)
  set(CMAKE_CXX_COMPILER_LAUNCHER
    $<TARGET_PROPERTY:sccache::sccache,IMPORTED_LOCATION>)
  set(CMAKE_C_COMPILER_LAUNCHER
    $<TARGET_PROPERTY:sccache::sccache,IMPORTED_LOCATION>)
endif()

string(CONCAT CMAKE_MSVC_DEBUG_INFORMATION_FORMAT $<IF:
  $<TARGET_EXISTS:sccache::sccache>,
  Embedded,
  ProgramDatabase
>)
```

Because so many of these values can be set with generator expressions, it
allows users a great amount of flexibility to work around the instance where
`sccache` could not be found.


