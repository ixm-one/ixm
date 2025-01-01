---
title: Basic
order: 1
---

# Basic Mixin

The so-called Basic mixin provides a set of useful defaults for projects. It is
intended for projects that do not have difficult build requirements and only
export one target, and do not have specific platform requirements. Typically
this is a directory layout in the following style:

```console {.output}
$ tree .
.
├── docs (optional)
├── include
│   └── <project-name>
│       ├── file.hpp
│       └── path.hpp
├── src (optional)
│   ├── main.cpp (optional)
│   ├── file.cpp
│   └── path.cpp
└── tests (optional)
    ├── file.cpp
    └── path.cpp
```

This layout allows for an intelligent detection of a project's type, and will
automatically create a single target with the name `${PROJECT_NAME}`. 

## Automatic Target Type Detection

The conditions for changing the project's "type" is as follows:

1. If no `src/` directory is detected, the target is created via
   `add_library(INTERFACE)`
2. If there is no file under `src/` whose *stem* (i.e., the part without the
   file extension) is exactly `main`, then the target is created via
   `add_library(STATIC)`.
3. If there is *exactly* one file under `src/` whose *stem* is exactly `main`,
   then the target is created with `add_executable()`.

Obviously, these use cases do not work for everyone.
