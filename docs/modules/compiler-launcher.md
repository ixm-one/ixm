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
well known compiler launchers, [`ccache`](/packages/launchers/ccache) and
[`sccache`](/packages/launchers/sccache).

## Commands

### `target_compiler_launcher`

This command sets various properties for a given target for any language names
passed to the `PRIVATE`, `PUBLIC`, or `INTERFACE` arguments. This property
setting works with:

 - Makefile Generators
 - Xcode Generator

It will set `-fno-pch-timestamp` on the target if the user is using `clang` as
the given language's compiler *and* the command can detect that `sccache` or
`ccache` is being used as the launcher.

Additionally, if `sccache` or `ccache` are detected as the launcher, the
`MSVC_DEBUG_INFORMATION_FORMAT` property will be set to `Embedded`
automatically.

> [!NOTE]
> Typically, developers will utilize a compiler launcher for caching of object
> files. However, this is not always the case, and this command is safe to use
> in those instances where a custom launcher is being provided.

#### Required Parameters {#target_compiler_launcher/required}

`target`
: Name of the target to modify

#### Keyword Parameters {#target_compiler_launcher/keyword}

`PUBLIC`, `PRIVATE`, `INTERFACE`
: Visibility for the language names given to the command. This affects the
  `INTERFACE_<LANG>_COMPILER_LAUNCHER` and `<LANG>_COMPILER_LAUNCHER`
  properties for the target.

`LAUNCHER`
: Name of a target, a path to an executable file, or the name of an executable
  that can be found via `find_program` (not `ixm::find::program`).
: If the name of a target is given, it does not have to exist at the time of
  the call. As long as it exists at the generation step, it will be used. The
  target can be either an `IMPORTED` target, or a target from the current
  project.
: If the name of an `IMPORTED` target is given, its `IMPORTED_LOCATION`
  property will be read. If this property is empty, no launcher will be set.
: If the name or path of an executable is given, it will be stored in a
  `${LAUNCHER}_EXECUTABLE` cache variable.
: > [!WARNING]
  > The `${LAUNCHER}_EXECUTABLE` cache variable can sometimes be set if the
  > name of a target is given and it already exists on disk. In these
  > instances, the target will still be prioritized over the variable.
: > [!WARNING]
  > If the `${LAUNCHER}_EXECUTABLE` is not found *and* no valid target name is
  > given, the compiler launcher property will be empty, however other
  > properties such as the `MSVC_DEBUG_INFORMATION_FORMAT` property will still
  > be set. This is due to limitations in CMake's generator expressions that
  > prevent the ability to error with a useful message at generation time.
: > [!IMPORTANT]
  > If using a target from the current build tree, users *will* have to call
  > `add_dependencies` themselves manually to ensure the launcher is built
  > before the current target.

#### Example

```cmake
find_package(ccache 4.10)
# If `ccache::ccache` does not exist, the `${PROJECT_NAME}` target
# will *not* be set to run.
target_compiler_launcher(${PROJECT_NAME}
  LAUNCHER ccache::ccache
  PUBLIC
    CXX C
  PRIVATE
    OBJC)
```
