---
title: Project Code Injection
order: 5
---

# Project Code Injection

When calling the `project()` command in CMake, there are several ways to inject
custom scripts to be executed both *immediately before* and *immediately after*
each call. There are also code injection features that use the name passed to
`project()` to determine which files to include.

This guide will walk you through *what* these code injection variables are, how
to best use them, and provide useful examples for why they might exist.

> [!NOTE]
> While `CMAKE_TOOLCHAIN_FILE` is technically a form of code injection, it is
> intended to be used explicitly for *toolchain* related features. It is also
> sometimes read multiple times when first executing CMake, and is usually not
> read on subsequent CMake configuration runs unless the `--fresh` flag is
> passed to CMake.
>
> Covering `CMAKE_TOOLCHAIN_FILE` is outside the scope of this guide.
## Behavior

To take advantage of the `project()` code injection, users need to either call
`set()` or `list(APPEND)` on the variables documented below:

 - `CMAKE_PROJECT_TOP_LEVEL_INCLUDES`
 - `CMAKE_PROJECT_INCLUDE`
 - `CMAKE_PROJECT_INCLUDE_BEFORE`
 - `CMAKE_PROJECT_<PROJECT-NAME>_INCLUDE`
 - `CMAKE_PROJECT_<PROJECT-NAME>_INCLUDE_BEFORE`

In the case of these last two variables, replace the `<PROJECT-NAME>` with
whatever name is passed to `project()`. This name is case sensitive, so be sure
to label the variable correctly. For example:

The above code sample will *not* work because the variable name is
`CMAKE_PROJECT_injected_project_INCLUDE_BEFORE` and not
`CMAKE_PROJECT_injected-project_INCLUDE_BEFORE`:

```cmake
list(APPEND CMAKE_PROJECT_injected_project_INCLUDE_BEFORE ${script}) # [!code --]
list(APPEND CMAKE_PROJECT_injected-project_INCLUDE_BEFORE ${script}) # [!code ++]
project(injected-project)
```

## Top Level Code Injection
