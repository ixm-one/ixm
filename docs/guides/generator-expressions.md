---
title: Generator Expressions
order: 4
description: An opionated guide on the use of generator expressions in CMake.
---

# Generator Expressions

CMake provides a powerful construct known as a [generator expression][genexpr].
Unfortunately, their documentation leaves a lot to be desired and does little
to explain *why* one would even bother to use generator expressions over raw
CMake scripts.

This section will explain the *why*, and to act as a supplement to CMake's
documentation. Additionally, it will provide more useful code samples of
generator expressions that have been put into production, and influenced IXM's
design.

## Why Use Them?

To answer this question, we need to understand the "execution contexts" a
typical CMake execution will perform. Namely these are *configure* and
*generate*, wherein CMake *generates* the files necessary for your build system
to execute. The biggest issue CMake has, is that its *configure* stage is
single threaded. However, it's *generate* stage is able to perform
multithreading.

As a result, CMake's generator expressions can be viewed as a very weird syntax
for pure functional programming during the generation stage. This might be hard
to grasp. However, when looking at the APIs for generator expressions provided
to users by CMake, we see that generator expressions:

1. Cannot mutate values. They can only return new objects.
2. They cannot read from the configuration state, or the machine's state.

In other words, if you treat generator expressions as "Lisp S-expressions, but
worse", you will have an easier time of understanding their behavior.

The more interesting aspect of all of this, however, is that it allows
developers of complex CMake based projects to provide basic
`set_property(TARGET)` values for users that can then turn into more complex
operations or API calls, while not slowing the build system down.

## When To Use?

At first glance, it might not seem obvious *when* to use a generator
expression. Thankfully, the answer is quite simple: Anything that *can* be
calculated at the *generation* step of CMake *should*. Only in rare cases will
users discover that a property for a target *cannot* be set or calculated with
a generator expression.

Additionally, generator expressions are able to be used as parameters to *some*
constructs such as `target_sources`, `add_custom_target`, and
`add_custom_command`, as well as commands such as `file(GENERATE)`, where a
generator expression will execute at generation time and participate in target
dependency validation (i.e., the generation step will *fail* if the file was
not generated correctly).

Sometimes users can provide custom property settings for an already existing
generator expression. For example, `gcc` and `clang` support a `-Wformat` flag
that takes the value of an integer. If someone were writing boilerplate to
create a target and set some defaults for downstream users, they could expose a
property on these targets. This is a better approach than having users remember
exactly *what* `-Wformat` value to use, and explicitly requiring them to set it
in all cases.

For example, if we defined the following code

```cmake
function (add_boilerplate_library name)
  # We're using this `set()` call here to reduce the width of the code
  # shown.
  set(is-gnu $<COMPILE_LANG_AND_ID:CXX,AppleClang,Clang,GNU>)
  add_library(${name})
  target_include_directories(${name}
    PUBLIC
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    PRIVATE
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>)
  target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_23)
  target_compile_options(${PROJECT_NAME}
    PRIVATE
      $<${is-gnu}:-Wformat=$<TARGET_PROPERTY:WARN_FORMAT>>)
  set_property(TARGET ${PROJECT_NAME} PROPERTY WARN_FORMAT 0)
endfunction()
```

Then downstream users could simply do the following:

```cmake
add_boilerplate_library(${PROJECT_NAME})
# Users can now override the `WARN_FORMAT` property.
set_property(TARGET ${PROJECT_NAME} PROPERTY WARN_FORMAT 2)
```

