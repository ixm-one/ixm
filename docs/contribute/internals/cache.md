---
title: Cache Variables
order: 4
---

# Cache Variables

This section details the cache variables IXM sets internally. Some of these are
declared `INTERNAL`. Others, are overrides of CMake variables, or undocumented
variables that affect CMake's execution environment.

`IXM_FILES_DIR` {#ixm-files-dir}
: Path pointing under the `CMAKE_BINARY_DIR` where IXM will generate build-wide
  or project specific temporary files. This is mostly an analogue to the
  `CMakeFiles` directory found under a configured build.

`IXM_ROOT_DIR` {#ixm-root-dir}
: Path to the directory where the main IXM CMakeLists.txt file is located. This
  is more or less the downloaded IXM repository.
