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
        $<BOOL:$<TARGET_PROPERTY:${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS>>,
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
  set(${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAG "-fprofile-instr-generate -fcoverage-mapping")
  set(${CMAKE_FIND_PACKAGE_NAME}_LLVM_LINK_FLAG "-fprofile-inst-generate")
  block (SCOPE_FOR VARIABLES)
    set(target ${CMAKE_FIND_PACKAGE_NAME}::LLVM)
    set(prefix ${target}:{${target}})
    set_property(GLOBAL APPEND PROPERTY ${target}::target ${target})
    set_property(GLOBAL APPEND PROPERTY ${target}::variables
      ${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAG
      ${CMAKE_FIND_PACKAGE_NAME}_LLVM_LINK_FLAG)

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
  endblock()

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

# Cache variables for default property values.
block (SCOPE_FOR VARIABLES)
  if (🈯::ixm::${CMAKE_FIND_PACKAGE_NAME}::CACHE)
    return()
  endif()

  string(CONCAT llvm.profile.file $<PATH:APPEND
    $<TARGET_PROPERTY:BINARY_DIR>,
    $<CONFIG>,
    $<PATH:REPLACE_EXTENSION,$<TARGET_PROPERTY:NAME>,profraw>
  >)

  # These are inaccurate until the command is done.
  set(IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_PREFIX_MAP "$<TARGET_PROPERTY:SOURCE_DIR>=."
    CACHE STRING "Default coverage prefix map. Use `<old>=<new>`")
  set(IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_FILEPATH "${llvm.profile.file}"
    CACHE STRING "Default LLVM coverage filepath")
  set(IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_REUSE_PGO NO
    CACHE BOOL "The coverage file will be used for Profile Guided Optimization")

  set(IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS NO
    CACHE BOOL "Create absolute paths in the .gcno files")
  set(IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_CONDITIONS NO
    CACHE BOOL "Whether to instrument program conditions (GCC Only)")

  mark_as_advanced(
    IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_PROFILE_FILE
    IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_COVERAGE_PREFIX_MAP

    IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS
    IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_CONDITIONS
  )


  set(🈯::${CMAKE_FIND_PACKAGE_NAME}::CACHE YES CACHE INTERNAL "")
endblock()

# Setting default values
set(IXM_LLVM_COVERAGE_PREFIX_MAP "$<TARGET_PROPERTY:SOURCE_DIR>=."
  CACHE STRING "Default LLVM Coverage prefix map path")
set(IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_PROFILE_FILENAME
  "$<PATH:APPEND,$<TARGET_PROPERTY:BINARY_DIR>,$<CONFIG>,$<TARGET_PROPERTY:NAME>.profraw>"
  CACHE STRING "Default LLVM Coverage profile filename")
set(IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS NO
  CACHE BOOL "Pass `-fprofile-abs-path` in for gcov build targets")

mark_as_advanced(
  IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_COVERAGE_PREFIX_MAP
  IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS
)

#[[
define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS INHERITED
  BRIEF_DOCS "Create absolute paths in the .gcno files"
  INITIALIZE_FROM_VARIABLE
    IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS)

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
]]
define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_INSTRUMENTED_EXECUTABLES
  BRIEF_DOCS "Executables that generate LLVM Profile Instrumentation Data")

define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_INSTRUMENTED_SOURCES
  BRIEF_DOCS "todo")

define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_INSTRUMENTED_FILENAME
  BRIEF_DOCS "Path to the LLVM .profraw file"
  INITIALIZE_FROM_VARIABLE
    IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_INSTRUMENTED_FILENAME)

define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_MERGE_FAILURE_MODE
  BRIEF_DOCS "todo")

define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_MERGE_REUSE_PGO
  BRIEF_DOCS "todo")

define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_MERGE_PROFILES
  BRIEF_DOCS "")

define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_MERGE_OPTIONS
  BRIEF_DOCS "")