This type of usage is discussed in more detail below under [Custom
Properties](#custom-properties), as there are some edge cases developers should
be aware of when writing boilerplate functions like above, as well as "best
behavior" that should be followed when using custom target properties.

> [!TIP]
> The `install()` command also has some fields that support generator
> expressions. This means users can configure *some* `install()` behavior even
> if that behavior is not exposed to them explicitly, but doesn't require them
> to have full knowledge of how to call `install()`.

## Multi-line Expressions

As CMake states in the [Whitespace and Quoting][ws] section in the generator
expression documentation, generator expressions are parsed after command
arguments. As a result, placing a space or some other command argument
separator can cause CMake and the generator expression to fail entirely.

CMake's documentation alludes that users must instead quote their expressions,
or in some cases assign them to variables to avoid these issues. Storing
expressions in variables can save time and mental overhead. However they still
suffer from the same multi-line value issue, and thus complex generator
expressions can quickly get out of hand.

For example, the mental overhead required to "unroll" the generator expressions
displayed in the documentation is quite large:

```cmake
set(is_gnu "$<CXX_COMPILER_ID:GNU>")
set(v5_or_later "$<VERSION_GREATER_EQUAL:$<CXX_COMPILER_VERSION>,5>")
set(meet_requirements "$<AND:${is_gnu},${v5_or_later}>")
target_compile_definitions(tgt PRIVATE
  "$<${meet_requirements}:HAVE_5_OR_LATER>"
)
```

However, CMake actually provides a way to write these generator expressions in
a more simple manner through the use of `string(CONCAT)`. The following is a
real world source code example of IXM using `string(CONCAT)` for a more complex
generator expression:

```cmake
string(CONCAT gnu/clang+languages $<OR:
  $<COMPILE_LANG_AND_ID:OBJCXX,GNU,Clang>,
  $<COMPILE_LANG_AND_ID:OBJC,GNU,Clang>,
  $<COMPILE_LANG_AND_ID:CXX,GNU,Clang>,
  $<COMPILE_LANG_AND_ID:C,GNU,Clang>
>)

string(CONCAT clang+languages $<OR:
  $<COMPILE_LANG_AND_ID:OBJCXX,Clang>,
  $<COMPILE_LANG_AND_ID:OBJC,Clang>,
  $<COMPILE_LANG_AND_ID:CXX,Clang>,
  $<COMPILE_LANG_AND_ID:C,Clang>
>)

set(stack $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_ASAN_STACK>>>)

target_compile_options(Sanitizer::Address
  INTERFACE
    $<$<AND:${clang+languages},$<NOT:${stack}>>:-mllvm$<SEMICOLON>-asan-stack=0>
    # ...
    $<$<AND:${gnu+languages},$<NOT:${stack}>>:--param$<SEMICOLON>asan-stack=0>)

```

This would be much harder (and much longer) to write using the "one `set()` per
line/expression" approach CMake's own documentation recommends.

> [!NOTE]
> Not all syntax highlighters and parsers are able to understand generator
> expressions when written in this way.

## Custom Properties

CMake makes it fairly simple for a developer or user to create a custom target
property. It is as simple as just *setting* the property directly on the
target. However, this doesn't guarantee that the property will exist or be set
in all cases, and it doesn't provide for a non-property based "default
initialization" setting that most other CMake properties support. For this
reason, users should turn to [`define_property`][define-property], a CMake
command available when CMake is executing over a project.

This command allows users to set the "scope" of a property, whether it is
inherited from parent scopes, and it's initial value based on a variable.
Information on how property scoping and inheritance work can be found in the
Properties section of [Writing Scripts](./writing-scripts#properties).

As mentioned previously in [When To Use?](#when-to-use), there are edge cases
developers need to be aware of when using custom properties and using said
properties in "chains" of generator expressions.

Let's use the prior example of the `-Wformat` compile option.

```cmake
target_compile_options(${PROJECT_NAME}
  PRIVATE
    $<${is-gnu}:-Wformat=$<TARGET_PROPERTY:WARN_FORMAT>)
```

As defined above, if we were to set the property with *another* generator
expression, this would cause a compiler failure.

```cmake
set_property(TARGET ${PROJECT_NAME}
  PROPERTY
    WARN_FORMAT $<TARGET_PROPERTY:MY_CUSTOM_PROPERTY>)
```

The reason is that CMake does not know that it needs to perform a second
generator expression evaluation. Thankfully this is easily resolved with the
use of the two "multi level expression evaluation" expressions,
`$<TARGET_GENEX_EVAL>` and `$<GENEX_EVAL>`. These expressions can be nested
nearly ad infinitum, so if you would like to permit inputs to be a generator
expression themselves, simply use them whenever possible.

```cmake
target_compile_options(${PROJECT_NAME}
  PRIVATE
    $<${is-gnu}:-Wformat=$<GENEX_EVAL:$<TARGET_PROPERTY:WARN_FORMAT>>>)
```

Those with some familiarity of generator expressions might notice we've been
using the `$<TARGET_PROPERTY:property>` form instead of
`$<TARGET_PROPERTY:tgt,property>`. This form evaluates the generator expression
directly on the *consumer* of the generator expression, rather than on the
target it was *set* on. Typically, if you're using properties that you want to
exist on a per-target basis, you'll want to use monadic version. However, if
the behavior you run into is surprising, stick with the
`$<TARGET_PROPERTY:tgt,PROPERTY>` signature, or better yet simply use
`define_property` with an `INITIALIZE_FROM_VARIABLE` parameter.

```cmake
define_property(TARGET
  PROPERTY WARN_FORMAT
  INHERITED # Mark as inherited so setting the property
            # at the global or directory scope sets the default.
  BRIEF_DOCS "Value to pass to -Wformat"
  INITIALIZE_FROM_VARIABLE ${PROJECT_NAME}_WARN_FORMAT)
set(${PROJECT_NAME}_WARN_FORMAT 2)

add_library(${PROJECT_NAME})
# Later on, we declare how the target will interact with this warning
target_compile_options(${PROJECT_NAME}
  PRIVATE
    $<${is-gnu}:-Wformat=$<GENEX_EVAL:$<TARGET_PROPERTY:WARN_FORMAT>>>)
```

However, remember that we can also affect properties at the directory scope for
compile options, either by using `add_compile_options` or setting the property
manually, including the `INTERFACE_COMPILE_OPTIONS` properties.

```cmake
define_property(TARGET
  PROPERTY WARN_FORMAT
  INHERITED
  BRIEF_DOCS "Value to pass to -Wformat"
  INITIALIZE_FROM_VARIABLE ${PROJECT_NAME}_WARN_FORMAT)
set(${PROJECT_NAME}_WARN_FORMAT 2)

string(CONCAT warn-format $<${is-gnu}:
  -Wformat=$<GENEX_EVAL:$<TARGET_PROPERTY:WARN_FORMAT>>
>)

# We typically don't want warnings to be "viral" for dependents,
# so we *don't* set the `INTERFACE_COMPILE_OPTIONS` property here.
set_property(DIRECTORY APPEND
  PROPERTY
    COMPILE_OPTIONS "${warn-format}")

# All targets declared after this point in this directory will now
# have their `WARN_FORMAT` property set to `2`, and have the
# `-Wformat` flag added to them.
add_library(${PROJECT_NAME})

```

## Targets and Commands

Generator expressions come most in handy when working with `add_custom_target`
and `add_custom_command`. This allows users to configure how a command might
execute, while allowing users to set or modify the settings without having to
have all the answers up front when creating a custom command or calling a
function.

For example, CMake provides a `find_package(MODULE)` for protobuf. This module
provides a function, [`protobuf_generate`][protobuf-generate] that provides
nearly every configurable function as a named argument. However, there's
nothing stopping someone from writing a version of this that relies on
generator expressions instead, and then places the generated files *directly*
onto the target.

> [!NOTE]
> This example is massively simplified compared to what the actual
> `protobuf_generate` command CMake provides does, and does not take into
> account things like making sure the `PROTOBUF_OUTPUT_DIR`exists prior to
> execution, as the protobuf compiler does not create `--cpp_out` and other
> `_out` directory.

First, we can allow for a custom output directory to exist for a given target
by checking if a property exists or is set with a non-false value, and then
supply our own fallback:

```cmake
function (target_protobuf_generate target)
  # We imitate `target_sources` but can't really do
  # PUBLIC and INTERFACE without this example increasing
  # in complexity.
  cmake_parse_arguments(ARG "" "PRIVATE" "" ${ARGN})
  # Users can optionally set a custom output directory
  # If they don't *we* provide a fallback
  string(CONCAT output-dir $<IF:
    $<BOOL:$<TARGET_PROPERTY:${target},PROTOBUF_OUTPUT_DIR>>,
    $<TARGET_PROPERTY:${target},PROTOBUF_OUTPUT_DIR>,
    $<TARGET_PROPERTY:${target},BINARY_DIR>
  >)

  # Shortcuts for the property lookups
  set(proto.options $<TARGET_PROPERTY:${target},PROTOBUF_OPTIONS>)
  set(proto.plugins $<TARGET_PROPERTY:${target},PROTOBUF_PLUGINS>)
  set(proto.paths $<TARGET_PROPERTY:${target},PROTOBUF_PATHS>)

  # Where we "combine" the various multiple arguments
  set(plugins --plugin=$<JOIN:${proto.plugins},$<SEMICOLON>--plugin=>)
  set(paths --proto_path=$<JOIN:${proto.path},$<SEMICOLON>--proto_path=>)
  set(options $<JOIN:${proto.options},$<SEMICOLON>>)

  set(sources)
  foreach (source IN LISTS ARG_PRIVATE)
    set(basename $<PATH:GET_FILENAME,${source}>)
    set(depfile $<PATH:APPEND,${output-dir},${basename}.d>)

    # C++ source names are thankfully always the same.
    set(generated-source $<PATH:APPEND,${output-dir},${basename}.pb.cc>)
    set(generated-header $<PATH:APPEND,${output-dir},${basename}.pb.h>)

    add_custom_command(
      OUTPUT
        "${generated-source}"
        "${generated-header}"
      COMMAND protobuf::protoc
        "--cpp_out=${output-dir}"
        "--dependency_out=${depfile}"
        $<GENEX_EVAL:${paths}>
        $<GENEX_EVAL:${plugins}>
        $<GENEX_EVAL:${options}>
        "${source}"
      DEPFILE "${depfile}"
      MAIN_DEPENDENCY "${source}"
      DEPENDS $<TARGET_PROPERTY:${target},PROTOBUF_DEPENDS>
      COMMENT "Compiling protobuf descriptor ${source}"
      COMMAND_EXPAND_LISTS
      VERBATIM
      # Because this is a code generator step we can also force it to be
      # generated and check intermediate stages by using the `codegen`
      # target provided by CMake.
      CODEGEN
    )
    list(APPEND sources "${generated-source}")
  endforeach()

  # One might want to use a FILE_SET for the headers
  # But that is a different story.
  target_include_directories(${target}
    PRIVATE
      $<BUILD_INTERFACE:${output-dir}>)
  target_sources(${target} PRIVATE ${sources})
endfunction()
```

Now a module can provide `target_proto_XXX` commands for setting the
`PROTOBUF_` properties mentioned in the command above, or users can set/modify
them themselves.

Users could go a step further and implement a `target_grpc_generate` command to
handle both the protobuf and grpc files generated by the protobuf compiler.

> [!TIP]
> There *are* limitations to what can be passed as a generator expression to
> `add_custom_command` and this typically causes some friction when it is
> suggested to use generator expressions that are property based, specifically,
> the `OUTPUT` parameter of a custom command *cannot* rely on target
> properties, but does permit some transformations such as `$<PATH:...>` and
> `$<LIST:...>` generator expressions.


[protobuf-generate]: https://cmake.org/cmake/help/latest/module/FindProtobuf.html#command:protobuf_generate
[define-property]: https://cmake.org/cmake/help/latest/command/define_property.html
[genexpr]: https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html
[ws]: https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#whitespace-and-quoting
