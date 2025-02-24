if ("GNU" IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  message(WARNING "GNU code coverage is not currently a supported component for Coverage at this time.")
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
  cmake_language(CALL ixm::check::option::compile CXX -fprofile-instr-generate
    OUTPUT_VARIABLE ${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_OPTIONS
    COMPILE_OPTIONS -fcoverage-mapping
    LINK_OPTIONS -fprofile-instr-generate
    QUIET)

  if (${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_OPTIONS)
    set(${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAGS "-fprofile-instr-generate")
  endif()
  set_property(GLOBAL APPEND
    PROPERTY
      ${CMAKE_FIND_PACKAGE_NAME}::LLVM::variables
      ${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAGS)
endif()

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "Code Coverage Support")

if (${CMAKE_FIND_PACKAGE_NAME}_LLVM_FOUND)
  if (NOT TARGET ${CMAKE_FIND_PACKAGE_NAME}::LLVM)
    block(SCOPE_FOR VARIABLES)
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
      set(target ${CMAKE_FIND_PACKAGE_NAME}::LLVM)
      add_library(${target} INTERFACE IMPORTED)
      target_compile_options(${target}
        INTERFACE
          $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fprofile-instr-generate${profile.file}>
          $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fcoverage-mapping>
          $<${mcdc}:-fcoverage-mcdc>
          ${coverage-prefix-maps})
      target_link_options(${target}
        INTERFACE
          $<$<CXX_COMPILER_ID:AppleClang,Clang>:-fprofile-instr-generate${profile.file}>)
    endblock()
  endif()
endif()

# Setting a default value
set(IXM_LLVM_COVERAGE_PREFIX_MAP $<TARGET_PROPERTY:SOURCE_DIR>=.
  CACHE STRING "Default LLVM Coverage prefix map path")

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
