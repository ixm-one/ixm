---
title: Summary
---

# Summary

> [!CAUTION]
> This module is still in development, and is therefore unstable and does not
> work as documented.

This module is a more powerful version of the CMake `FeatureSummary` module.
Including this module will also include `FeatureSummary`, and users will
interact with this module by using the same functions provided by
`FeatureSummary`, or by functions provided with the `ixm::package` prefix, as
well as the `ixm::feature` command.

The primary reason this module exists is so that integration with CI/CD
platforms (such as GitHub Actions) is easier on users. Specifically, the
`ixm::summarize` command automatically detects if the `${GITHUB_STEP_SUMMARY}`
environment variable is present, and will use it by default if no `OUTPUT`
parameter was passed to the command.

Additionally, this module's source is written in a more readable way so that
users can better understand what `FeatureSummary` is doing, as it's internal
functions are difficult to follow or understand.

## Commands

### `ixm::summarize`

A more powerful version of `feature_summary(WHAT ALL)`, in that it will generate markdown as output.

Additionally, this command has knowledge of the `GITHUB_STEP_SUMMARY` environment variable and will output to it automatically if the `OUTPUT` parameter is not provided.

Finally, users can opt to pipe the output into a CLI rendering tool if desired.
Said tool can be an `IMPORTED` target, an `ALIAS` target, an `EXECUTABLE`
target, or a `FILEPATH`.

#### Keyword Parameters {#ixm::summarize/keyword}

`OUTPUT`
: Filepath to write the feature summary to.
: *Required*: **NO**
: *Default*: `$ENV{GITHUB_STEP_SUMMARY}` (if `$ENV{CI}` and
  `$ENV{GITHUB_ACTIONS}` are true)

`PAGER`
: `FILEPATH` to, or `TARGET` of, an executable that can output the generated
  markdown output for the build process.
: *Required*: **NO**
: > [!NOTE]
  > If no `PAGER` is passed to `ixm::summarize`, a non-markdown version of the
  > output is printed to `stdout`.

## Usage

The best way to use `ixm::summarize` is with a `cmake_language(DEFER)` call, as
this ensures it is executed at the very end of the CMake project, even if your
project is pulled in as a dependency.

```cmake
include(Summary)

cmake_language(DEFER DIRECTORY "${CMAKE_SOURCE_DIR}" CALL ixm::summarize)
```
