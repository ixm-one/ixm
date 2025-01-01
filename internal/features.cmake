include_guard(GLOBAL)

#[============================================================================[
# @summary Wrapper for creating both options and features in a structured and
# self documenting manner.
#
# @description This command operates as a wrapper around both the
# `cmake_dependent_option` and `add_feature_info` commands provided by CMake.
# However, the way arguments are laid out allows for a more structured and
# self-documenting approach. Features are a boolean value. For string based
# values, either use `ixm::choice`, or set cache variables normally.
#
# @param {identifier} NAME
# @param {identifier} OPTION
# @param {boolean} [DEFAULT]
# @param {string} [DESCRIPTION]
# @param {option} [PREDEFINED]
# @param {option} [PROJECT_ONLY]
# @param {condition[]} [REQUIRES]
#]============================================================================]
function (ixm::feature)
  # Each of these if something you'd find in an `if` statement, but we auto
  # construct them.
  set(requirement.types PACKAGES TARGETS EXISTS FILES DIRECTORIES CONDITIONS)
  cmake_parse_arguments(ARG "PREDEFINED;PROJECT_ONLY" "NAME;OPTION;DEFAULT;DESCRIPTION" "REQUIRES" ${ARGN})
  cmake_parse_arguments(REQUIRES "" "" "${requirement.types}" ${ARG_REQUIRES})
  cmake_language(CALL 🈯::ixm::requires OPTION)
  cmake_language(CALL 🈯::ixm::requires NAME)
  cmake_language(CALL 🈯::ixm::feature::requirements)

  cmake_language(CALL 🈯::ixm::default ARG_DEFAULT NO)

  if (ARG_PROJECT_ONLY)
    list(APPEND requirements PROJECT_IS_TOP_LEVEL)
  endif()

  if (NOT ARG_PREDEFINED)
    cmake_dependent_option(${ARG_OPTION} "${ARG_DESCRIPTION}" ${ARG_DEFAULT} "${requirements}" OFF)
  endif()

  add_feature_info("${ARG_NAME}" ${ARG_OPTION} "${ARG_DESCRIPTION}")
endfunction()

#[============================================================================[
# @summary Creates a configurable 'choice' that can be one of several values.
#
# @param {identifier} NAME
# @param {string[]} VALUES - The possible values for a user to select from.
# @param {*} DEFAULT - The default value for the choice to be if not set.
#]============================================================================]
function (ixm::choice)
  cmake_parse_arguments(ARG "ADVANCED" "DEFAULT;NAME;DESCRIPTION" "VALUES" ${ARGN})
  cmake_language(CALL 🈯::ixm::requires DEFAULT)
  cmake_language(CALL 🈯::ixm::requires VALUES)
  cmake_language(CALL 🈯::ixm::requires NAME)

  if (NOT ${ARG_NAME})
    set(${ARG_NAME} "${ARG_DEFAULT}" CACHE STRING "${ARG_DESCRIPTION}")
  endif()
  set_property(CACHE ${ARG_NAME} PROPERTY STRINGS ${ARG_VALUES})

  if (NOT ${ARG_NAME} IN_LIST ARG_VALUES)
    list(POP_BACK ARG_VALUES end)
    list(JOIN ARG_VALUES "," values)
    message(FATAL_ERROR
      "Expected ${ARG_NAME} to be one of ${values}, or ${end}."
      "Got '${${ARG_NAME}}'")
  endif()

  if (${ARG_NAME} AND ARG_ADVANCED)
    mark_as_advanced(${ARG_NAME})
  endif()
endfunction()

# This function doesn't *really* do any validation of inputs. Technically
# someone could shove a bunch of semi-colons in, but you can do that in CMake
# anyhow and the only person you're hurting is yourself.
macro (🈯::ixm::feature::requirements)
  unset(requirements)
  foreach (package IN LISTS REQUIRE_PACKAGES)
    list(APPEND requirements "${package}_FOUND")
  endforeach()
  foreach (target IN LISTS REQUIRE_TARGETS)
    list(APPEND requirements "TARGET ${target}")
  endforeach ()
  foreach (entry IN LISTS REQUIRE_EXISTS)
    list(APPEND requirements "EXISTS ${entry}")
  endforeach()
  foreach (filename IN LISTS REQUIRE_FILES)
    list(APPEND requirements "EXISTS ${filename} AND NOT IS_DIRECTORY ${filename} AND NOT IS_SYMLINK ${filename}")
  endforeach ()
  foreach (directory IN LISTS REQUIRE_DIRECTORIES)
    list(APPEND requirements "IS_DIRECTORY ${directory}")
  endforeach ()
  list(APPEND requirements ${REQUIRE_CONDITIONS})
endmacro()
