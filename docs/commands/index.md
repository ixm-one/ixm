---
title: Commands
order: 5
---

# Commands

IXM's real power lies in the robust set of commands provided to CMake project
maintainers. These are a set of functions and macros (in otherwise "commands",
as CMake calls them) to allow project maintainers to implement more powerful
constructs with less work or "hardening".

This section is specifically for people who might be implementing CMake
functions, or `find_package` modules, rather than editing a CMakeLists.txt
file.

For this reason, *every command* in IXM's API is intended to be called via
`cmake_language(CALL)`. This might seem burdensome, however it allows users to
write their own wrapper commands if so desired. The overhead of calling
`cmake_language(CALL)` is minimal, and also makes it stand out when someone is
calling an IXM based command.
