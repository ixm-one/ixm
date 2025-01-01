---
title: ccache
---

# `ccache`

`ccache` is a compiler cache. It speeds up recompilation by caching previous
compilations and detecting when the same compilation is being done again. More
information can be learned about `ccache` on [its website](https://ccache.dev).

IXM provides a `ccache` package that allows users to use `ccache` as an
`IMPORTED` executable target. This can then be used to set the
`CMAKE_<LANG>_COMPILER_LAUNCHER` (or the properties they set).

## Targets

This module only provides one imported executable target. If the `ccache`
executable cannot be found, this target is not available.

`ccache::ccache`
: The `ccache` executable (or a `ccache` compatible executable)
: *Required*: **YES**

## Usage

To get the full usage out of `ccache`, a few extra operations must be
performed.

1. The `MSVC_DEBUG_INFORMATION_FORMAT` property **MUST** be set to `Embedded`,
   otherwise `ccache` will fail to cache and users will get inscrutable errors
   regarding PDBs or the PDB server.
2. When using `target_precompile_header`, source files *MUST* use the
   `-fno-pch-timestamp` flag *if* the compiler is Clang or a Clang-like. This
   option can only be passed in via `-Xclang`, and thus a generator expression
   is recommended.
   ```cmake
   target_compile_options(${target}
     PRIVATE
       $<$<CXX_COMPILER_ID:Clang>:SHELL:-Xclang$<SEMICOLON>-fno-pch-timestamp>)
   ```
   Additionally, users must ensure that `pch_defines,time_macros` are present
   for the
   [`sloppiness`](https://ccache.dev/manual/4.10.html#config_sloppiness) ccache
   setting.
3. `ccache` does *not* support C++ Modules at this time. It does however
   support *clang* C++ modules, which are a wholly separate concept altogether.

Lastly, to ensure that the correct `ccache` configuration settings are found, it's
recommended to use CMake Presets to set environment variables for build
preset execution:

```json
{
    "buildPresets": [
        {
            "name": "base",
            "hidden": true,
            "environment": {
                "CCACHE_BASEDIR": "${sourceDir}",
                "CCACHE_CONFIGPATH": "${sourceDir}/my/path/to/ccache.conf"
            }
        }
    ]
}
```

With this work in place, users will be able to get the best experience out of
`ccache`.

> [!NOTE]
> It is not necessary to use the `CCACHE_CONFIGPATH` environment variable or a
> separate `ccache` configuration file, however it can save time when
> editing/working with `ccache` inside of a large CMake based build system.
