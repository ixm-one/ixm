---
title: clang-tidy
---

# Clang Tidy

This module provides a way to find (and use) `clang-tidy` as an `IMPORTED`
executable target. This can then be used to set the `CMAKE_<LANG>_CLANG_TIDY`
variable, or for the properties the variable sets.

This package also defines a new custom property to ensure that values are
correctly joined by default when passing additional options into `clang-tidy`.

## Usage

To get the most out of this module, it's encouraged that users rely primarily
on *generator expressions* when setting the `clang-tidy` related properties.
Additionally, when setting or appending to the property, it's important that
users *append strings*.

```cmake
find_package(clang-tidy)
```

## Examples

Setting the `CMAKE_CXX_CLANG_TIDY` variable is usually enough if a user's clang
tidy configuration is simple.

```cmake
find_package(clang-tidy)

if (TARGET clang::tidy)
  set(CMAKE_CXX_CLANG_TIDY $<TARGET_PROPERTY:clang::tidy,IMPORTED_LOCATION>)
endif()
```

However, sometimes users may want to append additional settings for a given
target:

```cmake
set_property(TARGET ${my-target} APPEND_STRING
  PROPERTY
    CXX_CLANG_TIDY " --checks=readability-identifier-naming")
```

This can however end up causing issues as it's easy to forget to prepend a
space before the new values. Instead, one can set the `<LANG>_CLANG_TIDY`
property to join the IXM defined property `<LANG>_CLANG_TIDY_OPTIONS` as a
default, and append values from there.

```cmake
string(CONCAT CMAKE_CXX_CLANG_TIDY
  $<TARGET_PROPERTY:clang::tidy,IMPORTED_LOCATION>
  " "
  "$<JOIN:$<TARGET_PROPERTY:CXX_CLANG_TIDY_OPTIONS>, >"
)

set_property(TARGET ${my-target} APPEND
  PROPERTY
    CXX_CLANG_TIDY_OPTIONS --checks=readability-identifier-naming)
```

Further generator expressions can be used to expand upon this feature in a more
powerful way.
