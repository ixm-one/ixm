---
title: Features and Concepts
order: 6
---

# Features and Concepts

This guide will provide an overview of features that IXM provides that are not
obviously exposed to users, but are provided in some fashion by IXM's command
API, it's properties, and more.

## Component Discovery

Writing `find_package(MODULE)` files is a very painful process and difficult to
get correct. The moment a developer wants to provide more than one *component*
for a `find_package(MODULE)` file, the complexity of the file will increase.

IXM's `ixm::find::*` and `ixm::package::*` commands are able to discern when
they are executing inside of a `find_package(MODULE)` file, and from there,
they are able to automatically register *and* import components as users
declare them.

As an example, the `find_package(Coverage)` module provides different targets
depending on the requested component. Inside this module, we find several LLVM
specific programs if the `LLVM` component was requested. We can automatically
register these commands to be part of this component and to be imported with
specific names.

```cmake
cmake_language(CALL ixm::find::program
  NAMES llvm-cxxfilt
  DESCRIPTION "LLVM symbol undecoration tool"
  PACKAGE
    COMPONENT LLVM
    TARGET C++Filter
    OPTIONAL)
cmake_language(CALL ixm::find::program
  NAMES llvm-profdata
  DESCRIPTION "LLVM profile data tool"
  PACKAGE
    COMPONENT LLVM
    TARGET ProfData)
```

If the above code were to be placed *outside* of *any* `find_package(MODULE)`
command, no information would be registered for use to be automatically
imported.

## Unicode and Hyperlinks

At startup, IXM briefly checks the environment variables provided to CMake to
see if it is executing under an environment which supports printing unicode
characters, as well as if terminal sequences for hyperlinks are an option.

If they are, the `ixm::hyperlink` command will be able to generate ANSI
terminal sequences that provide friendly hyperlinks. This can, in many cases,
cut down on unnecessarily large lines in a user's terminal when CMake is
outputting text.

### Customization

Users can override the detection mechanisms IXM uses to check if unicode or
hyperlinks are supported. The values documented below *must* be set before IXM
is loaded.

`IXM_SUPPORTS_HYPERLINKS`
: *Type*: `boolean`
: When set to any `boolean` value, IXM will skip environment detection for
  support of ANSI terminal sequence hyperlinks. If this is set to any `false`
  value, IXM will never use ANSI terminal sequence hyperlinks.

`IXM_SUPPORTS_UNICODE`
: *Type*: `boolean`
: When set to any `boolean` value, IXM will skip environment detection for
  whether it is safe to print UTF-8 text in calls to `message()`. If this is
  set to any `false`, IXM will never output UTF-8 character sequences.

## Augmenting Check Messages

CMake provides a special set of methods for the `message()` command that are
related to reporting the start and end state of a "check". However, the output
that CMake provides *by default* leaves a lot to be desired when reading
through terminal or text logs. For this reason, IXM will provide more detailed
output from commands it provides checks for.

Specifically, if IXM is able to determine that Unicode is supported, emojis
will be used for `CHECK_START` (🔎), `CHECK_PASS` (😎), and `CHECK_FAIL` (❌).
This allows users to quickly know which lined output is related to the
`ixm::find` and `ixm::check` API calls.

Example output will look similar to the following output:

```console
-- 🔎 Searching for PackageName_LIBRARY
-- 🔎 Searching for PackageName_LIBRARY - found 😎 : /path/to/lib
-- 🔎 Searching for PackageName_INCLUDE_DIR
-- 🔎 Searching for PackageName_INCLUDE_DIR - not found ❌
```

This output can be disabled by [disabling unicode
support](#unicode-and-hyperlinks) within IXM.

In the future, IXM *may* support ANSI color code sequences to make output stand
out even more.

## Experimental Features

IXM will sometimes provide ambitious features that might require fine tuning,
redesigns, or complete removal if they prove to be unpopular.

As a result, attempting to use these features prior to stabilization will
result in an error being thrown by IXM unless users explicitly opt in to the
feature. This is done via a UUID being set to the name of a specific variable.
These UUIDs *may* change in between releases of IXM. By using experimental
features *early* users are explicitly opting in to possibly have their build
break.
