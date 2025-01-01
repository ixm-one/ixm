---
title: Properties
order: 2
---

# Properties

## Globals

### Internals

`🈯::ixm::supports::hyperlinks` {#reserved-ixm-supports-hyperlinks}
: This property is set (and used internally) if IXM was able to determine if
  the current executing environment supports ANSI escape sequences to render
  hyperlinks.
: This property can be forced to `TRUE` or `FALSE` with the
  `IXM_SUPPORTS_HYPERLINKS` cache variable.

`🈯::ixm::supports::unicode` {#reserved-ixm-supports-unicode}
: This property is set (and used internally) if IXM was able to determine if
  the current executing environment is capable of rendering unicode characters.
  This allows IXM to use emoji in some use cases.
: This property can be forced to true or false with the `IXM_SUPPORTS_UNICODE`
  cache variable.
