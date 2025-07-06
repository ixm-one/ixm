---
title: JACK
---

# JACK

This module provides a way to find and use the JACK Audio Connection Kit.

> [!NOTE]
> This module only works with the JACK2 set of libraries and dependencies.
> It does *not* support JACK1. If you are having trouble finding JACK, check
> that your system's package manager has not installed the wrong package.

This module provides a default set of targets for finding JACK2 specifically,
and does *not* support the now deprecated JACK1. This is due to improved
support across operating systems, and because of the change in expected
libraries and their dependencies.


## Targets

This module provides several library targets and one executable target. It does
not provide an interface for the Qt based JACK control tool.

`JACK::JACK` {#jack-jack}
: The default JACK client library. 99% of the time, this is what you'll need.

`JACK::Client` {#jack-client}
: An alias for `JACK::JACK`, intended to be a counterpart to `JACK::Server`.

`JACK::Network` {#jack-network}
: The JACK library for the `net` backend used by `JACK`.

`JACK::Net` {#jack-net}
: An alias for `JACK::Network`

`JACK::Server` {#jack-server}
: The JACK library to let a program act as a JACK server.

`JACK::Daemon` {#jack-daemon}
: The executable `jackd` as an `IMPORTED` executable target.

## Usage

```cmake
find_package(JACK OPTIONAL_COMPONENTS Daemon)
```
