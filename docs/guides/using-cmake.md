---
title: Using CMake
order: 2
---

# Using CMake

In recent years, the CMake CLI has improved a great deal, providing a large
amount of usability improvements and improving general user workflow. Despite
this, not all users might be up to date and as a result might take unnecessary
steps, or even suggest unnecessary steps to passersby, in their project's build
instructions.

This guide gives a small and brief overview of how to improve CMake's
usability, regardless of whether you operate on the CLI, an editor like VSCode
or Neovim, or an IDE like Visual Studio.

## Using the CLI

It may come as a surprise to many users, but the `cmake` executable tool
provides a swath of usability for everyday use beyond *just* running a
configure step. It's recommended users read the [documentation][cmake-cli] for
more detail, however this section will provide a basic rundown on common
features. The first of these are the `-S` and `-B`, which are used to set the
`CMAKE_SOURCE_DIR` and `CMAKE_BINARY_DIR` when running a configuration.

The `-S` flag is optional, as CMake is typically run from the location of the
top-level CMakeLists.txt file, however it can come in handy if you want to be
explicit.

Conversely, the `-B` flag is *always* set, and by default uses the current
working directory. By setting it to the path a user wishes to be the build
directory, they can avoid the `mkdir`, `cd` and `cmake ..` set of commands most
users are given in instructions by other projects.

In other words, it is no longer necessary to do the following commands:

```console
$ mkdir build
$ cd build
$ cmake ..
```

and instead users can simply do

```console
$ cmake -Bbuild -S.
```

And achieve the same effect.

Additionally, instead of having to execute your specific build tool, you can
execute it via [`cmake`'s `--build` option][--build], and CMake will detect and then execute
the correct build tool based on your prior configuration. For example, if a
developer used Xcode as their generator:

```console
$ cmake -Bbuild -S. -G "Xcode"
```

This would typically be executed from the commandline with `xcodebuild`

```console
$ cd build
$ xcodebuild
```

However, users can simply pass the build directory they wish to target (as well
as any additional flags they might want, such as `--target` or `--config`) and
CMake will execute `xcodebuild` for the user:

```console
$ cmake --build build
```

This is highly advantageous as it allows users to use the same commands across
multiple machines but does not require them to worry about specific build tools
and their flags except in extreme cases.

## Presets

[CMake Presets][cmake-presets] are a powerful feature that was added in CMake
3.19 and has steadily been added to in nearly every CMake release since. This
allows users to share common configure, build, test, and package project
ettings with each other, as well as with CI/CD systems. Not only this, but
several tools have adopted CMake presets for use in IDEs and editors such as
[VS Code][vs-code], [Visual Studio 2022][vs-2022], [CLion][clion], and there
are plugins for editors like [neovim][neovim].

It is *highly* recommended that users of IXM also take advantage of CMake
presets to set IXM specific configuration options across all configurations
*without* having to tell other users what settings to pass in.

### Using Presets

### Workflows

One additional aspect of CMake presets are so-called *workflow* presets. This
allows for multiple configure and build steps to be executed in sequence (*not
in parallel*). The most useful aspect of a CMake workflow preset is a "fire and
forget" sequence allowing someone to download a CMake based project and then
configure, build, test, and package said project without having to know what
step to take next.

## Generators

The most important aspect of CMake's usability are its generators (not to be
confused with *generator expressions*, which are [discussed in a separate
guide](./generator-expressions.md)), such as Ninja, Xcode, and Visual Studio.

In recent years, many developers have adopted Ninja for it's speed and
efficiency over alternative build tools. In fact, Visual Studio's "Open Folder"
CMake feature allows the use of Ninja while still providing all the usability
of Visual Studio as an IDE. One thing to note, is that there is also a *Ninja
Multi-Config* generator which allows the generation of multiple configurations
in a single configuration run. This generator *is as fast* as the basic
single-configuration Ninja generator, and so for quickly switching between
build configurations it is recommended to use the *Ninja Multi-Config*
generator.

[cmake-presets]: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html
[cmake-cli]: https://cmake.org/cmake/help/latest/manual/cmake.1.html
[--build]: https://cmake.org/cmake/help/latest/manual/cmake.1.html#build-a-project

[neovim]: https://github.com/Civitasv/cmake-tools.nvim
[clion]: https://www.jetbrains.com/help/clion/cmake-presets.html
[vs-2022]: https://learn.microsoft.com/en-us/cpp/build/cmake-presets-vs
[vs-code]: https://github.com/microsoft/vscode-cmake-tools
