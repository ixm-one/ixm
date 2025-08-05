---
title: Installation
order: 1
---

# Installation

IXM is intended to be used via `add_subdirectory`. How this is achieved is up
to you, the user. However, the simplest and easiest way to get started is to
use CMake's [FetchContent][1] module. This allows users to be able to get the
same version of IXM when needed, while still allowing users to vendor IXM
themselves, pin to tags or specific git commits, test feature branches, and
more.

## Acquiring CMake

IXM is, obviously, quite useless without  CMake installed. If CMake is already
installed on your system, you can skip to [Acquiring IXM](#acquiring-ixm).

CMake comes with a variety of installers, and while it's instructions are
fairly simple, there are some additional options or notes that users can take
into account.

### Via GitHub Releases

Kitware uses GitHub's release system to release prebuilt packages fit for
installation on Windows, macOS, and Linux. These can be acquired
[here](https://github.com/Kitware/CMake/releases).

### Via Python Packages

Thanks to the work of the [@scikit-build](https://github.com/scikit-build)
organization, it is possible to install CMake (and Ninja!) via the python
package manager `pip`.

```console
$ pip install cmake ninja
```

However, this *does* install them to the system, active virtual environment, or
user's `site-packages` directory. To keep these installations separated from
any virtual environments or from your global python installation, it's
recommended to instead use [pipx](https://pipx.pypa.io/) to actually perform
the installation.

### Ubuntu Based Systems

As of CMake 3.14, Kitware has begun maintaining an `apt` repository. Directions
on installing CMake this way can be found [here][2]. However, the instructions
provided are a bit out of date for modern tooling. Instead, the author of IXM
recommends you perform the following operations instead:

```console
$ sudo curl -OL https://apt.kitware.com/keys/kitware-archive-latest.asc \
    --output-dir /etc/apt/trusted.gpg.d/
$ echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" | \
    sudo tee --append /etc/apt/sources.list.d/kitware.list
$ sudo apt update
$ sudo apt install cmake
```

This approach permits users to not have to "dearmor" the
`kitware-archive-latest.asc` key. `apt` (and `apt-get` will automatically
handle the GPG "armor" format without issue as long as the file was placed into
the correct directory.

#### DEB822

We can also rely on the [DEB822][3] format that is used by various aspects of
Debian's packaging format. Create a file named `kitware.sources` under
`etc/apt/sources.list.d` and place the following key-value pairs within:

```yaml
Types: deb
URIs: https://apt.kitware.com/ubuntu
Suites: <distribution-here>
Components: main
```

This approach is a bit easier to add additional fields to further harden a
configuration. Users are free to read [sources.list(5)][4] for more
information.

> [!NOTE]
> Debian based distributions of Linux are [beginning to move to the DEB822
> format](https://github.com/linuxmint/mintsources/issues/236). It is for this
> reason that we recommend the use of DEB822 over the single line entry format
> for a `sources.list` file.

#### Docker Containers

When constructing an ubuntu or debian based container, several additional
packages might be installed alongside CMake that might not be desired. To help
improve this (and reduce the amount of `--no-install-recommends` flags when
using `apt-get` in `RUN` commands), users can write a configuration file to
`/etc/apt/apt.conf.d/` that will speed up the CMake installation steps:

```perl
APT {
  Install-Recommends "false";
  Get {
    Assume-Yes "true";
  }
}
```

## Acquiring IXM

As mentioned above, IXM can be installed in several ways. The easiest of which
is using [FetchContent][1].

### FetchContent

To install IXM for a project, simply place the following at the top of your
root `CMakeLists.txt` file:

```cmake
cmake_minimum_required(VERSION 3.30)
include(FetchContent)
FetchContent_Declare(ixm URL https://get.ixm.one)
FetchContent_MakeAvailable(ixm)
```

## Updating IXM

`FetchContent` does not automatically update `URL` dependencies to latest
unless the value passed to `URL` has changed. This means that IXM will *not*
always update locally. To force an update on IXM, simply delete the `ixm-src`
directory within your `FETCHCONTENT_BASE_DIR`. By default, this is
`${CMAKE_BINARY_DIR}/_deps`, but can be changed by setting the
`FETCHCONTENT_BASE_DIR` variable.

> [!NOTE]
> If keeping IXM updated on a regular basis is desired, it might be easier to
> use the `GIT_REPOSITORY` and `GIT_TAG` fields for `FetchContent_Declare`,
> where `GIT_TAG` is a branch name (such as `main`) or any other value
> mentioned in the [Pinning IXM](#pinning-ixm-via-fetchcontent) section.

### Pinning IXM via FetchContent

It is understandable that users would want to keep IXM pinned to a specific
version, and thus forego "Living at HEAD". For this reason, any `git` revision
parseable string can be appended to the end of the `URL` in
`FetchContent_Declare`, so that even if IXM updates, users will only download
from a specific location.

::: code-group
```cmake [Branch]
FetchContent_Declare(ixm URL https://get.ixm.one/next)
```

```cmake [Git Revision]
FetchContent_Declare(ixm URL https://get.ixm.one/ba5eba11)
```

```cmake [Git Tag]
FetchContent_Declare(ixm URL https://get.ixm.one/v3.31)
```
:::

## Versioning Policy

IXM does not currently have a "set in stone" versioning policy, as we are
currently only at our initial release. However, the currently planned approach
for IXM is to do the following:

1. Versioned releases will coincide with CMake releases when possible (e.g.,
   IXM 3.30 will work with CMake 3.3.0)
2. Bugfixes will be backported when possible and version tags will be updated.

One alternative approach that might occur in the future is to use Calendar
Versioning, so releases are tied to a specific *date*, allowing users to know
how old a release is if a dependency is using IXM.

[1]: https://cmake.org/cmake/help/latest/module/FetchContent.html
[2]: https://apt.kitware.com/
[3]: https://manpages.ubuntu.com/manpages/jammy/en/man5/deb822.5.html
[4]: https://manpages.ubuntu.com/manpages/jammy/en/man5/sources.list.5.html
