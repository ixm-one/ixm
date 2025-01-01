---
title: Project Features
order: 3
---

# Project Features

This section documents and discusses commands used for declaring and setting
"project features". These are typically something you'd see set with an
`--enable-<feature>` flag in autoconf scripts of yore. To use these, simply use
`-D<feature>=<value>` and it will either turn the feature on or off.

## `ixm::feature`

`ixm::feature` acts as a wrapper around the `add_feature_info` and
`cmake_dependent_option` commands found in the [FeatureSummary][summary] and
`CMakeDependentOption` modules respectively. Unlike these two commands,
however, `ixm::feature` operates in a more structured and self-documenting
manner, while reducing some logic users would normally have to be very explicit
about.

This command can be used in conjunction with *both* CMake's
[FeatureSummary][summary], and IXM's [Summary](../modules/summary).

> [!TIP]
> `add_feature_info` only works for boolean values (i.e., `YES/NO`, `ON/OFF`),
> not general cache values or "choices" that might be shown in `cmake-gui` or
> `ccmake`, and as a result so too does `ixm::feature`.

### Keyword Parameters {#feature/keyword}

`NAME` {#feature/keyword/name}
: *Type*: `identifier`
: *Required*: YES
: Name of the feature that will be printed to the feature summary.

`OPTION` {#feature/keyword/option}
: *Type*: `identifier`
: *Required*: YES
: Name of an `option()` that will be used to turn a given feature on or off.

`DEFAULT` {#feature/keyword/default}
: *Type*: `boolean`
: *Default*: `NO`
: Default state for the option to be set to.
: > [!NOTE]
  > The default value for a feature is irrelevant if the conditions passed to
  > `REQUIRES` are not valid, as the feature will be forced to `OFF`. The
  > default value here is what the feature can be set to *if* the necessary
  > conditions are met.

`DESCRIPTION` {#feature/keyword/description}
: *Type*: `string`
: Provides help text to display when printing out a feature summary, or showing
  the option's help information under an interactive CMake configuration tool,
  such as `ccmake` or `cmake-gui`.

`PREDEFINED` {#feature/keyword/predefined}
: *Type*: `option`
: `ixm::feature` will assume the `option()` has already been defined, and will
  skip defining the `option()`. Most useful when converting from
  `add_feature_info` and `option()` or `cmake_dependent_option` to
  `ixm::feature`.

`PROJECT_ONLY` {#feature/keyword/project_only}
: *Type*: `option`
: Makes it so that the current project must be the top level project, or else
  the `option()` will be turned off


`REQUIRED` {#feature/keyword/required}
: *Type*: `arguments`
: Required options for whether the `option()` is forced to `OFF` or not. This
  keyword argument supports *multiple* sub-keyword arguments, each of which is
  provided to simplify the logic involved with detecting whether a feature can
  be enabled or not.
: | Parameter | Type | Description |
  |:-:|:-:|:--|
  |`PACKAGES`|`any[]`|Names of packages that *must* be considered found via `find_package`. These values are case sensitive. |
  |`TARGETS`|`any[]`|Names of targets that *must* be defined. These can be `ALIAS`, `IMPORTED`, or defined locally within the given project structure.|
  |`EXISTS`|`path[]`|Any filesystem entity that *must* exist on disk.|
  |`FILES`|`path[]`|Files that *must* exist on disk. If a provided name is actually a *symlink* to a file, this condition will fail.|
  |`DIRECTORIES`|`path[]` | Directories that must exist on disk.|
  |`CONDITIONS`|`condition[]` | Any additional conditions that are valid under CMake's [Condition Syntax][condition] |

[condition]: https://cmake.org/cmake/help/latest/command/if.html#condition-syntax
[summary]: https://cmake.org/cmake/help/latest/module/FeatureSummary.htm
