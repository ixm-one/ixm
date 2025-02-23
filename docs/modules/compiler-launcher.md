---
title: CompilerLauncher
---
# CompilerLauncher

Setting a compiler launcher to work correctly across different types of
launchers or for different systems becomes difficult without a deeper
understanding of various tooling for languages.

This module is provided specifically to reduce the overhead required to set a
compiler launcher by initializing the default variable, or by setting a
launcher on a per-target basis.

IXM also provides several `find_package(MODULE)` files for finding two very
well known compiler launchers, `ccache` and `sccache`.

## Commands

### `target_compiler_launcher`

This command sets various properties for a given target for any language names
passed to the `PRIVATE`, `PUBLIC`, or `INTERFACE` arguments. This property
setting works with:

 - Makefile Generators
 - Xcode Generator

It also works with MSVC, and will set `-fno-pch-timestamp` on the target if the
user is using `clang` as the given language's compiler.

> [!NOTE]
> Typically, developers will utilize a compiler launcher for caching of object
> files. However, this is not always the case, and this command is safe to use
> in those instances where a custom launcher is being provided.

#### Required Parameters {#target_compiler_launcher/required}

`target`
: Name of a target to operate on

#### Keyword Parameters {#target_compiler_launcher/keyword}

`PUBLIC`, `PRIVATE`, `INTERFACE`
: Visibility for the language names given to the command. This affects the
  `INTERFACE_<LANG>_COMPILER_LAUNCHER` and `<LANG>_COMPILER_LAUNCHER`
  properties for the target.

`LAUNCHER`
: Name of an `IMPORTED` target, a path to an executable file, or the name of an
  executable that can be found via `find_program` (not `ixm::find::program`).

`OPTIONAL`
: Do not error if the parameter given to `LAUNCHER` does not exist or cannot be
  found.
