include_guard(GLOBAL)

#[[
Extract a version from a call to AC_INIT in `configure.ac`.
The output variable will be cached, and the DOC argument set as its
documentation string.
]]
function (extract_autoconf_version output)
  cmake_parse_arguments(ARG "ADVANCED" "FILE;REGEX;DOC" "" ${ARGN})
  if (NOT ARG_FILE)
    set(ARG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/configure.ac")
  endif()
  if (NOT ARG_REGEX)
    set(ARG_REGEX "^AC_INIT\\([^,]+,\\[([0-9]+)[.]([0-9]+)?[.]?([0-9]+)?\\].+$")
  endif()
  file(STRINGS "${ARG_FILE}" ac-init-line
    REGEX "^AC_INIT\\([^)]+\\)$"
    LIMIT_COUNT 1)
  if (ac-init-line)
    string(REGEX MATCH "${ARG_REGEX}" version-check "${ac-init-line}")
  endif()
  if (version-check)
    string(JOIN "." ${output} ${CMAKE_MATCH_1} ${CMAKE_MATCH_2} ${CMAKE_MATCH_3} ${CMAKE_MATCH_4})
    set(${output} "${${output}}" CACHE STRING "${ARG_DOC}" FORCE)
    if (ARG_ADVANCED)
      mark_as_advanced(${output})
    endif()
  endif()
endfunction()
