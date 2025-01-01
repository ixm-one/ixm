---
title: Packages and Imports
order: 5
---

# Packages and Imports

## Automatic Component Discovery

## `ixm::package::check`

This is a wrapper around `find_package_handle_standard_args` to make it easier
to work with. If used in the same scope as the [`ixm::find::*`
commands](./find), it will also automatically discover components, variables,
*and* create `IMPORTED` targets.

## `ixm::package::import`

## `ixm::package::properties`

This is a wrapper around `set_package_properties` to make it consistent with
other CMake commands. Instead of requiring users to remember to pass in the
`PROPERTIES` keyword argument prior to the actual properties, users can simply
pass them in directly as if they were normal keyword arguments.

### Example

```cmake
cmake_language(CALL ixm::package::properties
  URL https://example.com
  DESCRIPTION "Describing the current package"
  PURPOSE "This package has a purpose"
  TYPE OPTIONAL)
```