define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_LLVM_EXPORT_IGNORE_FILENAME_REGEX
  BRIEF_DOCS "")

block (SCOPE_FOR VARIABLES)
  set(IXM_${CMAKE_FIND_PACKAGE_NAME}_LLVM_INSTRUMENTED_FILENAME
    $<PATH:APPEND,$<TARGET_PROPERTY:BINARY_DIR>,$<CONFIG>,$<TARGET_PROPERTY:NAME>.profraw>
    CACHE STRING "Default path for the LLVM .profraw file")
endblock()

#[============================================================================[
# @param {option} LLVM - Set the coverage target type to use source-based code
# coverage
# @param {option} GNU - Set the coverage target type to use gcov.
#]============================================================================]
function (add_coverage_target name)
  #cmake_language(CALL ixm::unimplemented)
  cmake_parse_arguments(ARG "LLVM;GNU" "OUTPUT;FORMAT" "" ${ARGN})
  if (ARG_LLVM AND ARG_GNU)
    message(FATAL_ERROR "Coverage targets may only have one of type: LLVM, GNU")
  endif()

  if (ARG_LLVM)
    # TODO: Use cmake_path to ensure there is a "well known" file extension based on FORMAT
    cmake_language(CALL 🈯::ixm::default ARG_FORMAT lcov)
    string(CONCAT llvm.output $<PATH:APPEND,
      ${CMAKE_CURRENT_BINARY_DIR},
      $<CONFIG>,
      ${name}.${ARG_FORMAT}
    >)
    cmake_language(CALL 🈯::ixm::default ARG_OUTPUT "${llvm.output}")
  endif()

  add_custom_target(${name}
    DEPENDS
      "${ARG_OUTPUT}"
      $<GENEX_EVAL:$<TARGET_PROPERTY:${name},COVERAGE_DEPENDENCIES>>)

  set_target_properties(${name}
    PROPERTIES
      COVERAGE_IMPLEMENTATION $<IF:$<BOOL:${ARG_LLVM}>,LLVM,GNU>
  )

  if (ARG_LLVM)
    string(CONCAT profile.data $<PATH:APPEND,
      ${CMAKE_CURRENT_BINARY_DIR},
      $<CONFIG>,
      $<PATH:REPLACE_EXTENSION,${name},profdata>
    >)

    set(common.arguments PACKAGE Coverage TARGET ${name})
    cmake_language(CALL 🈯::ixm::property::get LLVM_INSTRUMENTED_EXECUTABLES ${common.arguments})
    cmake_language(CALL 🈯::ixm::property::get LLVM_INSTRUMENTED_SOURCES ${common.arguments})

    cmake_language(CALL 🈯::ixm::property::get LLVM_MERGE_FAILURE_MODE ${common.arguments})
    # TODO: Consider renaming this one to just `LLVM_MERGE_SPARSE`, default it to YES
    cmake_language(CALL 🈯::ixm::property::get LLVM_MERGE_REUSE_PGO ${common.arguments})
    cmake_language(CALL 🈯::ixm::property::get LLVM_MERGE_PROFILES ${common.arguments})
    cmake_language(CALL 🈯::ixm::property::get LLVM_MERGE_OPTIONS ${common.arguments})

    cmake_language(CALL 🈯::ixm::property::get LLVM_EXPORT_IGNORE_FILENAME_REGEX
      OUTPUT_VARIABLE ignore.regex ${common.arguments})

    add_custom_command(OUTPUT "${profile.data}"
      COMMAND Coverage::LLVM::ProfileData merge
        $<$<NOT:$<BOOL:${LLVM_MERGE_REUSE_PGO}>>:--sparse>
        --instr
        $<$<BOOL:${LLVM_MERGE_FAILURE_MODE}>:--failure-mode=${LLVM_MERGE_FAILURE_MODE}>
        --output=${profile.data}
        ${LLVM_MERGE_OPTIONS}
        ${LLVM_MERGE_PROFILES}
      DEPENDS
        $<TARGET_NAME_IF_EXISTS:test>
        ${LLVM_INSTRUMENTED_EXECUTABLES}
        ${LLVM_MERGE_PROFILES}
      COMMENT "Merging profiling data to ${profile.data}"
      COMMAND_EXPAND_LISTS
      VERBATIM)

    cmake_language(CALL 🈯::ixm::property::get IMPORTED_LOCATION
      TARGET $<TARGET_NAME_IF_EXISTS:Coverage::LLVM::C++Filter>
      OUTPUT_VARIABLE demangler)

    # TODO: Make the `cmake_pch` itself a property of "banned" files
    # e.g., we could just reuse the IGNORE_FILENAME_REGEX property :)
    set(sources $<LIST:FILTER,${LLVM_INSTRUMENTED_SOURCES},EXCLUDE,cmake_pch>)

    # It is beyond unfortunate that no one on the LLVM team ever thought "what
    # if someone is writing this to a file and doesn't want to rely on the
    # shell?" but LLVM rarely makes the right choice. We all just put up with
    # it. :(
    add_custom_command(OUTPUT "${ARG_OUTPUT}"
      COMMAND Coverage::LLVM::Tool export
        --format=${ARG_FORMAT}
        --instr-profile=${profile.data}
        $<$<BOOL:$<TARGET_NAME_IF_EXISTS:Coverage::LLVM::C++Filter>>:-Xdemangler=${demangler}>
        "$<$<BOOL:${ignore.regex}>:--ignore-filename-regex=($<JOIN:${ignore.regex},|>)>"
        $<JOIN:${LLVM_INSTRUMENTED_EXECUTABLES},$<SEMICOLON>--object$<SEMICOLON>>
        --sources $<JOIN:${sources},$<SEMICOLON>--sources$<SEMICOLON>>
      > "${ARG_OUTPUT}"
      DEPENDS
        ${profile.data}
      COMMENT "Exporting coverage information to ${ARG_OUTPUT}"
      COMMAND_EXPAND_LISTS
      USES_TERMINAL
      VERBATIM)
    set_property(TARGET ${name} APPEND
      PROPERTY Coverage_LLVM_EXPORT_IGNORE_FILENAME_REGEX
        $<PATH:RELATIVE_PATH,${FETCHCONTENT_BASE_DIR},${CMAKE_BINARY_DIR}>)
    set_property(TARGET ${name} APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${ARG_OUTPUT}")
  endif()
endfunction()

function (target_coverage name)
  cmake_parse_arguments(ARG "" "" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})
  get_property(implementation TARGET ${name} PROPERTY COVERAGE_IMPLEMENTATION)

  foreach (visibility IN ITEMS PRIVATE PUBLIC)
    foreach (target IN LISTS ARG_${visibility})
      set(is.executable $<STREQUAL:$<TARGET_PROPERTY:${target},TYPE>,EXECUTABLE>)
      cmake_language(CALL 🈯::ixm::property::get LLVM_INSTRUMENTED_FILENAME
        PACKAGE Coverage
        TARGET ${target}
        CONTEXT)
      set(properties INSTRUMENTED_SOURCES INSTRUMENTED_EXECUTABLES MERGE_PROFILES)
      set(values $<TARGET_PROPERTY:${target},SOURCES>
        $<${is.executable}:$<TARGET_FILE:${target}>>
        $<${is.executable}:${LLVM_INSTRUMENTED_FILENAME}>)
      foreach (property value IN ZIP_LISTS properties values)
        set_property(TARGET ${name} APPEND
          PROPERTY
            Coverage_LLVM_${property} ${value})
      endforeach()
      set_property(TARGET ${name} APPEND
        PROPERTY
          ADDITIONAL_CLEAN_FILES $<${is.executable}:${LLVM_INSTRUMENTED_FILENAME}>)
      target_link_libraries(${target}
        ${visibility}
          Coverage::${implementation})
    endforeach()
  endforeach()
endfunction()
