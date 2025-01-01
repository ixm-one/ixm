---
title: Style Guide
order: 1
---

# Style Guide

## CMake

Please try to follow the existing style of code and keep the following rules in
mind:

 - 2 spaces per indented level.
 - Parameters passed to commands that are intended to be treated as URLs (or
   strings) are to be quoted.
 - Prefer generator expressions over `if()/else()` and other control flow
   commands unless it is either impossible *or* the conditional logic can only
   execute during configuration time and does not pass through generation time.
 - Public global variables, and keyword arguments (i.e., those created via
   `cmake_parse_arguments`) are to use `SCREAMING_SNAKE_CASE`.
 - Local variables are to use `kebab-case`.
 - When placing a command over multiple lines, parameters names are to be
   indented one level, with the actual arguments indented one level further.
 - Prefer `YES/NO` or `ON`/`OFF` for boolean values over `TRUE`/`FALSE`.

### Naming Conventions

> [!NOTE]
> This section is outdated and needs to be brought up to date.

 - Public global properties expected to be read by users are to use the prefix
  `ixm::`
 - Public properties that inform users about the current system are to use
   `ixm::system::`. e.g., `ixm::system::docker` is typically set to `YES` when
   IXM is able to detect it is running inside of a docker container.
 - Public properties that inform users about a given continuous integration
   provider are expected to use `ixm::ci::<provider>::`
 - Internal or private properties are to start with `🈯::ixm::`. ("🈯" is the
   "reserved" emoji).
 - Internal commands are to start with `🈯::ixm::` and be executed via
   `cmake_language(CALL)`.
 - Public commands (i.e., commands that allow users to implement their own
   library functionality), are to start with `ixm::`

## Documentation Tags

IXM uses a self-designed system of so-called "documentation tags" that are
borrowed from tools like Doxygen or JSDoc. In IXM's specific case, these have
been adjusted specifically for use with CMake. While we do not currently have
tooling in place for automatic extraction of these documentation tags, they are
still useful for readers to allow a quick understanding of what arguments a
given function might take.

This is important for a language like CMake as there are two types of
arguments: position arguments and keyword arguments. Position arguments are the
arguments named in a function when calling the `function()` command. Keyword
arguments are the ones that are generated via the `cmake_parse_arguments`
command, and typically it is not immediately obvious what keyword arguments a
given function might take. This is further compounded by the ability to more or
less parse arguments from keyword arguments. For example:

```cmake
function (my-function argument)
  cmake_parse_arguments(ARG "" "${PROJECT_NAME}" "VERSION" ${ARGN})
  cmake_parse_arguments(VERSION "SET" "VALUE" "DEPENDENCIES" ${ARG_VERSION})
  if (VERSION_SET)
    # Do something here
  endif()
endfunction()
```

In the above example, this function takes a variadic argument, `VERSION`, which
in itself has several arguments of its own. This is where documentation tags
can come in handy, describing both the argument *name* as well as its expected
type.

```cmake
#[[
# @param {option} VERSION.SET - Is the version set?
# @param {version} VERSION.VALUE - What is the version value?
# @param {list} VERSION.DEPENDENCIES - What are the version dependencies?
#]]
```

This notation approach allows any user to see that they can call the defined
function like so:

```cmake
cmake_language(CALL my-function arg
  VERSION
    SET
    VALUE 1.2.3
    DEPENDENCIES 11 22 33)
```

While not all functions within IXM currently have documentation tags, all
contributions *must* provide a basic set of documentation tags for new
functions, and any changes to existing functions must be updated as well. PRs
without these will not be accepted until they are added. If authors do not add
them after being asked to do so, their PR may be closed.
