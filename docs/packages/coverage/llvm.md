---
title: LLVM
---

# Source-based Code Coverage

For more information on the LLVM source-based code coverage implementation, see
its [documentation
page](https://clang.llvm.org/docs/SourceBasedCodeCoverage.html). This component is considered missing if the *Required* targets in [`IMPORTED Targets`](#imported-targets) cannot be found.

## Targets

The following `IMPORTED` targets are created when the LLVM component is
required.

`Coverage::LLVM` {#coverage-llvm}
: Provides LLVM's source based code coverage compiler and linker options
: This target is available if the C or C++ compiler supports the
  `-fcoverage-mapping` compiler flag and the `-fprofile-instr-generate` linker
  flag.
: *Type*: **LIBRARY**
: *Required*: **YES**

`Coverage::LLVM::ProfileData` {#coverage-llvm-profiledata}
: The `llvm-profdata` executable
: *Type*: **PROGRAM**
: *Required*: **YES**

`Coverage::LLVM::Tool` {#coverage-llvm-tool}
: The `llvm-cov` executable
: *Type*: **PROGRAM**
: *Required*: **YES**

`Coverage::LLVM::C++Filter` {#coverage-llvm-cxxfilter}
: The `llvm-cxxfilter` executable.
: *Type*: **PROGRAM**
: > [!TIP]
  > Sadly, not all distributions of Clang are made equal. The Windows installer
  > provided by the LLVM project *does not* install `llvm-cxxfilter`. However
  > the tarball distribution it provides *does*. If the filtering of symbols
  > when viewing code coverage on Windows is important, ensure that this tool
  > is installed.

## Commands

### `add_llvm_coverage`

This creates a target that can be referred to directly with `set_property` and,
when built, will collate the raw profile data (`.profraw` files) from executed
tests into a .`profdata`, and then convert them into a format defined by the
user.

> [!NOTE]
> This command uses `add_custom_target` internally, which does not permit
> creating alias targets, nor does it permit creating "scoped" targets (e.g.,
> `${PROJECT_NAME}::coverage`). As a result, *all targets* passed to this
> command ***must*** be globally unique.

#### Required Parameters {#add_llvm_coverage/required}

`name`
: name of the target to create

#### Keyword Parameters {#add_llvm_coverage/keyword}

`ALL`
: Add this target to the `all` target's dependencies.

`EXPORT`
: Where to output the exported coverage information.
: By default, this is set to
  `${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${name}.lcov.info`.

`OUTPUT`
: Where to output the `.profdata` file.
: By default, this is set to
  `${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${name}.profdata`.

`GITHUB`
: Name of the GitHub Actions output parameter to writ the final `EXPORT` value
  to.
: By default, this is the value passed to `name`.
: No actions are taken if not under GitHub Actions.

`TARGETS`
: A list of targets to filter source files from.

`IGNORE_FILENAME_REGEX`
: Skip source code files with file paths that match the given regular
  expressions.

#### Example

```cmake
add_llvm_coverage(coverage
  TARGETS ${PROJECT_NAME}
  IGNORE_FILENAME_REGEX
    $<PATH:RELATIVE_PATH,${FETCHCONTENT_BASE_DIR},${CMAKE_BINARY_DIR}>
    $<PATH:RELATIVE_PATH,${CMAKE_CURRENT_SOURCE_DIR},${PROJECT_SOURCE_DIR}>)
foreach (test IN LISTS tests)
  add_executable(${test} ${test}.cpp)
  target_link_libraries(${test} PRIVATE Coverage::LLVM)
  # Set properties to work with `coverage` target.
  set_target_properties(${test}
    PROPERTIES
      ADDITIONAL_CLEAN_FILES $<GENEX_EVAL:$<TARGET_PROPERTY:LLVM_PROFILE_FILE>>
      LLVM_PROFILE_FILE ${PROJECT_BINARY_DIR}/$<CONFIG>/${PROJECT_NAME}-${test}.profraw
      LLVM_COVERAGE_PREFIX_MAP ${PROJECT_SOURCE_DIR}=.)
  add_test(NAME ${PROJECT_NAME}::${test} COMMAND ${test})
  set_property(TARGET coverage APPEND
    PROPERTY
      LLVM_PROFRAW_SOURCES $<GENEX_EVAL:$<TARGET_PROPERTY:${test},LLVM_PROFILE_FILE>>)
endforeach()
```
## Properties

Some properties need to be mentioned directly on targets that will link against
a given target, others are specifically for a *coverage* target.
