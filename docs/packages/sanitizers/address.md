---
title: Address
---

# Address Sanitizer

This component provides all necessary information for the Address Sanitizer.

## Targets

`Sanitizer::Address`
: Provides the necessary compiler and linker flags to use the address sanitizer

`Sanitizer::ASan`
: An alias for `Sanitizer::Address`

## Properties

`SANITIZER_ASAN_USE_PRIVATE_ALIASES`
: Use private aliases for global objects.

`SANITIZER_ASAN_GLOBALS`
: Detect overflow/underflow for global objects.

`SANITIZER_ASAN_STACK`
: Detect overflow/underflow for stack objects.
