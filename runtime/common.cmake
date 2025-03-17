include_guard(GLOBAL)

#[[ Small helper function to error when a function is just a stub ]]
function (ixm::unimplemented)
  message(FATAL_ERROR "This command is not yet implemented")
endfunction()

#[[
Provide any expression to the function and it will error if it cannot be
evaluated.
]]
function (ixm::assert)
  string(JOIN " " ARGN ${ARGN})
  cmake_language(EVAL CODE "
    if (NOT (${ARGN}))
      message(FATAL_ERROR [[ASSERTION FAILED '${ARGN}' evaluated to false]])
    endif()
  ")
endfunction()

#[[
Creates a renderable hyperlink usable for the current interface that is
rendering CMake output. When using a hyperlink capable terminal, this will use
ANSI escape codes.
]]
function (ixm::hyperlink output)
  get_property(hyperlinks GLOBAL PROPERTY 🈯::ixm::supports::hyperlinks)
  cmake_parse_arguments(ARG "" "URL;TEXT" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::requires TEXT)
  cmake_language(CALL 🈯::ixm::requires URL)
  if (hyperlinks)
    string(ASCII 27 ESC)
    string(ASCII 7 SEP)
    set(${output} "${ESC}]8;;${ARG_URL}${SEP}${ARG_TEXT}${ESC}]8;;${SEP}")
  else()
    set(${output} "${ARG_TEXT} (${ARG_URL})")
  endif()
  return(PROPAGATE ${output})
endfunction()

#[[
Preserves `CMAKE_MATCH_<N>` and `CMAKE_MATCH_COUNT` as `MATCH{<N>}` and
`MATCH{COUNT}`. This also replaces instances of `CMAKE_MATCH_<N>` with the
`MATCH{<N>}` equivalent in the calling scope.
]]
function (ixm::matches)
  set(MATCH{COUNT} ${CMAKE_MATCH_COUNT} PARENT_SCOPE)
  unset(CMAKE_MATCH_COUNT PARENT_SCOPE)
  foreach (n RANGE MATCH{COUNT})
    set(MATCH{${n}} ${CMAKE_MATCH_${n}} PARENT_SCOPE)
    unset(CMAKE_MATCH_${n} PARENT_SCOPE)
  endforeach()
endfunction()

function (🈯::ixm::experiment name uuid)
  if (NOT IXM_EXPERIMENTAL_${name} STREQUAL "${uuid}")
    message(SEND_ERROR "Experiment opt-in '${name}' is not set to its correct UUID")
  endif()
endfunction()

macro(🈯::ixm::requires name)
  if (NOT ARG_${name})
    message(FATAL_ERROR "function '${CMAKE_CURRENT_FUNCTION}' requires a '${name}' argument")
  endif()
endmacro()

#[============================================================================[
# @summary Sets a default fallback value for a variable if it is not defined.
# @description This is intended to be used inside of `function()`s after a call
# to `cmake_parse_arguments`. While there is technically nothing stopping its
# use in a general scope, users will most likely not receive this functions
# benefits.
# @param {identifier} variable - name of variable to set a fallback value for.
#]============================================================================]
function (ixm_fallback variable)
  if (NOT DEFINED ${variable})
    set(${variable} ${ARGN} PARENT_SCOPE)
  endif()
endfunction()
#[============================================================================[
# @summary Creates a generator expression for reading from a target property.
# @description This command permits creating generator expressions for targets
# that are *not yet defined*, even if the `TARGET` parameter is passed in.
#
# @param {identifier} property - Name of the property to create generator
# expression for.
# @param {option} [CONTEXT] - Use `TARGET_GENEX_EVAL` instead of `GENEX_EVAL`.
# Does nothing if `TARGET` has not been specified.
# @param {target} [TARGET] - Name of a target to use for context and scope.
# @param {identifier} [OUTPUT_VARIABLE=${property}] - Name of the variable to
# output.
# @param {list} [PREFIX] - Additional prefixes to prepend to the property.
# These are joined via the `_` character. Useful if `OUTPUT_VARIABLE` is not
# provided, as this allows for more complex property generator expressions with
# simple output variables.
#]============================================================================]
function (ixm_property property)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "CONTEXT" "TARGET;OUTPUT_VARIABLE" "PREFIX")
  ixm_fallback(ARG_OUTPUT_VARIABLE ${property})
  string(JOIN _ property ${ARG_PREFIX} ${property})

  set(eval GENEX_EVAL:)
  set(target)
  if (ARG_TARGET)
    set(target "${ARG_TARGET},") # note the `,` at the end of the string
    if (ARG_CONTEXT)
      set(eval TARGET_GENEX_EVAL:${target})
    endif()
  endif()

  set(${ARG_OUTPUT_VARIABLE} "$<${eval}$<TARGET_PROPERTY:${target}${property}>>" PARENT_SCOPE)
endfunction()
