include_guard(GLOBAL)

#[============================================================================[
# @summary Finds the desired executable. Optionally, finds the program's
# version value as well if requested.
#
# @description When this function is called inside of a `find_package(MODULE)`
# file, it will automatically perform bookkeeping for automatic component and
# target discovery and creating imported targets.
#
# @param {string|string[]} NAMES - Names of the executable to find
# @param {identifier} [OUTPUT_VARIABLE]
# @param {string} DESCRIPTION
# @param {option} [QUIET]
# @param {option} [PACKAGE.OPTIONAL]
# @param {string} [PACKAGE.COMPONENT]
# @param {string} [PACKAGE.TARGET]
# @param {identifier} [VERSION.OUTPUT_VARIABLE]
# @param {string} VERSION.DESCRIPTION
# @param {string} [VERSION.OPTION]
# @param {string} [VERSION.REGEX]
# @param {option} [VERSION.QUIET] - suppresses status messages if set
# @returns {cache:filepath} - the result of the operation is stored in the
# variable specified by `OUTPUT_VARIABLE`, which is stored as a cache variable.
#]============================================================================]
function (ixm::find::program)
  cmake_language(CALL 🈯::ixm::find::prologue "" "" "VERSION" ${ARGN})
  ixm_fallback(ARG_OUTPUT_VARIABLE ${name}_EXECUTABLE)

  find_program(${ARG_OUTPUT_VARIABLE} NAMES ${ARG_NAMES} ${ARG_UNPARSED_ARGUMENTS})
  cmake_language(CALL 🈯::ixm::find::log)
  cmake_language(CALL 🈯::ixm::find::properties ${prefix}::{${target}}::program)

  if (ARG_VERSION AND ARG_OUTPUT_VARIABLE)
    cmake_parse_arguments(VERSION "" "OPTION;REGEX;VARIABLE;DESCRIPTION" "" ${ARG_VERSION})
    ixm_fallback(VERSION_VARIABLE ${name}_VERSION)
    cmake_language(CALL 🈯::ixm::find::version
      OUTPUT_VARIABLE ${VERSION_VARIABLE}
      DESCRIPTION "${VERSION_DESCRIPTION}"
      COMMAND "${${ARG_OUTPUT_VARIABLE}}"
      OPTION "${VERSION_OUTPUT}"
      REGEX "${VERSION_REGEX}"
      QUIET "${ARG_QUIET}")
  endif()
endfunction()

#[============================================================================[
# @summary Finds the desired library. Optionally, finds a header if requested
# as well.
#
# @description When this function is called inside of a `find_package(MODULE)`
# file, it will automatically perform bookkeeping for automatic component
# discovery and creating imported targets.
# @param {string|string[]} NAMES - Names of the library to find.
# @param {identifier} OUTPUT_VARIABLE
# @param {string} DESCRIPTION
# @param {option} QUIET
# @param {option} [PACKAGE.OPTIONAL]
# @param {string} [PACKAGE.COMPONENT]
# @param {string} [PACKAGE.TARGET]
# @param {identifier} [VERSION.OUTPUT_VARIABLE]
# @returns {cache:filepath} - The result of the operation is stored in the
# variable specified by `OUTPUT_VARIABLE`, which is stored as a cache variable.
#]============================================================================]
function (ixm::find::library)
  cmake_language(CALL 🈯::ixm::find::prologue "" "" "HEADER" ${ARGN})
  ixm_fallback(ARG_OUTPUT_VARIABLE ${name}_LIBRARY)

  if (DEFINED ARG_HEADER)
    cmake_parse_arguments(HEADER "" "VARIABLE" "" ${ARG_HEADER})
    ixm_fallback(HEADER_VARIABLE ${name}_INCLUDE_DIR)
  endif()

  find_library(${ARG_OUTPUT_VARIABLE} NAMES ${ARG_NAMES} ${ARG_UNPARSED_ARGUMENTS})
  cmake_language(CALL 🈯::ixm::find::log)
  cmake_language(CALL 🈯::ixm::find::properties ${prefix}::{${target}}::library)

  if (ARG_HEADER)
    if (ARG_QUIET)
      list(APPEND HEADER_UNPARSED_ARGUMENTS QUIET)
    endif()
    cmake_language(CALL ixm::find::header
      OUTPUT_VARIABLE "${HEADER_VARIABLE}"
      ${HEADER_UNPARSED_ARGUMENTS}
      PACKAGE
        COMPONENT "${PACKAGE_COMPONENT}"
        TARGET "${PACKAGE_TARGET}")
  endif()
