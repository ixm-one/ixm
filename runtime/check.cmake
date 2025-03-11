include_guard(GLOBAL)

include(CMakePushCheckState)
include(CheckSourceCompiles)
include(CheckCompilerFlag)
include(CheckIncludeFiles)
include(CheckLinkerFlag)
include(CheckSourceRuns)

#[============================================================================[
# @param {string} language - Which language to check the compiler flag against
# @param {string} flag - compiler flag to check is valid.
# @param {list} [COMPILE_OPTIONS] - additional flags to pass to the compiler.
# @param {list} [LINK_OPTIONS] - flags to pass to the link command.
# @param {bool} [QUIET] - suppresses status messages if `true`.
# @param {string} [OUTPUT_VARIABLE=$<MAKE_C_IDENTIFIER:${flag}>] -
# variable to set the return value to. If this is not set the default
# `OUTPUT_VARIABLE` is the C identifier form of the flag passed in.
# @returns {cache:bool} - The result of the operation is stored in
# OUTPUT_VARIABLE and is stored as an internal cache variable.
#]============================================================================]
function (ixm::check::option::compile language flag)
  cmake_language(CALL 🈯::ixm::check::prelude "" "" "" ${ARGN})
  if (NOT ARG_OUTPUT_VARIABLE)
    string(MAKE_C_IDENTIFIER "${flag}" ARG_OUTPUT_VARIABLE)
  endif()

  check_compiler_flag(${language} "${flag}" ${ARG_OUTPUT_VARIABLE})
endfunction()

function (ixm::check::option::link language flag)
  cmake_language(CALL 🈯::ixm::check::prelude "" "" ${ARGN})
  # Override any `TARGET_TYPE` arguments. This command is useless if it's not
  # set to EXECUTABLE, as there is no way to check for archiver flags.
  set(CMAKE_TRY_COMPILE_TARGET_TYPE EXECUTABLE)

  if (NOT ARG_OUTPUT_VARIABLE)
    string(MAKE_C_IDENTIFIER "${flag}" ARG_OUTPUT_VARIABLE)
  endif()

  check_linker_flag(${language} "${flag}" ${ARG_OUTPUT_VARIABLE})
endfunction()

#[============================================================================[
# Checks for the provided header file for the given language.
#
# @param {filename} header - Name of header file to check for existence
# @param {string} [LANGUAGE] - which language's compiler to use for checks.
# @param {string} [OUTPUT_VARIABLE=$<UPPER_CASE:$<MAKE_C_IDENTIFIER:HAVE_${header}>>]
# @param {list<string|define>} [COMPILE_DEFINITIONS]
# @param {list} [COMPILE_OPTIONS]
# @param {list} [INCLUDE_DIRECTORIES]
# @param {list} [LINK_OPTIONS]
# @param {list} [COMPILE_OPTIONS]
# @param {list} [LIBRARIES]
# @param {list<filename>} [HEADERS]
# @param {bool} [QUIET] - suppresses status messages if `true`
# @remarks If this function does not meet your needs, use the
# CMakePushCheckState and CheckIncludeFiles modules instead.
#]============================================================================]
function (ixm::check::include header)
  cmake_language(CALL 🈯::ixm::check::prelude "" "LANGUAGE" "HEADERS" ${ARGN})

  if (ARG_LANGUAGE)
    set(language LANGUAGE ${ARG_LANGUAGE})
  endif()

  if (NOT ARG_OUTPUT_VARIABLE)
    string(MAKE_C_IDENTIFIER "${header}" ARG_OUTPUT_VARIABLE)
    string(TOUPPER "HAVE_${ARG_OUTPUT_VARIABLE}" ARG_OUTPUT_VARIABLE)
  endif()

  check_include_files("${header};${ARG_HEADERS}" ${ARG_OUTPUT_VARIABLE} ${language})
endfunction()

function (ixm::check::compiles)
  cmake_language(CALL 🈯::ixm::check::prelude "" "LANGUAGE;CODE" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::requires OUTPUT_VARIABLE)
  cmake_language(CALL 🈯::ixm::requires LANGUAGE)
  cmake_language(CALL 🈯::ixm::requires CODE)

  check_source_compiles("${ARG_LANGUAGE}" "${ARG_CODE}" "${ARG_OUTPUT_VARIABLE}" ${ARG_UNPARSED_ARGUMENTS})
endfunction()

if (NOT DEFINED IXM_DISABLE_CHECK_RUNS_COMMAND)

function (ixm::check::runs)
  cmake_language(CALL 🈯::ixm::check::prelude "" "LANGUAGE;CODE" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::check::requires OUTPUT_VARIABLE)
  cmake_language(CALL 🈯::ixm::check::requires LANGUAGE)
  cmake_language(CALL 🈯::ixm::check::requires CODE)

  check_source_runs("${ARG_LANGUAGE}" "${ARG_CODE}" "${ARG_OUTPUT_VARIABLE}" ${ARG_UNPARSED_ARGUMENTS})
endfunction()

endif()

macro(🈯::ixm::check::prelude options monadic variadic)
  cmake_parse_arguments(ARG
    "QUIET;${options}"
    "OUTPUT_VARIABLE;TARGET_TYPE;${monadic}"
    "COMPILE_DEFINITIONS;INCLUDE_DIRECTORIES;COMPILE_OPTIONS;LINK_OPTIONS;LIBRARIES;${variadic}"
    ${ARGN})

  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LINK_OPTIONS ${ARG_LINK_OPTIONS})
  set(CMAKE_REQUIRED_LIBRARIES ${ARG_LIBRARIES})
  set(CMAKE_REQUIRED_INCLUDES ${ARG_INCLUDE_DIRECTORIES})
  set(CMAKE_REQUIRED_QUIET ${ARG_QUIET})

  set(CMAKE_TRY_COMPILE_TARGET_TYPE ${ARG_TARGET_TYPE})
  if (NOT CMAKE_TRY_COMPILE_TARGET_TYPE)
    unset(CMAKE_TRY_COMPILE_TARGET_TYPE)
  endif()

  list(JOIN ARG_COMPILE_OPTIONS " " CMAKE_REQUIRED_FLAGS)
  list(TRANSFORM ARG_COMPILE_DEFINITIONS
    PREPEND "-D"
    REGEX "[^-][^D]"
    OUTPUT_VARIABLE CMAKE_REQUIRED_DEFINITIONS)
endmacro()
