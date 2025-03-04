if ("GNU" IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  message(WARNING "GNU code coverage is not currently a supported component for Coverage at this time.")
  cmake_language(CALL ixm::find::program
    NAMES gcov
    PACKAGE
      COMPONENT GNU
      TARGET Tool)
  cmake_language(CALL ixm::find::program
    NAMES lcov
    PACKAGE
      COMPONENT GNU
      TARGET LTP
      OPTIONAL)
  cmake_language(CALL ixm::find::program
    NAMES gcovr
    PACKAGE
      COMPONENT GNU
      TARGET Coverage
      OPTIONAL)

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
        $<${abs.path}:-fprofile-abs-path>)
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
  set(${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAG
    "-fprofile-instr-generate -fcoverage-mapping")
  set(${CMAKE_FIND_PACKAGE_NAME}_LLVM_LINK_FLAG
    "-fprofile-inst-generate")

  block (SCOPE_FOR VARIABLES)
    set(target ${CMAKE_FIND_PACKAGE_NAME}::LLVM)
    set(prefix ${target}::{${target}})
    set_property(GLOBAL APPEND PROPERTY ${target}::targets ${target})
    set_property(GLOBAL APPEND PROPERTY ${target}::variables
      ${CMAKE_FIND_PACKAGE_NAME}_LLVM_COMPILE_FLAG
      ${CMAKE_FIND_PACKAGE_NAME}_LLVM_LINK_FLAG)

    foreach (language IN ITEMS OBJCXX OBJC CXX C)
      ixm_target_property(LLVM_INSTRUMENTED_FILENAME PREFIX COVERAGE)
      ixm_target_property(LLVM_COVERAGE_PREFIX_MAP PREFIX COVERAGE)
      ixm_target_property(LLVM_COVERAGE_MCDC PREFIX COVERAGE)

      string(CONCAT mcdc $<
        $<AND:
          $<COMPILE_LANG_AND_ID:${language},AppleClang,Clang>,
          $<BOOL:${LLVM_COVERAGE_MCDC}>
        >:-fcoverage-mcdc
      >)
      string(CONCAT prefix.map $<
        $<BOOL:${LLVM_COVERAGE_PREFIX_MAP}>:-fcoverage-prefix-map=
        $<JOIN:${LLVM_COVERAGE_PREFIX_MAP},$<SEMICOLON>-fcoverage-prefix-map=>
      >)
      set(instrumented.filename -fprofile-instr-generate=${LLVM_INSTRUMENTED_FILENAME})
      set_property(GLOBAL APPEND PROPERTY ${prefix}::options::compile
        $<$<COMPILE_LANG_AND_ID:${language},AppleClang,Clang>:${instrumented.filename}>
        $<$<COMPILE_LANG_AND_ID:${language},AppleClang,Clang>:-fcoverage-mapping>
        ${prefix.map}
        ${mcdc})
      set_property(GLOBAL APPEND PROPERTY ${prefix}::options::link
        $<$<LINK_LANG_AND_ID:${language},AppleClang,Clang>:${instrumented.filename}>)
    endforeach()
  endblock()

endif()

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "Code Coverage Support")

