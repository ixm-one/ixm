include_guard(GLOBAL)

# These are cache variables that let us set defaults and ONLY update if the
# actual file itself has changed.
# While there is additional I/O on "first" or "fresh" runs, the overhead for
# incremental builds and setting `find_package` defaults is more than worth it.

# It also lets us ensure this file is only included ONCE per run (thankfully)

set(IXM_COVERAGE_LLVM_INSTRUMENTED_FILENAME
  $<PATH:APPEND,$<TARGET_PROPERTY:BINARY_DIR>,$<CONFIG>,$<TARGET_PROPERTY:NAME>.profraw>
  CACHE STRING "Default path for the LLVM .profraw file")

set(IXM_COVERAGE_LLVM_COVERAGE_PREFIX_MAP
  "$<TARGET_PROPERTY:SOURCE_DIR>=."
  CACHE STRING "Default coverage prefix map.")

set(IXM_COVERAGE_LLVM_MERGE_SPARSE YES
  CACHE BOOL "Add `--sparse` to llvm-profdata merge commands")

set(IXM_COVERAGE_LLVM_EXPORT_IGNORE_FILENAME_REGEX
  $<PATH:RELATIVE_PATH,${FETCHCONTENT_BASE_DIR},${CMAKE_BINARY_DIR}>
  CACHE STRING "Default filepaths to ignore")

set(IXM_COVERAGE_GNU_ABSOLUTE_PATHS NO
  CACHE BOOL "Create absolute paths in the .gcno files")
set(IXM_COVERAGE_GNU_CONDITIONS NO
  CACHE BOOL "Whether to instrument program conditions (GCC Only)")

mark_as_advanced(
  IXM_COVERAGE_LLVM_INSTRUMENTED_FILENAME

  IXM_COVERAGE_LLVM_COVERAGE_PREFIX_MAP

  IXM_COVERAGE_LLVM_MERGE_SPARSE

  IXM_COVERAGE_LLVM_EXPORT_IGNORE_FILENAME_REGEX

  IXM_COVERAGE_GNU_ABSOLUTE_PATHS
  IXM_COVERAGE_GNU_CONDITIONS
)

function (🈯::ixm::coverage::type kind)
  if (ARG_LLVM AND ARG_GNU)
    message(FATAL_ERROR "Coverage ${kind} targets may only have one of type: LLVM or GNU")
  endif()
endfunction()

function (🈯::ixm::coverage::target name)
  add_custom_target(${name}
    DEPENDS
      $<GENEX_EVAL:$<TARGET_PROPERTY:${name},COVERAGE_REPORT_LOCATION>>)

  set_property(TARGET ${name}
    PROPERTY
      COVERAGE_IMPLEMENTATION $<IF:$<BOOL:${ARG_LLVM}>,LLVM,GNU>)
endfunction()

