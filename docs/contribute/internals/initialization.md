---
title: Initialization
order: 1
---

# Initialization

Like any library, IXM has to do *some* level of bookkeeping to ensure that it
is able to execute correctly. For this reason, there is an initialization step
that more or less runs on every CMake execution. While the steps listed below
may seem like a lot, the overhead of using IXM on every CMake configuration
step is kept to a minimum.

IXM's initialization performs the following steps:

1. Set internal cache variables
2. Set global cache variables
3. Set default values for CMake policies
4. *Define* internal properties
5. *Set* internal properties
   1. Check execution environment for ANSI Terminal Hyperlink support.
   2. Check execution environment for Unicode character support.
6. Include source files containing IXM's required functions.
7. Setup a `DEFER` call to `cmake_file_api` for `CMAKE_SOURCE_DIR` so that the
   CMake File API is generated before CMake exits execution.
8. Prepend the IXM module directory to `CMAKE_MODULE_PATH`.
