---
title: Safe Stack
---

# Safe Stack

SafeStack is an instrumentation pass that protects programs against attacks
based on stack buffer overflows, without introducing any measurable performance
overhead. More information on its use can be found in its
[documentation](https://clang.llvm.org/docs/SafeStack.html)

## Targets

`Sanitizer::SafeStack`
: Provides the necessary compiler and linker options to use SafeStack.
