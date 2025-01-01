---
title: OpenBSD
---

# OpenBSD

> [!IMPORTANT]
> This `find_package` module is currently marked as experimental

For more information visit the [OpenBSD man
pages](https://man.openbsd.org/intro.3).

## Components

Nearly every component for this package has a `<Component>.Profile` equivalent
that automatically adds the correct profiling flags to anything that links
against it, and is setup for proper profiling.

Additionally, each component creates at least *one* `IMPORTED` target. In some
cases, there may be an `ALIAS` target. (e.g., `OpenBSD::ExecInfo` is an `ALIAS`
to `OpenBSD::Backtrace`.

> [!WARNING]
> Not all libraries are available via components. Some libraries are considered
> implicit, *or* aren't provided due to deprecation in favor of "newer" system
> libraries. Check the list of `IMPORTED` targets below if you are unsure of
> any missing features.

## Targets

`OpenBSD::Agentx`
: AgentX client library. Used for applications to export metrics to AgentX
  capable snmp daemons
: See [agentx(3)](https://man.openbsd.org/agentx.3)

`OpenBSD::CBOR`
: An implementation of the Concise Binary Object Representation (CBOR) encoding
  format defined in RFC 7049.

`OpenBSD::Crypto`
: Provides functionality such as symmetric encryption, public key cryptography,
  digests, message authentication codes, and certificate handling.
: See [crypto(3)](https://man.openbsd.org/crypto.3)

`OpenBSD::Curses`
: See [curses(3)](https://man.openbsd.org/curses.3)

`OpenBSD::Edit`
: Generic line editing and history functions, similar to those found in sh(1).
  Dependents of this library will also link against `OpenBSD::Curses`.
: See [editline(3)](https://man.openbsd.org/editline.3)

`OpenBSD::ELF`
: Library routines for manipulating ELF objects.
: See [elf(3)](https://man.openbsd.org/elf.3)

`OpenBSD::Event`
: Provides a mechanism to execute a function when a specific event on a file
  descriptor occurs or after a given time has passed.
: See [event(3)](https://man.openbsd.org/event.3)

`OpenBSD::Backtrace`
: Library providing backtrace functions.
: See [backtrace(3)](https://man.openbsd.org/backtrace.3)
: Alias: `OpenBSD::ExecInfo`

`OpenBSD::Expat`
: Library routines for parsing XML documents.

`OpenBSD::FIDO2`
: Library for communication with U2F/FIDO2 devices over USB.

`OpenBSD::Form`
: Terminal-independent facilities for composing form screens on character-cell
  terminals. Dependents of this library will also link against
  `OpenBSD::Curses`.
: See [form(3)](https://man.openbsd.org/form.3)

`OpenBSD::Fuse`
: File system in userland library.
: See [fuse_main(3)](https://man.openbsd.org/fuse_main.3)

`OpenBSD::Keynote`
: See [keynote(3)](https://man.openbsd.org/keynote.3) and
  [keynote(4)](https://man.openbsd.org/keynote.4)

`OpenBSD::KVM`
: See [kvm(3)](https://man.openbsd.org/kvm.3)

`OpenBSD::Math`
: This is the C math library.

`OpenBSD::Menu`
: Dependents on this library will also link against `OpenBSD::Curses`.
: See [menu(3)](https://man.openbsd.org/menu.3)

`OpenBSD::Panel`
: Dependents on this library will also link against `OpenBSD::Curses`.
: See [panel(3)](https://man.openbsd.org/panel.3)

`OpenBSD::PacketCapture`
: See [pcap_open_live(3)](https://man.openbsd.org/pcaop_open_live.3)

`OpenBSD::Radius`
: See [radius_new_request_packet(3)](https://man.openbsd.org/radius_new_request_packet.3)

`OpenBSD::Readline`
: See [readline(3)](https://man.openbsd.org/readline.3)

`OpenBSD::RPC`
: See [rpc(3)](https://man.openbsd.org/rpc.3)

`OpenBSD::SKey`
: See [skey(3)](https://man.openbsd.org/skey.3)

`OpenBSD::SoundIO`
: See [sio_open(3)](https://man.openbsd.org/sio_open.3)
: See [audio(4)](https://man.openbsd.org/audio.4)
: See [sndiod(8)](https://man.openbsd.org/sndiod.8)

`OpenBSD::HID`
: See [usbhid(3)](https://man.openbsd.org/usbhid.3)
