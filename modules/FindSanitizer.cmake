if (NOT DEFINED ${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK)
  block (SCOPE_FOR VARIABLES PROPAGATE ${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK)
    get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
    # No languages have been enabled yet, so we're just gonna angrily warn and
    # return
    if (NOT languages)
      message(WARNING "find_package(${CMAKE_FIND_PACKAGE_NAME}) must be called after enabling a language via `project()`")
      return()
    endif()
    if ("CXX" IN_LIST languages)
      set(${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK "CXX")
    elseif ("C" IN_LIST languages)
      set(${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK "C")
    elseif ("OBJCXX" IN_LIST languages)
      set(${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK "OBJCXX")
    elseif ("OBJC" IN_LIST languages)
      set(${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK "OBJC")
    else()
      message(WARNING "find_package(${CMAKE_FIND_PACKAGE_NAME}) requires one of OBJCXX, OBJC, CXX, and C to be enabled")
      return()
    endif()
  endblock()
endif()

# Address
if (CMAKE_${${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK}_COMPILER_ID MATCHES "(Clang|GNU|MSVC)")
  set(${CMAKE_FIND_PACKAGE_NAME}_Address_FOUND YES)
  set(${CMAKE_FIND_PACKAGE_NAME}_ASan_FOUND YES)
endif()

# Fuzzer
if (CMAKE_${${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK}_COMPILER_ID MATCHES "(Clang|GNU)" OR MSVC_TOOLSET_VERSION GREATER_EQUAL "143")
  set(${CMAKE_FIND_PACKAGE_NAME}_Fuzzer_FOUND YES)
endif()

if (CMAKE_${${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK}_COMPILER_ID MATCHES "(Clang|GNU)"
    AND NOT CMAKE_${${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
  # Undefined Behavior
  set(${CMAKE_FIND_PACKAGE_NAME}_UndefinedBehavior_FOUND YES)
  set(${CMAKE_FIND_PACKAGE_NAME}_UBSan_FOUND YES)

  # Leak
  set(${CMAKE_FIND_PACKAGE_NAME}_Leak_FOUND YES)
  set(${CMAKE_FIND_PACKAGE_NAME}_LSan_FOUND YES)

  # Thread
  set(${CMAKE_FIND_PACKAGE_NAME}_Thread_FOUND YES)
  set(${CMAKE_FIND_PACKAGE_NAME}_TSan_FOUND YES)

  # ShadowCallStack
  if ("arm64" IN_LIST CMAKE_OSX_ARCHITECTURES OR CMAKE_SYSTEM_PROCESSOR MATCHES "(aarch64|arm64-v8a|ARM64)")
    set(${CMAKE_FIND_PACKAGE_NAME}_ShadowCallStack_FOUND YES)
  endif()
endif()

if (CMAKE_${${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK}_COMPILER_ID MATCHES "Clang"
    AND NOT CMAKE_${${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"
    AND NOT CMAKE_${${CMAKE_FIND_PACKAGE_NAME}_LANGUAGE_CHECK}_COMPILER_LINKER_FRONTEND_VARIANT STREQUAL "MSVC")

  # DataFlow
  set(${CMAKE_FIND_PACKAGE_NAME}_DataFlow_FOUND YES)
  set(${CMAKE_FIND_PACKAGE_NAME}_DFSan_FOUND YES)

  # Memory
  set(${CMAKE_FIND_PACKAGE_NAME}_Memory_FOUND YES)
  set(${CMAKE_FIND_PACKAGE_NAME}_MSan_FOUND YES)

  # SafeStack
  if (CMAKE_SYSTEM_NAME MATCHES "(Linux|FreeBSD|NetBSD|Darwin)")
    set(${CMAKE_FIND_PACKAGE_NAME}_SafeStack_FOUND YES)
  endif()

  # ControlFlowIntegrity
  set(${CMAKE_FIND_PACKAGE_NAME}_ControlFlowIntegrity_FOUND YES)
  set(${CMAKE_FIND_PACKAGE_NAME}_CFI_FOUND YES)
endif()

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "Runtime checks for various forms of suspicious or undefined behavior")

if (${CMAKE_FIND_PACKAGE_NAME}_Address_FOUND AND NOT TARGET Sanitizer::Address)
  add_library(Sanitizer::Address INTERFACE IMPORTED)
  add_library(Sanitizer::ASan ALIAS Sanitizer::Address)
  block(SCOPE_FOR VARIABLES)
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
    string(CONCAT gnu+languages $<OR:
      $<COMPILE_LANG_AND_ID:OBJCXX,GNU>,
      $<COMPILE_LANG_AND_ID:OBJC,GNU>,
      $<COMPILE_LANG_AND_ID:CXX,GNU>,
      $<COMPILE_LANG_AND_ID:C,GNU>
    >)
    set(use-private-alias $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_ASAN_USE_PRIVATE_ALIASES>>>)
    set(globals $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_ASAN_GLOBALS>>>)
    set(stack $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_ASAN_STACK>>>)
    target_compile_options(Sanitizer::Address
      INTERFACE
        $<$<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=address>
        $<${gnu/clang+languages}:-fno-omit-frame-pointer>
        $<${gnu/clang+languages}:-fno-common>

        $<$<AND:${clang+languages},${use-private-alias}>:-mllvm$<SEMICOLON>-asan-use-private-alias=1>
        $<$<AND:${clang+languages},$<NOT:${globals}>>:-mllvm$<SEMICOLON>-asan-globals=0>
        $<$<AND:${clang+languages},$<NOT:${stack}>>:-mllvm$<SEMICOLON>-asan-stack=0>
        $<$<AND:${gnu+languages},$<NOT:${globals}>>:--param$<SEMICOLON>asan-globals=0>
        $<$<AND:${gnu+languages},$<NOT:${stack}>>:--param$<SEMICOLON>asan-stack=0>)
    target_link_options(Sanitizer::Address
      INTERFACE
        $<$<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=address>)
  endblock()

  define_property(TARGET
    PROPERTY "SANITIZER_ASAN_USE_PRIVATE_ALIASES" INHERITED
    BRIEF_DOCS "Detect overflow/underflow for global objects"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_ASAN_USE_PRIVATE_ALIASES")

  define_property(TARGET
    PROPERTY "SANITIZER_ASAN_GLOBALS" INHERITED
    BRIEF_DOCS "Detect overflow/underflow for global objects"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_ASAN_GLOBALS")

  define_property(TARGET
    PROPERTY "SANITIZER_ASAN_STACK" INHERITED
    BRIEF_DOCS "Detect overflow/underflow for stack objects"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_ASAN_STACK")
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_Fuzzer_FOUND AND NOT TARGET Sanitizer::Fuzzer)
  add_library(Sanitizer::Fuzzer INTERFACE IMPORTED)
  target_compile_options(Sanitizer::Fuzzer
    INTERFACE
      $<$<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=fuzzer>)
  target_link_options(Sanitizer::Fuzzer
    INTERFACE
      $<$<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=fuzzer>)
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_UndefinedBehavior_FOUND AND NOT TARGET Sanitizer::UndefinedBehavior)
  add_library(Sanitizer::UndefinedBehavior INTERFACE IMPORTED)
  add_library(Sanitizer::UBSan ALIAS Sanitizer::UndefinedBehavior)
  block (SCOPE_FOR VARIABLES)
    string(CONCAT compile.gnu/clang+languages $<OR:
      $<COMPILE_LANG_AND_ID:OBJCXX,GNU,Clang>,
      $<COMPILE_LANG_AND_ID:OBJC,GNU,Clang>,
      $<COMPILE_LANG_AND_ID:CXX,GNU,Clang>,
      $<COMPILE_LANG_AND_ID:C,GNU,Clang>
    >)
    string(CONCAT link.gnu/clang+languages $<OR:
      $<LINK_LANG_AND_ID:OBJCXX,GNU,Clang>,
      $<LINK_LANG_AND_ID:OBJC,GNU,Clang>,
      $<LINK_LANG_AND_ID:CXX,GNU,Clang>,
      $<LINK_LANG_AND_ID:C,GNU,Clang>
    >)

    set(strip.path.components $<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_UBSAN_STRIP_PATH_COMPONENTS>>)
    set(minimal.runtime $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_UBSAN_MINIMAL_RUNTIME>>>)
    set(vptr $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_UBSAN_VPTR>>>)

    string(CONCAT platforms $<PLATFORM_ID:
      Android,
      FreeBSD,
      OpenBSD,
      Windows,
      NetBSD,
      Darwin,
      Linux
    >)

    string(CONCAT compile.minimal.runtime $<AND:
      ${compile.gnu/clang+languages},
      ${minimal.runtime},
      $<NOT:${vptr}>
    >)
    string(CONCAT link.minimal.runtime $<AND:
      ${link.gnu/clang+languages},
      ${minimal.runtime},
      $<NOT:${vptr}>
    >)

    string(CONCAT compile.strip.components $<AND:
      ${compile.gnu/clang+languages},
      $<BOOL:${strip.path.components}>
    >)
    string(CONCAT link.strip.components $<AND:
      ${link.gnu/clang+languages},
      $<BOOL:${strip.path.components}>
    >)

    target_compile_options(Sanitizer::UndefinedBehavior
      INTERFACE
        $<${compile.gnu/clang+languages}:-fsanitize=undefined>
        $<${compile.strip.components}:-fsanitize-undefined-strip-path-components=${strip.path.components}>
        $<${compile.minimal.runtime}:-fsanitize-minimal-runtime>)
    target_link_options(Sanitizer::UndefinedBehavior
      INTERFACE
        $<${link.gnu/clang+languages}:-fsanitize=undefined>
        $<${link.strip.components}:-fsanitize-undefined-strip-path-components=${strip.path.components}>
        $<${link.minimal.runtime}:-fsanitize-minimal-runtime>)
  endblock()

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_MINIMAL_RUNTIME" INHERITED
    BRIEF_DOCS "Minimal UBSan runtime suitable for production environments"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_MINIMAL_RUNTIME")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_STRIP_PATH_COMPONENTS" INHERITED
    BRIEF_DOCS "Trim full filename components"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_STRIP_PATH_COMPONENTS")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_ALIGNMENT" INHERITED
    BRIEF_DOCS "Use of misaligned pointer or creation of misaligned reference."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_ALIGNMENT")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_BOOL" INHERITED
    BRIEF_DOCS "Load of a bool value which is neither true nor false."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_BOOL")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_BUILTIN" INHERITED
    BRIEF_DOCS "Passing invalid values to compiler builtins."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_BUILTIN")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_BOUNDS" INHERITED
    BRIEF_DOCS "Out of bounds array indexing, in cases where the array bound can be statically determined"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_BOUNDS")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_ENUM" INHERITED
    BRIEF_DOCS "Load of a value of an enumerated type which is not in the range of representable values"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_ENUM")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_FLOATING_CAST_OVERFLOW" INHERITED
    BRIEF_DOCS "Conversion to, from, or between floating point types that would overflow the destination."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_FLOATING_CAST_OVERFLOW")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_FUNCTION" INHERITED
    BRIEF_DOCS "Indirect call of a function through a function pointer of the wrong type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_FUNCTION")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_UNSIGNED_INTEGER_TRUNCATION" INHERITED
    BRIEF_DOCS " Implicit conversion from integer of larger bit width to smaller bit width, if that results in data loss"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_UNSIGNED_INTEGER_TRUNCATION")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_SIGNED_INTEGER_TRUNCATION" INHERITED
    BRIEF_DOCS " Implicit conversion from integer of larger bit width to smaller bit width, if that results in data loss"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_SIGNED_INTEGER_TRUNCATION")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_INTEGER_SIGN_CHANGE" INHERITED
    BRIEF_DOCS "Implicit conversion between integer types, if that changes the sign of the value"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_INTEGER_SIGN_CHANGE")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_INTEGER_DIVIDE_BY_ZERO" INHERITED
    BRIEF_DOCS "Integer division by zero"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_INTEGER_DIVIDE_BY_ZERO")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_BITFIELD_CONVERSION" INHERITED
    BRIEF_DOCS "Implicit conversion from integer of larger bit width to smaller bitfield, if that results in data los"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_BITFIELD_CONVERSION")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_NONNULL_ATTRIBUTE" INHERITED
    BRIEF_DOCS "Passing null pointer as a function parameter which is declared to never be null."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_NONNULL_ATTRIBUTE")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_NULL" INHERITED
    BRIEF_DOCS "Use of a null pointer or creation of a null reference."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_NULL")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_NULLABILITY_ARG" INHERITED
    BRIEF_DOCS "Passing null as a function parameter which is annotated with _Nonnull."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_NULLABILITY_ARG")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_NULLABILITY_ASSIGN" INHERITED
    BRIEF_DOCS "Use of a null pointer or creation of a null reference."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_NULLABILITY_ASSIGN")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_NULLABILITY_RETURN" INHERITED
    BRIEF_DOCS "Use of a null pointer or creation of a null reference."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_NULLABILITY_RETURN")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_OBJC_CAST" INHERITED
    BRIEF_DOCS "Invalid implicit cast of an ObjC object pointer to an incompatible type."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_OBJC_CAST")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_OBJECT_SIZE" INHERITED
    BRIEF_DOCS "An attempt to potentially use bytes which the optimizer can determine are not part of the object being accessed"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_OBJECT_SIZE")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_POINTER_OVERFLOW" INHERITED
    BRIEF_DOCS "Performing pointer arithmetic which overflows, or where either the old or new pointer value is a null pointer (or in C, when they both are)."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_POINTER_OVERFLOW")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_RETURN" INHERITED
    BRIEF_DOCS "In C++, reaching the end of a value-returning function without returning a value."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_RETURN")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_RETURNS_NONNULL_ATTRIBUTE" INHERITED
    BRIEF_DOCS "Returning null pointer from a function which is declared to never return null."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_RETURNS_NONNULL_ATTRIBUTE")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_SHIFT" INHERITED
    BRIEF_DOCS "Shift operators where the amount shifted is greater or equal to the promoted bit-width of the left hand side or less than zero, or where the left hand side is negative."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_SHIFT")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_UNSIGNED_SHIFT_BASE" INHERITED
    BRIEF_DOCS "check that an unsigned left-hand side of a left shift operation doesn’t overflow."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_UNSIGNED_SHIFT_BASE")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_UNREACHABLE" INHERITED
    BRIEF_DOCS "If control flow reaches an unreachable program point."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_UNREACHABLE")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_UNSIGNED_INTEGER_OVERFLOW" INHERITED
    BRIEF_DOCS "Unsigned integer overflow, where the result of an unsigned integer computation cannot be represented in its type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_UNSIGNED_INTEGER_OVERFLOW")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_VLA_BOUND" INHERITED
    BRIEF_DOCS "A variable-length array whose bound does not evaluate to a positive value."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_VLA_BOUND")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_VPTR" INHERITED
    BRIEF_DOCS "Use of an object whose vptr indicates that it is of the wrong dynamic type, or that its lifetime has not begun or has ended."
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_VPTR")

  # These are UBSan groups. They can be used to set or unset multiple properties
  # above
  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_UNDEFINED" INHERITED
    BRIEF_DOCS "Enables most UBSan checks"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_UNDEFINED")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_INTEGER_TRUNCATION" INHERITED
    BRIEF_DOCS "Enables SANITIZER_UBSAN_IMPLICIT_SIGNED_INTEGER_TRUNCATION and SANITIZER_UBSAN_IMPLICIT_UNSIGNED_INTEGER_TRUNCATION"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_INTEGER_TRUNCATION")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_INTEGER_ARITHMETIC_VALUE_CHANGE" INHERITED
    BRIEF_DOCS "Catches implicit conversions that change the arithmetic value of the integer"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_INTEGER_ARITHMETIC_VALUE_CHANGE")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_INTEGER_CONVERSION" INHERITED
    BRIEF_DOCS "Checks for suspicious behavior of implicit integer conversions"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_INTEGER_CONVERSION")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_IMPLICIT_CONVERSION" INHERITED
    BRIEF_DOCS "Checks for suspicious behavior of implicit conversions"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_IMPLICIT_CONVERSION")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_INTEGER" INHERITED
    BRIEF_DOCS "Checks for undefined or suspicious integer behavior"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_INTEGER")

  define_property(TARGET
    PROPERTY "SANITIZER_UBSAN_NULLABILITY" INHERITED
    BRIEF_DOCS "Enables all nullability-* checks"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_UBSAN_NULLABILITY")
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_Leak_FOUND AND NOT TARGET Sanitizer::Leak)
  add_library(Sanitizer::Leak INTERFACE IMPORTED)
  add_library(Sanitizer::LSan ALIAS Sanitizer::Leak)

  target_compile_options(Sanitizer::Leak
    INTERFACE
      $<$<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=leak>)
  target_link_options(Sanitizer::Leak
    INTERFACE
      $<$<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=leak>)
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_Thread_FOUND AND NOT TARGET Sanitizer::Thread)
  add_library(Sanitizer::Thread INTERFACE IMPORTED)
  add_library(Sanitizer::TSan ALIAS Sanitizer::Thread)

  block (SCOPE_FOR VARIABLES)
    string(CONCAT compile.enabled $<AND:
      $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:INTERPROCEDURAL_OPTIMIZATION>>>,
      $<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>
    >)
    string(CONCAT link.enabled $<AND:
      $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:INTERPROCEDURAL_OPTIMIZATION>>>,
      $<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>
    >)
    target_compile_options(Sanitizer::Thread
      INTERFACE
        $<${compile.enabled}:-fsanitize=thread>)
    target_link_options(Sanitizer::Thread
      INTERFACE
        $<${link.enabled}:-fsanitize=thread>)
  endblock()

endif()

if (${CMAKE_FIND_PACKAGE_NAME}_ShadowCallStack_FOUND AND NOT TARGET Sanitizer::ShadowCallStack)
  add_library(Sanitizer::ShadowCallStack INTERFACE IMPORTED)
  target_compile_options(Sanitizer::ShadowCallStack
    INTERFACE
      $<$<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=shadow-call-stack>)
  target_link_options(Sanitizer::ShadowCallStack
    INTERFACE
      $<$<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=shadow-call-stack>)
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_DataFlow_FOUND AND NOT TARGET Sanitizer::DataFlow)
  add_library(Sanitizer::DataFlow INTERFACE IMPORTED)
  add_library(Sanitizer::DFSan ALIAS Sanitizer::DataFlow)

  target_compile_options(Sanitizer::DataFlow
    INTERFACE
      $<$<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=dataflow>)
  target_link_options(Sanitizer::DataFlow
    INTERFACE
      $<$<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=dataflow>)
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_Memory_FOUND AND NOT TARGET Sanitizer::Memory)
  add_library(Sanitizer::Memory INTERFACE IMPORTED)
  add_library(Sanitizer::MSan ALIAS Sanitizer::Memory)

  target_compile_options(Sanitizer::Memory
    INTERFACE
      $<$<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=memory>)
  target_link_options(Sanitizer::Memory
    INTERFACE
      $<$<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=memory>)

  define_property(TARGET
    PROPERTY "SANITIZER_MSAN_TRACK_ORIGINS" INHERITED
    BRIEF_DOCS "Enables a slightly faster mode, disables intermediate stores"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_MSAN_TRACK_ORIGINS")

  define_property(TARGET
    PROPERTY "SANITIZER_MSAN_USE_AFTER_DTOR" INHERITED
    BRIEF_DOCS "Detect object access after destructor invocation"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_MSAN_USE_AFTER_DTOR")
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_SafeStack_FOUND AND NOT TARGET Sanitizer::SafeStack)
  add_library(Sanitizer::SafeStack INTERFACE IMPORTED)
  target_compile_options(Sanitizer::SafeStack
    INTERFACE
      $<$<COMPILE_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=safe-stack>)
  target_link_options(Sanitizer::SafeStack
    INTERFACE
      $<$<LINK_LANGUAGE:OBJCXX,OBJC,CXX,C>:-fsanitize=safe-stack>)
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_ControlFlowIntegrity_FOUND AND NOT TARGET Sanitizer::ControlFlowIntegrity)
  add_library(Sanitizer::ControlFlowIntegrity INTERFACE IMPORTED)
  add_library(Sanitizer::CFI ALIAS Sanitizer::ControlFlowIntegrity)

  block (SCOPE_FOR VARIABLES)
    set(unrelated-cast $<NOT:$<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_CFI_UNRELATED_CAST>>>>)
    set(derived-cast $<NOT:$<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_CFI_DERIVED_CAST>>>>)
    set(cast-strict $<NOT:$<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_CFI_CAST_STRICT>>>>)
    set(mfcall $<NOT:$<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_CFI_MEMBER_FUNCTION_CALL>>>>)
    set(nvcall $<NOT:$<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_CFI_NONVIRTUAL_CALL>>>>)
    set(icall $<NOT:$<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_CFI_INDIRECT_CALL>>>>)
    set(vcall $<NOT:$<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:SANITIZER_CFI_VIRTUAL_CALL>>>>)

    set(enabled $<BOOL:$<GENEX_EVAL:$<TARGET_PROPERTY:INTERPROCEDURAL_OPTIMIZATION>>>)

    target_compile_options(Sanitizer::ControlFlowIntegrity
     INTERFACE
        $<${enabled}:-fsanitize=cfi>
        $<$<AND:${enabled},${unrelated-strict}>:-fno-sanitize=cfi-unrelated-strict>
        $<$<AND:${enabled},${derived-strict}>:-fno-sanitize=cfi-derived-strict>
        $<$<AND:${enabled},${cast-strict}>:-fno-sanitize=cfi-cast-strict>
        $<$<AND:${enabled},${mfcall}>:-fno-sanitize=cfi-mfcall>
        $<$<AND:${enabled},${nvcall}>:-fno-sanitize=cfi-nvcall>
        $<$<AND:${enabled},${vcall}>:-fno-sanitize=cfi-vcall>
        $<$<AND:${enabled},${icall}>:-fno-sanitize=cfi-icall>)
    target_link_options(Sanitizer::ControlFlowIntegrity
      INTERFACE
        $<${enabled}:-fsanitize=cfi>
        $<$<AND:${enabled},${unrelated-cast}>:-fno-sanitize=cfi-unrelated-strict>
        $<$<AND:${enabled},${derived-cast}>:-fno-sanitize=cfi-derived-strict>
        $<$<AND:${enabled},${cast-strict}>:-fno-sanitize=cfi-cast-strict>
        $<$<AND:${enabled},${mfcall}>:-fno-sanitize=cfi-mfcall>
        $<$<AND:${enabled},${nvcall}>:-fno-sanitize=cfi-nvcall>
        $<$<AND:${enabled},${vcall}>:-fno-sanitize=cfi-vcall>
        $<$<AND:${enabled},${icall}>:-fno-sanitize=cfi-icall>)
  endblock()

  define_property(TARGET
    PROPERTY "SANITIZER_CFI_CAST_STRICT" INHERITED
    BRIEF_DOCS "Enables strict cast checks"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_CFI_CAST_STRICT")

  define_property(TARGET
    PROPERTY "SANITIZER_CFI_DERIVED_CAST" INHERITED
    BRIEF_DOCS "Base-to-derived cast to the wrong dynamic type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_CFI_DERIVED_CAST")

  define_property(TARGET
    PROPERTY "SANITIZER_CFI_UNRELATED_CAST" INHERITED
    BRIEF_DOCS "Cast from void* or another unrelated type to the wrong dynamic type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_CFI_UNRELATED_CAST")

  define_property(TARGET
    PROPERTY "SANITIZER_CFI_NONVIRTUAL_CALL" INHERITED
    BRIEF_DOCS "Non-virtual call via an object whose vptr is of the wrong dynamic type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_CFI_NONVIRTUAL_CALL")

  define_property(TARGET
    PROPERTY "SANITIZER_CFI_VIRTUAL_CALL" INHERITED
    BRIEF_DOCS "Virtual call via an object whose vptr is of the wrong dynamic type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_CFI_VIRTUAL_CALL")

  define_property(TARGET
    PROPERTY "SANITIZER_CFI_INDIRECT_CALL" INHERITED
    BRIEF_DOCS "Indirect call of a function with wrong dynamic type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_CFI_INDIRECT_CALL")

  define_property(TARGET
    PROPERTY "SANITIZER_CFI_MEMBER_FUNCTION_CALL" INHERITED
    BRIEF_DOCS "Indirect call via a member function pointer with wrong dynamic type"
    INITIALIZE_FROM_VARIABLE "IXM_SANITIZER_CFI_MEMBER_FUNCTION_CALL")
endif()

set(IXM_SANITIZER_ASAN_USE_PRIVATE_ALIAS NO CACHE BOOL "AddressSanitizer: Use private aliases for global objects")
set(IXM_SANITIZER_ASAN_GLOBALS YES CACHE BOOL "AddressSanitizer: Detect overflow/underflow for global objects")
set(IXM_SANITIZER_ASAN_STACK YES CACHE BOOL "AddressSanitizer: Detect overflow/underflow for stack objects")

set(IXM_SANITIZER_UBSAN_UNDEFINED YES CACHE BOOL "UBSan: Default setting")

set(IXM_SANITIZER_MSAN_USE_AFTER_DTOR YES CACHE BOOL "MemorySanitizer: Use after destructor detection")

mark_as_advanced(
  IXM_SANITIZER_ASAN_USE_PRIVATE_ALIAS
  IXM_SANITIZER_ASAN_GLOBALS
  IXM_SANITIZER_ASAN_STACK

  IXM_SANITIZER_UBSAN_UNDEFINED

  IXM_SANITIZER_MSAN_USE_AFTER_DTOR
)
