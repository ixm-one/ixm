---
title: Data Flow
---

# Data Flow Sanitizer

The LLVM data flow sanitizer is a generalized dynamic data flow analysis
sanitizer tool. Unlike other sanitizers, it is not designed to detect a
specific class of bugs on its own. Instead, it provides a generic dynamic data
flow analysis framework to be used by clients to help detect application
specific issues within their own code. For more information on it's use, see
the [DataFlowSanitizer](https://clang.llvm.org/docs/DataFlowSanitizer.html)
page provided by LLVM's documentation.

## Targets

`Sanitizer::DataFlow`
: Provides the necessary compiler and linker flags to use the data flow
  sanitizer.

`Sanitizer::DFSan`
: An alias for `Sanitizer::DataFlow`
