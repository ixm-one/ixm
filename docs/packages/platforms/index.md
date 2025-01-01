---
title: Platforms
---

IXM provides a quite a few "platform" package modules. These provide `IMPORTED`
targets to represent either individual libraries that are part of the standard
distribution for platform development (e.g., `NetBSD::PacketCapture`), a group
of libraries for targeting specific API groups (e.g., the
`Windows::MediaFoundation` target), or "shim" libraries to work around
non-existent libraries so that code can remain the same everywhere (e.g.,
providing a `Threads::Threads` target on Android).

While these are not technically necessary when targeting a platform, especially
when developing *on* said platform, they are *most* useful if cross compiling
for a given platform. Each package found in this section can be "re-rooted" by
setting `<platform-name>_ROOT` as a cache variable to a system root.
