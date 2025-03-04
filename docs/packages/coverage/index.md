---
title: Coverage
---

# Code Coverage

IXM provides a `Coverage` package that allows users to link against an
`IMPORTED` `INTERFACE` library and automatically get the benefits to use a
specific compiler interface for code coverage. As of right now, only two
runtimes are supported:

 - GCC's [gcov][1]
 - LLVM's [Source Based Code Coverage][2]

This `find_package` module currently depends on the C++ language being enabled.
At a later date, a way to explicitly list which languages to use for checking
will be enabled.

> [!NOTE]
This module *does* perform some `try_compile` checks to make sure a compiler
supports a set of flags (as Clang can be easily modified to remove or change
this feature's behavior)

## Usage

To use this module properly, users must *explicitly* name the component they
wish to use. These components are [`GNU`](./gnu.md) and [`LLVM`](./llvm.md).
Additionally, a coverage *target* must be added to properly extract, combine,
and filter the results into a format that can be uploaded to a platform such
[codecov](https://codecov.io) *or* to be viewed via a separate tool such as
kcov. Each component has its own target and parameters for this use case.

Each component provides its own target, as well as some additional binary
targets that might be necessary for tooling. See each component's documentation
page for more information.

## Commands

### `add_coverage_target`

This creates a target that can be referred to directly with `set_property` and,
when built will collate raw profiling data into a format used by the selected
implementation.

> [!NOTE]
> This command uses `add_custom_target` internally, which does not permit
> creating alias targets, nor does it permit creating "scoped" targets (e.g.,
> `${PROJECT_NAME}::coverage`). As a result *all targets* passed to this
> command must be globally unique.

#### Required Parameters {#add_coverage_target/required}

`name`
: name of the target to create

#### Keyword Parameters {#add_coverage_target/keyword}

`LLVM`
: Use the LLVM Source-Based code coverage implementation

`GNU`
: Use the gcov code coverage implementation

`OUTPUT`
: Name of the final file generated at the end of the target's build step.

`FORMAT`
: File format to use for the given implementation.
: > [!TIP]
  > This can vary wildly between what tool might be used to merge and export
  > the coverage information.

### `target_coverage`

#### Required Parameters {#target_coverage/required}

`target`
: Target created with `add_coverage_target` to add dependencies to.

#### Keyword Parameters {#target_coverage/keyword}

#### Example

```cmake
add_coverage_target(coverage LLVM)
add_library(${PROJECT_NAME})
add_executable(${PROJECT_NAME}-cli)
target_coverage(coverage PRIVATE ${PROJECT_NAME} ${PROJECT_NAME}-cli)
```

## Properties

There are multiple properties provided to users that allow them to tweak either
the LLVM or GNU operations. These can be directly *on* a given build target
from the user (e.g., adding `-fcoverage-mcdc`) or modify the execution of the
coverage target itself.

`COVERAGE_LLVM_COVERAGE_PREFIX_MAP`
: Remap file source paths from `<old>` to `<new>` in coverage mapping. If there
  are multiple options, prefix replacement is applied in reverse order starting
  from the last one.
: *Type*: `list`
: *Default*: `$<TARGET_PROPERTY:SOURCE_DIR>=.`
: *Context*: Coverage Target

`COVERAGE_LLVM_MCDC`
: Pass [`-fcoverage-mcdc`][mcdc] to the compiler
: *Type*: `boolean`
: *Context*: User Target
: *Default*: `<empty>`

`COVERAGE_LLVM_MERGE_FAILURE_MODE` {#property/coverage-llvm-merge-failure-mode}
: `llvm-profdata`'s failure mode when merging `.profraw` files into a
  `.profdata` file.
: *Type*: `enum`
: *Values*: `warn`, `any`, `all`
: *Default*: `any`
: *Context*: Coverage Target



[1]: https://gcc.gnu.org/onlinedocs/gcc/Gcov-Intro.html
[2]: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html

[mcdc]: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html#mc-dc-instrumentation