endfunction()

#[============================================================================[
# @summary Finds the directory a file resides under.
#
# @description This function is *typically* used for finding header files. As a
# result, when the function is called inside of a `find_package(MODULE)` file,
# it will perform bookkeeping for automatic component discovery and creating
# imported targets *as if the file being searched for will be included via the
# C/C++ preprocessor.
# TODO: This function needs to be broken up into ::header and ::path. We want
# to accept more than just headers for searches
#]============================================================================]
function (ixm::find::header)
  cmake_language(CALL 🈯::ixm::find::prologue "" "" "" ${ARGN})
  ixm_fallback(ARG_OUTPUT_VARIABLE ${name}_INCLUDE_DIR)

  find_path(${ARG_OUTPUT_VARIABLE} NAMES ${ARG_NAMES} ${ARG_UNPARSED_ARGUMENTS})
  cmake_language(CALL 🈯::ixm::log)
  cmake_language(CALL 🈯::ixm::find::properties ${prefix}::{${target}}::include)
endfunction()

#[============================================================================[
# @summary Finds the desired Apple Framework.
#
# @description When this function is called inside of a `find_package(MODULE)`,
# it will automatically perform bookkeeping for automatic component discovery
# and creating imported targets.
#]============================================================================]
function (ixm::find::framework)
  cmake_language(CALL ixm::unimplemented)
  #[[
  cmake_language(CALL 🈯::ixm::find::prologue "" "" "" ${ARGN})
  if (DEFINED ARG_HEADER)
    cmake_parse_arguments(HEADER "" "VARIABLE" "NAMES" ${ARG_HEADER})
    ixm_fallback(HEADER_VARIABLE ${name}_INCLUDE_DIR)

    # check what name is
    ixm_fallback(HEADER_NAMES "${name}/${name}.h")
  endif()
  find_library(${ARG_OUTPUT_VARIABLE} NAMES ${ARG_NAMES} ${ARG_UNPARSED_ARGUMENTS})
  find_path(${HEADER_VARIABLE} NAMES ${HEADER_NAMES} ${ARG_UNPARSED_ARGUMENTS})
  cmake_language(CALL 🈯::ixm::find::log)
  cmake_language(CALL 🈯::ixm::properties ${prefix}::${target}::framework)
  #]]
endfunction()

# TODO: This can be made into a "check executable output" or some similar
# wrapper under ixm::check
#[[ Finds a program version ]]
function (🈯::ixm::find::version)
  cmake_parse_arguments(ARG "" "QUIET;OUTPUT_VARIABLE;DESCRIPTION;COMMAND;OPTION;REGEX" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::requires OUTPUT_VARIABLE)
  ixm_fallback(ARG_DESCRIPTION "${ARG_COMMAND} version")
  ixm_fallback(ARG_OPTION "--version")
  ixm_fallback(ARG_REGEX
    # This is a magic regex. It works in 95% of all cases.
    "[^0-9]*([0-9]+)[.]([0-9]+)?[.]?([0-9]+)?[.]?([0-9]+)?.*")
  if (NOT IS_EXECUTABLE "${ARG_COMMAND}")
    message(FATAL_ERROR "'${ARG_COMMAND}' is not executable and therefore it's version cannot be detected.")
  endif()

  # Executing commands a lot is no bueno, and we don't have a find_version
  # command, sadly that knows how to cache properly in the way CMake does.
  if (ARG_COMMAND AND NOT ${ARG_OUTPUT_VARIABLE})
    execute_process(
      COMMAND "${ARG_COMMAND}" "${ARG_OPTION}"
      OUTPUT_VARIABLE version.output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ENCODING UTF-8)
    if (version.output MATCHES "${ARG_REGEX}")
      string(JOIN "." ${ARG_OUTPUT_VARIABLE}
        ${CMAKE_MATCH_1}
        ${CMAKE_MATCH_2}
        ${CMAKE_MATCH_3}
        ${CMAKE_MATCH_4})
      set(${ARG_OUTPUT_VARIABLE} "${${ARG_OUTPUT_VARIABLE}}" CACHE STRING "${ARG_DESCRIPTION}")
    endif()
    cmake_language(CALL 🈯::ixm::find::log)
    set_property(GLOBAL PROPERTY ${prefix}::{${target}}::version "${${ARG_OUTPUT_VARIABLE}}")
  endif()
