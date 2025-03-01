if ("GNU" IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  message(WARNING "GNU code coverage is not currently a supported component for Coverage at this time.")
  cmake_language(CALL ixm::find::program
    NAMES gcov
    PACKAGE
      COMPONENT GNU
      TARGET Tool)
  set(${CMAKE_FIND_PACKAGE_NAME}_GNU_FLAG "--coverage")
  block (SCOPE_FOR VARIABLES)
    set(target ${CMAKE_FIND_PACKAGE_NAME}::GNU)
    set(prefix ${target}:{${target}})
    set_property(GLOBAL APPEND PROPERTY ${target}::targets ${target})
    set_property(GLOBAL APPEND PROPERTY ${target}::variables
      ${CMAKE_FIND_PACKAGE_NAME}_GNU_FLAG)
    foreach (language IN ITEMS OBJCXX OBJC CXX C)
      string(CONCAT abs.path $<AND:
        $<BOOL:$<TARGET_PROPERTY:COVERAGE_GNU_ABSOLUTE_PATHS>>,
        $<COMPILE_LANG_AND_ID:${language},GNU>
      >)

      set_property(GLOBAL APPEND PROPERTY ${prefix}::options::compile
        $<$<COMPILE_LANG_AND_ID:${language},AppleClang,Clang,GNU>:--coverage>
        $<${abs.path}:-fprofile-abs-path>
      )
      set_property(GLOBAL APPEND PROPERTY ${prefix}::options::link
        $<$<LINK_LANG_AND_ID:${language},AppleClang,Clang,GNU>:--coverage>)
    endforeach()
  endblock()
endif()

if ("LLVM" IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  cmake_language(CALL ixm::find::program
    NAMES llvm-undname
    DESCRIPTION "LLVM name undecorator"
    PACKAGE
      COMPONENT LLVM
      TARGET UndecorateName
      OPTIONAL)
  cmake_language(CALL ixm::find::program
    NAMES llvm-cxxfilt
    DESCRIPTION "LLVM symbol undecoration tool"
    PACKAGE
      COMPONENT LLVM
      TARGET C++Filter
      OPTIONAL)
  cmake_language(CALL ixm::find::program
    NAMES llvm-profdata
    DESCRIPTION "LLVM profile data tool"
    PACKAGE
      COMPONENT LLVM
      TARGET ProfileData)
  cmake_language(CALL ixm::find::program
    NAMES llvm-cov
    DESCRIPTION "Code coverage information tool"
    PACKAGE
      COMPONENT LLVM
      TARGET Tool)
  # TODO: Skip compilation check
  cmake_language(CALL ixm::check::option::compile CXX -fprofile-instr-generate
    OUTPUT_VARIABLE ${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_OPTIONS
    COMPILE_OPTIONS -fcoverage-mapping
    LINK_OPTIONS -fprofile-instr-generate
    QUIET)

  if (${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_OPTIONS)
    set(${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAGS "-fprofile-instr-generate")
  endif()
  # This is where we do manual bookkeeping for the automatic component
  # discovery system, since we're naming a target *after* the component itself
  # for a library we never *technically found*
  block (SCOPE_FOR VARIABLES)
    set(target ${CMAKE_FIND_PACKAGE_NAME}::LLVM)
    set(prefix ${target}::{${target}})
    string(CONCAT mcdc $<AND:
      $<CXX_COMPILER_ID:AppleClang,Clang>,
      $<BOOL:
        $<GENEX_EVAL:$<TARGET_PROPERTY:LLVM_MCDC>>
      >
    >)
    string(CONCAT coverage-prefix-map $<JOIN:
      $<GENEX_EVAL:$<TARGET_PROPERTY:LLVM_COVERAGE_PREFIX_MAP>>,
      -fcoverage-prefix-map=
    >)
    string(CONCAT coverage-prefix-maps $<
      $<BOOL:$<TARGET_PROPERTY:LLVM_COVERAGE_PREFIX_MAP>>:
      -fcoverage-prefix-map=${coverage-prefix-map}
    >)
    string(CONCAT profile.file $<
      $<BOOL:$<TARGET_PROPERTY:LLVM_PROFILE_FILENAME>>:
      =$<GENEX_EVAL:$<TARGET_PROPERTY:LLVM_PROFILE_FILENAME>>
    >)

    set_property(GLOBAL APPEND PROPERTY ${target}::variables
      ${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAGS)
    # NOTE(imuerte): I'm proud of myself for making this work, but also
    # bewildered at myself.
    set_property(GLOBAL APPEND PROPERTY ${target}::targets ${target})
    set_property(GLOBAL APPEND PROPERTY ${prefix}::options::compile
      $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fprofile-instr-generate${profile.file}>
      $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fcoverage-mapping>
      $<${mcdc}:-fcoverage-mcdc>
      ${coverage-prefix-maps})
    set_property(GLOBAL APPEND PROPERTY ${prefix}::options::link
      $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fprofile-instr-generate${profile.file}>)
  endblock()
endif()

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "Code Coverage Support")

# Setting a default value
set(IXM_LLVM_COVERAGE_PREFIX_MAP $<TARGET_PROPERTY:SOURCE_DIR>=.
  CACHE STRING "Default LLVM Coverage prefix map path")

define_property(TARGET
  PROPERTY GNU_ABSOLUTE_PATHS INHERITED
  BRIEF_DOCS "Create absolute paths in the .gcno files")

define_property(TARGET
  PROPERTY
    LLVM_MCDC
  INHERITED
  BRIEF_DOCS
    "Enable modified condition/decision code coverage support for LLVM instrumented targets")

define_property(TARGET
  PROPERTY
    LLVM_COVERAGE_PREFIX_MAP
  INHERITED
  BRIEF_DOCS
    "remap file source paths <old> to <new> in coverage mapping."
  INITIALIZE_FROM_VARIABLE
    IXM_LLVM_COVERAGE_PREFIX_MAP)

define_property(TARGET
  PROPERTY
    LLVM_PROFRAW_SOURCES
  INHERITED
  BRIEF_DOCS
    ".profraw file locations")

define_property(TARGET
  PROPERTY
    LLVM_TEST_EXECUTABLES
  INHERITED
  BRIEF_DOCS
    "Executables that generate LLVM Profile Data")

define_property(TARGET
  PROPERTY
    LLVM_IGNORE_FILENAME_REGEX
  INHERITED
  BRIEF_DOCS
    "Skip source code files with file paths that match the given regular expression"
  INITIALIZE_FROM_VARIABLE
    IXM_LLVM_IGNORE_FILENAME_REGEX)

define_property(TARGET
  PROPERTY
    LLVM_PROFILE_FILENAME
  BRIEF_DOCS
    "Equal to setting LLVM_PROFILE_FILE environment variable when adding a test")

#[[Add a coverage target (to generate and then merge all code coverage data]]
function (add_coverage name)
  cmake_language(CALL ixm::unimplemented)
  cmake_parse_arguments(ARG "LLVM;GNU" "" "" ${ARGN})
  if (ARG_LLVM AND ARG_GNU)
    message(FATAL_ERROR "Coverage targets may only have of: LLVM, GNU")
  endif()
endfunction()

#[[
Adds all the steps necessary to generate gcov data files.
#]]
function (add_gnu_coverage name)
  cmake_language(CALL ixm::unimplemented)
endfunction()

#[============================================================================[
Creates all the steps necessary to generate an lcov or json coverage report
file
]============================================================================]
function (add_llvm_coverage name)
  cmake_parse_arguments(ARG "ALL" "EXPORT;OUTPUT;FORMAT;GITHUB" "TARGETS;IGNORE_FILENAME_REGEX" ${ARGN})
  cmake_language(CALL 🈯::ixm::default ARG_EXPORT "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${name}.lcov.info")
  cmake_language(CALL 🈯::ixm::default ARG_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${name}.profdata")
  cmake_language(CALL 🈯::ixm::default ARG_FORMAT lcov)
  # Can't really remember why there's a ARG_GITHUB. Probably for
  # uploading/writing to a step summary automatically?
  # Might be as a "step" output, so it can be copied or uploaded to something
  # like codecov.io
  cmake_language(CALL 🈯::ixm::default ARG_GITHUB "${name}")
  set(ignore.filename.regex $<GENEX_EVAL:$<TARGET_PROPERTY:${name},LLVM_IGNORE_FILENAME_REGEX>>)
  set(test.executables $<GENEX_EVAL:$<TARGET_PROPERTY:${name},LLVM_TEST_EXECUTABLES>>)
  set(profraw.sources $<GENEX_EVAL:$<TARGET_PROPERTY:${name},LLVM_PROFRAW_SOURCES>>)
  set(failure.mode $<GENEX_EVAL:$<TARGET_PROPERTY:${name},LLVM_MERGE_FAILURE_MODE>>)
  set(sources $<GENEX_EVAL:$<TARGET_PROPERTY:${name},LLVM_SOURCES>>)
  # llvm-undname is broken, so we can *only* care about llvm-cxxfilter 😔
  set(demangler-name $<TARGET_NAME_IF_EXISTS:Coverage::LLVM::C++Filter>)
  string(CONCAT demangler $<
    $<BOOL:${demangler-name}>:
    $<TARGET_PROPERTY:${demangler-name},IMPORTED_LOCATION>
  >)
  add_custom_target(${name}
    DEPENDS
      ${ARG_EXPORT})
  add_custom_command(OUTPUT "${ARG_OUTPUT}"
    COMMAND Coverage::LLVM::ProfileData merge
      --sparse
      --instr
      --failure-mode=$<IF:$<BOOL:${failure.mode}>,${failure.mode},any>
      --output=${ARG_OUTPUT}
      ${profraw.sources}
    DEPENDS
      ${test.executables}
      ${profraw.sources}
      $<TARGET_NAME_IF_EXISTS:test>
    COMMENT "Merging raw profiling data"
    COMMAND_EXPAND_LISTS
    VERBATIM)
  # Unfortunate that we need a shell command (and require the `>` pipe
  # direction operator), but I've grown accustomed to LLVM tooling never doing
  # the right thing when you need it to.
  add_custom_command(OUTPUT ${ARG_EXPORT}
    DEPENDS ${ARG_OUTPUT}
    COMMAND Coverage::LLVM::Tool export
      --format=${ARG_FORMAT}
      --instr-profile=${ARG_OUTPUT}
      $<$<BOOL:${demangler-name}>:-Xdemangler=${demangler}>
      "$<$<BOOL:${ignore.filename.regex}>:--ignore-filename-regex=($<JOIN:${ignore.filename.regex},|>)>"
      $<JOIN:${test.executables},$<SEMICOLON>--object$<SEMICOLON>>
      --sources $<JOIN:${sources},$<SEMICOLON>--sources$<SEMICOLON>>
    > "${ARG_EXPORT}"
    COMMENT "Exporting coverage information to ${ARG_EXPORT}"
    COMMAND_EXPAND_LISTS
    USES_TERMINAL
    VERBATIM)
  foreach (target IN LISTS ARG_TARGETS)
    set_property(TARGET ${name} APPEND
      PROPERTY
        LLVM_SOURCES $<TARGET_PROPERTY:${target},SOURCES>)
  endforeach()
  set_property(TARGET ${name} APPEND
    PROPERTY
      LLVM_IGNORE_FILENAME_REGEX ${ARG_IGNORE_FILENAME_REGEX})
endfunction()
