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
