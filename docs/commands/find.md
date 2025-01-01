---
title: Finding Artifacts
order: 4
---

# Finding Artifacts

CMake provides several commands that can be used to find pre-existing files,
executables, and libraries. These come in handy when trying to determine if an
artifact exists. However, because these commands are quite old, they have
several issues:

1. Due to legacy naming conventions, users are encouraged to use
   `SCREAMING_SNAKE_CASE` when `<Component>_SNAKE_CASE` is the *correct*
   approach.
2. They do not automatically set a variable for users.
3. The search is the least important part of validating whether a component in
   a `find_package(MODULE)` file exists.

For these reasons, IXM provides several wrappers to find various artifacts that
aid in automatic [Component Discovery][acd] by generating bookkeeping
information to aid in creating an `IMPORTED` target.

Additionally, these commands use the `message(CHECK_PASS)` and
`message(CHECK_FAIL)` commands and IXM's augmented messages for them for
output.

## `ixm::find::program`

Find the desired executable. Optionally, finds the program's version value as
well if requested.

## `ixm::find::library`

Find the desired static or shared library. 

## `ixm::find::framework`

Find the desired Apple Framework. This command *also* searches for the header
that is necessary to include said framework.

## `ixm::find::header`

Find the *path* containing the given header name.

[acd]: ../guides/features-and-concepts#component-discovery
