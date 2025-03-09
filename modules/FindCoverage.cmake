cmake_language(CALL ixm::find::program
  NAMES gcov-tool
  PACKAGE
    COMPONENT GNU
    TARGET Merge)

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
    TARGET Merge)

cmake_language(CALL ixm::find::program
  NAMES lcov
  PACKAGE
    COMPONENT Report
    TARGET LTP
    OPTIONAL)
cmake_language(CALL ixm::find::program
  NAMES gcovr
  PACKAGE
    COMPONENT Report
    TARGET GCovR
    OPTIONAL)
cmake_language(CALL ixm::find::program
  NAMES llvm-cov
  PACKAGE
    COMPONENT Report
    TARGET LLVM
    OPTIONAL)

block (SCOPE_FOR VARIABLES PROPAGATE Coverage_Report_DEFAULT)
  # Users can set this prior to this line as either a cache variable or a
  # normal variable and it will "just work" and use their definition instead.
  set(Coverage_Report_TARGETS GCovR LLVM LTP
    CACHE "STRING" "Order of targets to search for viability")
  foreach (reporter IN LISTS Coverage_Report_TARGETS)
    if (Coverage_Report_${reporter}_EXECUTABLE)
      set(Coverage_Report_DEFAULT Coverage::Report::${reporter})
    endif()
  endforeach()
  set_property(GLOBAL APPEND PROPERTY Coverage::Report::variables Coverage_Report_DEFAULT)
endblock()


block (SCOPE_FOR VARIABLES PROPAGATE Coverage_GNU_FLAG)
  set(Coverage_GNU_FLAG "--coverage")
  set(target Coverage::GNU)
  set(prefix ${target}:{${target}})
  set_property(GLOBAL APPEND PROPERTY ${target}::targets ${target})
  set_property(GLOBAL APPEND PROPERTY ${target}::variables Coverage_GNU_FLAG)
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

block (SCOPE_FOR VARIABLES PROPAGATE Coverage_LLVM_COMPILE_FLAG Coverage_LLVM_LINK_FLAG)
  set(Coverage_LLVM_COMPILE_FLAG "-fprofile-instr-generate -fcoverage-mapping")
  set(Coverage_LLVM_LINK_FLAG "-fprofile-inst-generate")

  set(target Coverage::LLVM)
  set(prefix ${target}::{${target}})
  set_property(GLOBAL APPEND PROPERTY ${target}::targets ${target})
  set_property(GLOBAL APPEND PROPERTY ${target}::variables
    Coverage_Report_LLVM_EXECUTABLE # llvm-cov is OPTIONAL for Report, but not for LLVM
    Coverage_LLVM_COMPILE_FLAG
    Coverage_LLVM_LINK_FLAG)

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

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "Code Coverage Support")

# Post-search clean up
foreach (reporter IN ITEMS GCovR LLVM LTP)
  if (TARGET Coverage::Report::${reporter})
    string(CONCAT script.path $<PATH:APPEND
      ${IXM_ROOT_DIR},
      templates,
      coverage,
      report,
      $<LOWER_CASE:$<TARGET_PROPERTY:${reporter},NAME>>.cmake.in
    >)
    set_property(TARGET Coverage::Report::${reporter}
      PROPERTY
        COVERAGE_REPORT_SCRIPT_TEMPLATE "${script.path}")
  endif()
endforeach()


#[[
define_property(TARGET
  PROPERTY ${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS INHERITED
  BRIEF_DOCS "Create absolute paths in the .gcno files"
  INITIALIZE_FROM_VARIABLE
    IXM_${CMAKE_FIND_PACKAGE_NAME}_GNU_ABSOLUTE_PATHS)

]]
define_property(TARGET PROPERTY COVERAGE_IMPLEMENTATION)

define_property(TARGET PROPERTY COVERAGE_REPORT_SCRIPT_PATH)
define_property(TARGET PROPERTY COVERAGE_REPORT_SCRIPT_ECHO)
define_property(TARGET PROPERTY COVERAGE_REPORT_LOCATION)
define_property(TARGET PROPERTY COVERAGE_REPORT_FORMAT)

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

#[============================================================================[
# @param {option} LLVM - Set the coverage target type to use source-based code
# coverage
# @param {option} GNU - Set the coverage target type to use gcov.
# @param {filepath} [OUTPUT] - Set the filepath to write the target's merged
# profile data.
#]============================================================================]
function (add_coverage_target name)
  cmake_parse_arguments(ARG "LLVM;GNU" "FORMAT" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::coverage::type "targets")


  cmake_language(CALL 🈯::ixm::coverage::target ${name})

  if (ARG_LLVM)
    cmake_language(CALL 🈯::ixm::coverage::llvm::merge ${name})
  endif()
endfunction()

#[============================================================================[
# @param {string} FORMAT - File format to generate the report in. This depends
# on which reporter is being used.
#]============================================================================]
function (add_coverage_report name)
  cmake_parse_arguments(ARG "LLVM;GNU" "OUTPUT;FORMAT" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::coverage::type "reports")

  if (ARG_LLVM)
    cmake_language(CALL 🈯::ixm::default ARG_FORMAT JSON)
    cmake_language(CALL 🈯::ixm::requires::choice FORMAT LCOV JSON)
    cmake_language(CALL 🈯::ixm::default ARG_OUTPUT $* $<PATH:APPEND,
      ${CMAKE_CURRENT_BINARY_DIR},
      $<CONFIG>,
      ${name}.$<LOWER_CASE:${ARG_FORMAT}>
    >)
  endif()

  cmake_language(CALL 🈯::ixm::coverage::target ${name})

  if (ARG_LLVM)
    cmake_language(CALL 🈯::ixm::coverage::llvm::merge ${name})
    cmake_language(CALL 🈯::ixm::coverage::llvm::export ${name})
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

include("${CMAKE_CURRENT_LIST_DIR}/runtime/coverage.cmake")
