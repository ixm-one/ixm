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

#[[Used to set missing arguments to a well known default]]
macro(🈯::ixm::default var default)
  if (NOT ${var})
    set(${var} ${default})
  endif()
endmacro()

macro(🈯::ixm::requires name)
  if (NOT ARG_${name})
    message(FATAL_ERROR "function '${CMAKE_CURRENT_FUNCTION}' requires a '${name}' argument")
  endif()
endmacro()
