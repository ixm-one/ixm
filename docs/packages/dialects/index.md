---
title: Dialects
next:
  text: Exceptions
  link: /packages/dialects/exceptions
---

# Dialects

IXM provides a `Dialects` package that allows users to link against `INTERFACE`
`IMPORTED` libraries to allow users to turn on or off various C++ language
dialect features, such as <abbr title="Run-time Type Information">RTTI</abbr>,
Exceptions, fast math optimizations, or turning off the C++ standard library
entirely. Some of these dialects can be combined together. Detailed information
for each component can be found on their respective pages.

> [!NOTE]
> Some C++ programmers might argue that there simply are no dialects in C++.
> These people are wrong, and should be told they are wrong, as these compiler
> specific features result in users having to write code in a specific way that
> changes how they approach C++ as a programming language. To refuse to
> acknowledge this is foolish.

> [!IMPORTANT]
> This component currently *only* works with C++ projects. It does not work
> with C++-like languages such as:
> 
> - CUDA
> - ObjC++
>
> Support for these languages may be added in the future. Until then, this
> package will fail to find *any* components under the following circumstances:
>
> - `CMAKE_CXX_COMPILER_ID` is empty.
> - `CMAKE_CXX_COMPILER_ID` is not one of GCC, Clang, or MSVC.

## Example Usage

In this example, we are explicitly setting [`Exceptions`](./exceptions) to be
turned off, and [`RTTI`](./rtti) to be turned on.

```cmake
find_package(Dialect REQUIRED COMPONENTS Exceptions RTTI)
target_link_libraries(MyTarget
  PRIVATE
    Dialect::Exceptions::Off
    Dialect::RTTI::On)
```