#[[
define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS INHERITED
  BRIEF_DOCS "Create absolute paths in the .gcno files"
  INITIALIZE_FROM_VARIABLE
    IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS)

]]
block (SCOPE_FOR VARIABLES)
  define_property(TARGET PROPERTY COVERAGE_LLVM_INSTRUMENTED_EXECUTABLES)
  define_property(TARGET PROPERTY COVERAGE_LLVM_INSTRUMENTED_SOURCES)

  define_property(TARGET
    PROPERTY COVERAGE_LLVM_INSTRUMENTED_FILENAME
    INITIALIZE_FROM_VARIABLE IXM_COVERAGE_LLVM_INSTRUMENTED_FILENAME)

  define_property(TARGET
    PROPERTY COVERAGE_LLVM_COVERAGE_PREFIX_MAP
    INITIALIZE_FROM_VARIABLE IXM_COVERAGE_LLVM_COVERAGE_PREFIX_MAP)

  define_property(TARGET PROPERTY COVERAGE_LLVM_MCDC)

  define_property(TARGET PROPERTY COVERAGE_LLVM_MERGE_FAILURE_MODE)
  define_property(TARGET PROPERTY COVERAGE_LLVM_MERGE_PROFILES)
  define_property(TARGET PROPERTY COVERAGE_LLVM_MERGE_OPTIONS)
  define_property(TARGET PROPERTY COVERAGE_LLVM_MERGE_SPARSE
    INITIALIZE_FROM_VARIABLE IXM_COVERAGE_LLVM_MERGE_SPARSE)

  define_property(TARGET PROPERTY COVERAGE_LLVM_EXPORT_IGNORE_FILENAME_REGEX
    INITIALIZE_FROM_VARIABLE IXM_COVERAGE_LLVM_EXPORT_IGNORE_FILENAME_REGEX)

  define_property(TARGET PROPERTY COVERAGE_GNU_ABSOLUTE_PATHS
    INITIALIZE_FROM_VARIABLE IXM_COVERAGE_GNU_ABSOLUTE_PATHS)
  define_property(TARGET PROPERTY COVERAGE_GNU_CONDITIONS
    INITIALIZE_FROM_VARIABLE IXM_COVERAGE_GNU_CONDITIONS)
endblock()

function (🈯::ixm::${CMAKE_FIND_PACKAGE_NAME}::cache)
  file(SHA256 "${CMAKE_CURRENT_LIST_DIR}/Internal/Coverage.cmake" cache)
  if (🈯::ixm::${CMAKE_FIND_PACKAGE_NAME}::CACHE STREQUAL cache)
    return()
  endif()
  include("${CMAKE_CURRENT_LIST_DIR}/Internal/Coverage.cmake")
  set(🈯::ixm::${CMAKE_FIND_PACKAGE_NAME}::CACHE "${cache}" YES CACHE INTERNAL "")
