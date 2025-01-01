---
title: Policies
order: 3
---

# Policies

CMake's policy system allows for backwards compatibility with older CMake
implementations, allowing for older projects to "just work" out of the box.
However, when including these older projects as children, policy scoping may
end up being incorrect, and even if a given policy was set manually by a parent
project, the policy might be ignored.

However CMake provides an escape hatch to set default values for policies when
entering a "fresh" policy state. This escape hatch relies on a user setting the
`CMAKE_POLICY_DEFAULT_CMP<Policy Number Here>` variable.

Some policy values are absolutely necessary to be defaulted simply for user's
sanity and IXM does this to ensure that anyone calling `add_subdirectory` on a
subproject is guaranteed some specific behavior. Every policy documented below
is set to the `NEW` value.

[`CMP0180`](https://cmake.org/cmake/help/latest/policy/CMP0180.html)
: De-duplication of static libraries on link lines keeps first occurrence

[`CMP0180`](https://cmake.org/cmake/help/latest/policy/CMP0180.html)
: `project()` will always set the `<PROJECT_NAME>_*` values as normal
  variables.

[`CMP0177`](https://cmake.org/cmake/help/latest/policy/CMP0177.html)
: TODO

[`CMP0176`](https://cmake.org/cmake/help/latest/policy/CMP0176.html)
: TODO

[`CMP0175`](https://cmake.org/cmake/help/latest/policy/CMP0175.html)
: TODO

[`CMP0174`](https://cmake.org/cmake/help/latest/policy/CMP0174.html)
: TODO

[`CMP0172`](https://cmake.org/cmake/help/latest/policy/CMP0172.html)
: TODO

[`CMP0171`](https://cmake.org/cmake/help/latest/policy/CMP0171.html)
: `codegen` is a reserved target name.

[`CMP0160`](https://cmake.org/cmake/help/latest/policy/CMP0160.html)
: More read only properties not error when trying to set them.

[`CMP0144`](https://cmake.org/cmake/help/latest/policy/CMP0144.html)
: `find_package` supports upper-case `PACKAGENAME_ROOT` variables.

[`CMP0130`](https://cmake.org/cmake/help/latest/policy/CMP0130.html)
: `while()` diagnoses condition evaluation errors.

[`CMP0125`](https://cmake.org/cmake/help/latest/policy/CMP0125.html)
: `find_<...>()` functions have consistent cache variable behavior.

[`CMP0124`](https://cmake.org/cmake/help/latest/policy/CMP0124.html)
: `foreach()` loop variables are scoped.

[`CMP0121`](https://cmake.org/cmake/help/latest/policy/CMP0121.html)
: `list()` detects invalid indices

[`CMP0116`](https://cmake.org/cmake/help/latest/policy/CMP0116.html)
: Ninja transforms `DEPFILES` in `add_custom_command`.

[`CMP0092`](https://cmake.org/cmake/help/latest/policy/CMP0092.html)
: MSVC warning flags are removed by default.

[`CMP0091`](https://cmake.org/cmake/help/latest/policy/CMP0091.html)
: MSVC uses the `CMAKE_MSVC_RUNTIME_LIBRARY` variable.

[`CMP0090`](https://cmake.org/cmake/help/latest/policy/CMP0090.html)
: `export(PACKAGE)` does not populate package registry.


[`CMP0077`](https://cmake.org/cmake/help/latest/policy/CMP0077.html)
: `option()` honors normal variables.
