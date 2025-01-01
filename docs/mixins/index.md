---
title: Mixins
order: 4
---

# Mixins

> [!CAUTION]
> This feature is still experimental and not yet implemented fully or stable.

IXM provides several so-called *project mixins*, various files that can be
appended to the [`CMAKE_PROJECT_INCLUDE_BEFORE`][include-before] and
[`CMAKE_PROJECT_INCLUDE`][include] variables so that they execute immediately
before and after a call to the `project()` command, respectively. Each mixin
provided by IXM has its own settings, features, and configurability.

Care should be taken to carefully select mixins for use with your project. Not
all mixins are compatible with each other, and others are intended to be
combined together. Others, still, are already a combination of several mixins.

For more information on *using* project mixins, see the [guide on project code
injection](../guides/project-code-injection.md) for how to get started.

> [!TIP]
> Project mixins are intended to be used by the average user who doesn't want
> to think about or spend time on writing their CMake project every time.
> However, *implementing* a project mixin for others to use is an advanced
> topic, and care should be given when implementing *new* mixins.

[include-before]: https://cmake.org/cmake/help/latest/variable/CMAKE_PROJECT_INCLUDE_BEFORE.html
[include]: https://cmake.org/cmake/help/latest/variable/CMAKE_PROJECT_INCLUDE.html