endfunction()

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
      COVERAGE_IMPLEMENTATION $<IF:$<BOOL:${ARG_LLVM}>,LLVM,GNU>)

  if (ARG_LLVM)
    string(CONCAT profile.data $<PATH:APPEND,
      ${CMAKE_CURRENT_BINARY_DIR},
      $<CONFIG>,
      $<PATH:REPLACE_EXTENSION,${name},profdata>
    >)

    ixm_target_property(LLVM_INSTRUMENTED_EXECUTABLES TARGET ${name} PREFIX COVERAGE)
    ixm_target_property(LLVM_INSTRUMENTED_EXECUTABLES TARGET ${name} PREFIX COVERAGE)
    ixm_target_property(LLVM_INSTRUMENTED_SOURCES TARGET ${name} PREFIX COVERAGE)

    ixm_target_property(LLVM_MERGE_FAILURE_MODE TARGET ${name} PREFIX COVERAGE)
    ixm_target_property(LLVM_MERGE_PROFILES TARGET ${name} PREFIX COVERAGE)
    ixm_target_property(LLVM_MERGE_OPTIONS TARGET ${name} PREFIX COVERAGE)
    ixm_target_property(LLVM_MERGE_SPARSE TARGET ${name} PREFIX COVERAGE)

    ixm_target_property(LLVM_EXPORT_IGNORE_FILENAME_REGEX
      OUTPUT_VARIABLE ignore.regex TARGET ${name} PREFIX COVERAGE)


    add_custom_command(OUTPUT "${profile.data}"
      COMMAND Coverage::LLVM::ProfileData merge
        --instr
        $<$<BOOL:${LLVM_MERGE_SPARSE}>:--sparse>
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

    ixm_target_property(IMPORTED_LOCATION
      OUTPUT_VARIABLE demangler
      TARGET $<TARGET_NAME_IF_EXISTS:Coverage::LLVM::C++Filter>)

    # TODO: Make the `cmake_pch` itself a property of "banned" files
    set(sources $<LIST:FILTER,${LLVM_INSTRUMENTED_SOURCES},EXCLUDE,cmake_pch>)
    # This drops empty items from the list.
    set(executables $<JOIN:${LLVM_INSTRUMENTED_EXECUTABLES},$<SEMICOLON>>)

    # It is beyond unfortunate that no one on the LLVM team ever thought "what
    # if someone is writing this to a file and doesn't want to rely on the
    # shell?" but LLVM rarely makes the right choice. We all just put up with
    # it. :(
    add_custom_command(OUTPUT "${ARG_OUTPUT}"
      COMMAND Coverage::LLVM::Tool export
        --format=${ARG_FORMAT}
        --instr-profile=${profile.data}
        $<$<BOOL:$<TARGET_NAME_IF_EXISTS:Coverage::LLVM::C++Filter>>:-Xdemangler=${demangler}>
        "--ignore-filename-regex=($<JOIN:${ignore.regex},|>)"
        $<LIST:TRANSFORM,${executables},PREPEND,--object$<SEMICOLON>>
        $<LIST:TRANSFORM,${sources},PREPEND,--sources$<SEMICOLON>>
      > "${ARG_OUTPUT}"
      DEPENDS
        ${profile.data}
      COMMENT "Exporting coverage information to ${ARG_OUTPUT}"
      COMMAND_EXPAND_LISTS
      USES_TERMINAL
      VERBATIM)
    # Setting this lets us merge multiple .profdata files for amalgamations
    set_property(TARGET ${name}
      PROPERTY
        COVERAGE_LLVM_INSTRUMENTED_FILENAME "${ARG_OUTPUT}")
    set_property(TARGET ${name} APPEND
      PROPERTY
        COVERAGE_DEPENDENCIES ${LLVM_MERGE_PROFILES})
    set_property(TARGET ${name} APPEND
      PROPERTY
        ADDITIONAL_CLEAN_FILES "${ARG_OUTPUT}")
  endif()
endfunction()

function (target_coverage name)
  cmake_parse_arguments(ARG "" "" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})
  get_property(implementation TARGET ${name} PROPERTY COVERAGE_IMPLEMENTATION)

  foreach (visibility IN ITEMS PRIVATE PUBLIC)
    foreach (target IN LISTS ARG_${visibility})
      set(is.executable $<STREQUAL:$<TARGET_PROPERTY:${target},TYPE>,EXECUTABLE>)
      string(CONCAT is.mergeable $<IN_LIST:
        $<TARGET_PROPERTY:${target},TYPE>,
        $<LIST:APPEND,EXECUTABLE,UTILITY>
      >)
      ixm_target_property(LLVM_INSTRUMENTED_FILENAME PREFIX COVERAGE TARGET ${target} CONTEXT)
      set(instrumented $<${is.executable}:${LLVM_INSTRUMENTED_FILENAME}>)
      set(merged $<${is.mergeable}:${LLVM_INSTRUMENTED_FILENAME}>)
      set_property(TARGET ${name} APPEND
        PROPERTY
          COVERAGE_LLVM_INSTRUMENTED_SOURCES $<TARGET_PROPERTY:${target},SOURCES>)
      set_property(TARGET ${name} APPEND
        PROPERTY
          COVERAGE_LLVM_INSTRUMENTED_EXECUTABLES $<${is.executable}:$<TARGET_FILE:${target}>> )
      set_property(TARGET ${name} APPEND
        PROPERTY
          COVERAGE_LLVM_MERGE_PROFILES ${merged})
      set_property(TARGET ${name} APPEND
        PROPERTY
          ADDITIONAL_CLEAN_FILES ${instrumented})
      # We only add the link libraries call for targets that aren't genexpr
      string(GENEX_STRIP "${target}" stripped)
      if (target STREQUAL stripped)
        target_link_libraries(${target}
          ${visibility}
            Coverage::${implementation})
      endif()
    endforeach()
  endforeach()
endfunction()

cmake_language(CALL 🈯::ixm::${CMAKE_FIND_PACKAGE_NAME}::cache)