endfunction()

function (🈯::ixm::find::properties property)
  if (DEFINED CMAKE_FIND_PACKAGE_NAME)
    set_property(GLOBAL PROPERTY ${property} "${${ARG_OUTPUT_VARIABLE}}")
    if (NOT PACKAGE_OPTIONAL)
      set_property(GLOBAL APPEND
        PROPERTY
          ${prefix}::variables ${ARG_OUTPUT_VARIABLE})
    endif()
  endif()
endfunction()

# Add the result to the CMake configure log
function (🈯::ixm::find::log)
  # We mark the found variable as advanced but only if it was found, otherwise
  # the check will happen each time regardless.
  get_property(found-before CACHE ${ARG_OUTPUT_VARIABLE} PROPERTY ADVANCED)
  if (NOT found-before)
    set(call-site "${CMAKE_CURRENT_FUNCTION}")
    if (CMAKE_FIND_PACKAGE_NAME)
      string(PREPEND call-site "${CMAKE_FIND_PACKAGE_NAME}/")
      string(APPEND call-site "(${CMAKE_CURRENT_LIST_LINE})")
    endif()
    message(CONFIGURE_LOG
      "${call-site}: ${ARG_OUTPUT_VARIABLE}"
      "= ${${ARG_OUTPUT_VARIABLE}}")
  endif()
endfunction()

macro (🈯::ixm::find::prologue options monadic variadic)
  message(TRACE "Parsing ixm::find arguments")
  cmake_parse_arguments(ARG
    "QUIET;${options}"
    "OUTPUT_VARIABLE;DESCRIPTION;${monadic}"
    "NAMES;PACKAGE;${variadic}"
    ${ARGN})

  if (CMAKE_FIND_PACKAGE_NAME)
    ixm_fallback(ARG_NAMES ${CMAKE_FIND_PACKAGE_NAME})
    block (SCOPE_FOR VARIABLES PROPAGATE ARG_DESCRIPTION)
      list(LENGTH ARG_NAMES length)
      if (length EQUAL 1)
        ixm_fallback(ARG_DESCRIPTION "Path to ${ARG_NAMES}")
      endif()
    endblock()

    cmake_parse_arguments(PACKAGE "OPTIONAL" "COMPONENT;TARGET" "" ${ARG_PACKAGE})
    set(target ${CMAKE_FIND_PACKAGE_NAME}::${CMAKE_FIND_PACKAGE_NAME})
    set(prefix ${CMAKE_FIND_PACKAGE_NAME})
    set(name ${CMAKE_FIND_PACKAGE_NAME})

    if (PACKAGE_COMPONENT)
      set_property(GLOBAL APPEND PROPERTY ${prefix}::components ${PACKAGE_COMPONENT})
      set(target ${CMAKE_FIND_PACKAGE_NAME}::${PACKAGE_COMPONENT})
      set(name ${CMAKE_FIND_PACKAGE_NAME}_${PACKAGE_COMPONENT})
      set(prefix ${prefix}::${PACKAGE_COMPONENT})
    endif()

    if (PACKAGE_COMPONENT AND PACKAGE_TARGET)
      set(name ${name}_${PACKAGE_TARGET})
    endif()

    # If the TARGET contains `::` we just use the whole name *for* the target,
    # but there needs to be characters surrounding the `::`
    if (PACKAGE_TARGET MATCHES ".::.")
      set(target ${PACKAGE_TARGET})
    elseif (PACKAGE_TARGET)
      set(target ${target}::${PACKAGE_TARGET})
    endif()

    set_property(GLOBAL APPEND PROPERTY ${prefix}::targets ${target})
  endif()
endmacro()