function (🈯::ixm::coverage::llvm::merge name)
  set(timestamp.byproducts $<PATH:APPEND,${CMAKE_CURRENT_BINARY_DIR},$<CONFIG>,${name}-byproducts.timestamp>)
  set(profile.data $<PATH:APPEND,${CMAKE_CURRENT_BINARY_DIR},$<CONFIG>,${name}.profdata>)

  ixm_target_property(LLVM_INSTRUMENTED_EXECUTABLES TARGET ${name} PREFIX COVERAGE)

  ixm_target_property(LLVM_MERGE_FAILURE_MODE TARGET ${name} PREFIX COVERAGE)
  ixm_target_property(LLVM_MERGE_PROFILES TARGET ${name} PREFIX COVERAGE)
  ixm_target_property(LLVM_MERGE_OPTIONS TARGET ${name} PREFIX COVERAGE)
  ixm_target_property(LLVM_MERGE_SPARSE TARGET ${name} PREFIX COVERAGE)

  add_custom_command(OUTPUT "${profile.data}"
    COMMAND Coverage::LLVM::Merge merge
      --instr
      $<$<BOOL:${LLVM_MERGE_SPARSE}>:--sparse>
      $<$<BOOL:${LLVM_MERGE_FAILURE_MODE}>:--failure-mode=${LLVM_MERGE_FAILURE_MODE}>
      --output=${profile.data}
      ${LLVM_MERGE_OPTIONS}
      ${LLVM_MERGE_PROFILES}
    DEPENDS
      $<TARGET_NAME_IF_EXISTS:test>
      $<GENEX_EVAL:${LLVM_INSTRUMENTED_EXECUTABLES}>
      $<GENEX_EVAL:${LLVM_MERGE_PROFILES}>
    COMMENT "Merging profiling data to ${profile.data}"
    COMMAND_EXPAND_LISTS
    VERBATIM
  )

  # Setting this lets us merge multiple .profdata files for amalgamations
  set_property(TARGET ${name}
    PROPERTY
      COVERAGE_LLVM_INSTRUMENTED_FILENAME "${profile.data}")
  set_property(TARGET ${name} APPEND
    PROPERTY
      ADDITIONAL_CLEAN_FILES "${profile.data}")
  set_property(TARGET ${name} APPEND
    PROPERTY TRANSITIVE_COMPILE_PROPERTIES
      COVERAGE_LLVM_INSTRUMENTED_EXECUTABLES
      COVERAGE_LLVM_INSTRUMENTED_SOURCES)
endfunction()

function (🈯::ixm::coverage::llvm::export name)
  ixm_target_property(LLVM_INSTRUMENTED_FILENAME TARGET ${name} PREFIX COVERAGE)
  ixm_target_property(REPORT_SCRIPT_PATH TARGET ${name} PREFIX COVERAGE)

  ixm_target_property(LLVM_INSTRUMENTED_EXECUTABLES PREFIX COVERAGE)
  ixm_target_property(LLVM_INSTRUMENTED_SOURCES PREFIX COVERAGE)

  ixm_target_property(IMPORTED_LOCATION
    OUTPUT_VARIABLE demangler
    TARGET $<TARGET_NAME_IF_EXISTS:Coverage::LLVM::C++Filter>)

  # Do the same thing, but for sources
  # NAMESPACE generated with
  # python -m uuid
  #        --uuid uuid5
  #        --namespace @url
  #        --name ixm.one/find/coverage/report/llvm-cov.cmake.in
  string(UUID basename
    NAMESPACE 0b14e254-813c-50bf-a996-d997a15cb70b
    NAME ${name}
    TYPE SHA1)
  set(template.src "${IXM_TEMPLATES_DIR}/coverage/report/llvm-cov.cmake.in")
  set(script.src "${IXM_FILES_DIR}/${basename}.cmake.in")
  set(script.dst "${IXM_FILES_DIR}/${basename}-$<CONFIG>.cmake")
  # Some string work needs to be done *before* we use this script in CONTENT
  configure_file("${template.src}" "${script.src}" @ONLY NEWLINE_STYLE LF)

  file(GENERATE
    OUTPUT "${script.dst}"
    INPUT "${script.src}"
    TARGET ${name}
    NEWLINE_STYLE LF)

  add_custom_command(OUTPUT "${ARG_OUTPUT}"
    COMMAND "${CMAKE_COMMAND}" -P "${REPORT_SCRIPT_PATH}"
    DEPENDS
      "${LLVM_INSTRUMENTED_FILENAME}"
      "${REPORT_SCRIPT_PATH}"
    COMMENT "Exporting coverage information to ${ARG_OUTPUT}"
    COMMAND_EXPAND_LISTS
    VERBATIM)
  set_target_properties(${name}
    PROPERTIES
      COVERAGE_REPORT_SCRIPT_PATH "${script.dst}"
      COVERAGE_REPORT_LOCATION "${ARG_OUTPUT}"
      COVERAGE_REPORT_FORMAT "${ARG_FORMAT}")
endfunction()
