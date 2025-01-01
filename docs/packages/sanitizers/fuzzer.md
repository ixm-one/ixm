---
title: Fuzzer
---

# libFuzzer

Per LLVM's documentation, libFuzzer "is an in-process, coverage-guided,
evolutionary fuzzing engine". For information on using libFuzzer itself, see
the [LLVM documentation](https://llvm.org/docs/LibFuzzer.html) on its use.

## Targets

Unlike most other sanitizers, this component *does not* provide an `ALIAS`.

`Sanitizer::Fuzzer`
: Provides the necessary compiler and linker flags to build against libFuzzer.
