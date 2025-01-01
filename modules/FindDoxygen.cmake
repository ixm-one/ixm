# This FindDoxygen package overwrites the CMake FindDoxygen module so we can
# inject our own functions automatically, while still using the CMake
# FindDoxygen file for the imported targets and version checks.
block (SCOPE_FOR VARIABLES PROPAGATE DOXYGEN_FOUND DOXYGEN_VERSION)
  list(FIND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}" idx)
  if (idx EQUAL -1)
    message(FATAL_ERROR "${CMAKE_CURRENT_LIST_FILE} is not on the CMake Module Path. Please use find_package.")
  endif()
  list(REMOVE_AT CMAKE_MODULE_PATH ${idx})

  cmake_language(CALL ixm::package::arguments OUTPUT_VARIABLE arguments MODULE)
  find_package(Doxygen ${arguments})

  cmake_language(CALL ixm::package::properties
    DESCRIPTION "Generate documentation from source code"
    URL "https://doxygen.nl")
endblock()

function (add_doxygen_target target)
  cmake_parse_arguments(ARG "ALL" "INPUT;COMMENT" "" ${ARGN})
  if (NOT ARG_INPUT)
    get_property(ARG_INPUT GLOBAL PROPERTY 🈯::ixm::doxygen::template)
  endif()
  if (NOT ARG_COMMENT)
    set(ARG_COMMENT "Generating documentation for target '${target}' with Doxygen ${DOXYGEN_VERSION}")
  endif()
  set(args)
  if (ARG_ALL)
    set(args ALL)
  endif()
  set(working-directory-property $<GENEX_EVAL:$<TARGET_PROPERTY:${target},DOXYGEN_WORKING_DIRECTORY>>)
  set(configuration-file $<GENEX_EVAL:$<TARGET_PROPERTY:${target},DOXYGEN_CONFIGURATION_FILE>>)
  string(CONCAT sources $<JOIN:
    $<LIST:FILTER,$<TARGET_PROPERTY:${target},SOURCES>,EXCLUDE,([.]rule|${target}-$<CONFIG>)$>,
    " "
  >)
  set(timestamp "${CMAKE_CURRENT_BINARY_DIR}/${target}.timestamp")
  string(CONCAT working-directory $<IF:
    $<BOOL:${working-directory-property}>,
    ${working-directory-property},
    $<TARGET_PROPERTY:${target},SOURCE_DIR>
  >)
  add_custom_target(${target}
    ${args}
    DEPENDS
      "${timestamp}")
  add_custom_command(OUTPUT "${timestamp}"
    DEPENDS
      "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${target}.Doxyfile"
      $<GENEX_EVAL:$<TARGET_PROPERTY:${target},DOXYGEN_TARGET_DEPENDENCIES>>
      "$<LIST:FILTER,$<TARGET_PROPERTY:${target},SOURCES>,EXCLUDE,([.]rule|${target}-$<CONFIG>)$>"
    COMMAND Doxygen::doxygen "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${target}.Doxyfile"
    COMMAND "${CMAKE_COMMAND}" -E touch "${timestamp}"
    COMMENT "${ARG_COMMENT}"
    COMMAND_EXPAND_LISTS
    VERBATIM)
  file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${target}.Doxyfile"
    INPUT "${ARG_INPUT}"
    TARGET "${target}"
    NEWLINE_STYLE UNIX)
  set(exclude-pattern-defaults
    */.git/*
    */.svn/*
    */.hg/*
    */CMakeFiles/*
    */IXMFiles/*
    */_CPack_Packages/*
    */*.rule
    DartConfiguration.tcl
    CMakeLists.txt
    CMakeCache.txt)
  string(CONCAT warn-format $<
    $<STREQUAL:
      $<LIST:TRANSFORM,"${CMAKE_GENERATOR}",REPLACE,"^Visual Studio.*","Visual Studio">,
      "Visual Studio"
    >:
    "$file($line) : $text"
  >)
  message(TRACE "Setting default doxygen properties for '${target}'")
  set_target_properties(${target}
    PROPERTIES
      DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION}"
      DOXYGEN_PROJECT_BRIEF "${PROJECT_DESCRIPTION}"
      DOXYGEN_PROJECT_NAME "${PROJECT_NAME}"

      DOXYGEN_OUTPUT_DIRECTORY $<TARGET_PROPERTY:${target},BINARY_DIR>
      DOXYGEN_CONFIGURATION_FILE "${configuration-file}"
      DOXYGEN_WARN_FORMAT "${warn-format}"
      DOXYGEN_INPUT "${sources}"

      DOXYGEN_RECURSIVE YES
      DOXYGEN_QUIET YES

      DOXYGEN_MSCGEN_TOOL $<$<TARGET_EXISTS:Doxygen::mscgen>:$<TARGET_PROPERTY:Doxygen::mscgen,IMPORTED_LOCATION>>
      DOXYGEN_HAVE_DOT $<IF:$<TARGET_EXISTS:Doxygen::dot>,YES,NO>
      DOXYGEN_DOT_PATH $<$<TARGET_EXISTS:Doxygen::dot>:$<TARGET_PROPERTY:Doxygen::dot,IMPORTED_LOCATION>>
      DOXYGEN_DIA_PATH $<$<TARGET_EXISTS:Doxygen::dia>:$<TARGET_PROPERTY:Doxygen::dia,IMPORTED_LOCATION>>

      # TODO: Use dependencies from DOXYGEN_TARGET_DEPENDENCIES' INCLUDE_DIRECTORIES by default.
      # DOXYGEN_STRIP_FROM_INC_PATH
      DOXYGEN_STRIP_FROM_PATH "$<JOIN:$<QUOTE>${CMAKE_SOURCE_DIR}$<QUOTE>;$<QUOTE>${PROJECT_SOURCE_DIR}$<QUOTE>;$<QUOTE>${CMAKE_CURRENT_SOURCE_DIR}$<QUOTE>, >"
      DOXYGEN_EXCLUDE_PATTERNS "${exclude-pattern-defaults}"

      DOXYGEN_GENERATE_TAGFILE "${target}.tag"
      DOXYGEN_GENERATE_LATEX NO
      DOXYGEN_GENERATE_HTML YES
      DOXYGEN_GENERATE_MAN NO)
  target_sources(${target} PRIVATE $<TARGET_PROPERTY:${target},SOURCE_DIR>)
  set_property(GLOBAL APPEND PROPERTY ixm::doxygen::targets ${target})
endfunction()

function (target_doxygen_tagfile target tagfile)
  cmake_parse_arguments(ARG "" "URL" "" ${ARGN})
  if (ARG_URL)
    set(tagfile "${tagfile}=${ARG_URL}")
  endif()
  set_property(TARGET ${target} APPEND PROPERTY DOXYGEN_TAGFILES "${tagfile}")
endfunction()

function (target_doxygen_extra_css target)
  cmake_parse_arguments(ARG "" "PRIVATE;PUBLIC;INTERFACE" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::doxygen::assert)
  set_property(TARGET ${target} APPEND
    PROPERTY
      DOXYGEN_HTML_EXTRA_STYLESHEETS ${ARG_PRIVATE} ${ARG_PUBLIC})
endfunction()

#[[ Initializes internal doxygen template, properties, and cache variables ]]
function (🈯::ixm::doxygen::activate)
  if (NOT TARGET Doxygen::doxygen)
    return()
  endif()
  get_property(activated GLOBAL PROPERTY 🈯::ixm::doxygen::activated)
  if (activated AND EXISTS "${IXM_FILES_DIR}/doxyfile.tpl" AND EXISTS "${IXM_FILES_DIR}/Doxyfile.in")
    return()
  endif()
  set(doxyfile.tpl "${IXM_FILES_DIR}/doxyfile.tpl")
  set(doxyfile.in "${IXM_FILES_DIR}/Doxyfile.in")
  set_property(GLOBAL PROPERTY 🈯::ixm::doxygen::template "${doxyfile.in}")
  get_property(doxygen TARGET Doxygen::doxygen PROPERTY IMPORTED_LOCATION)
  if (NOT doxygen)
    message(AUTHOR_WARNING "Target 'Doxygen::doxygen' exists, but no IMPORTED_LOCATION property exists")
    return()
  endif()
  set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" APPEND
    PROPERTY
      CMAKE_CONFIGURE_DEPENDS "${doxygen}")
  if (NOT EXISTS "${doxyfile.tpl}")
    message(TRACE "Generating Doxygen template configuration file ${doxyfile.tpl}")
    execute_process(
      COMMAND "${doxygen}" -s -g "${doxyfile.tpl}"
      OUTPUT_QUIET
      ERROR_QUIET
      RESULT_VARIABLE doxyfile
    )
    if (NOT doxyfile EQUAL 0)
      message(FATAL_ERROR "Could not generate doxygen configuration template")
    endif()
  endif()
  message(TRACE "Generating Doxygen properties, cache variables, and ${doxyfile.in} template")
  file(READ "${doxyfile.tpl}" doxyfile.contents)
  string(REGEX REPLACE "\\\\\n( *)" " " doxyfile.contents "${doxyfile.contents}")
  string(REPLACE "\n" ";" doxyfile.contents "${doxyfile.contents}")
  set(doxyfile.template
    "#"
    "# DO NOT EDIT."
    "# THIS FILE WAS GENERATED BY CMAKE VIA IXM."
    "# ANY CHANGES MADE CAN AND WILL BE LOST ON REGENERATION."
    "#"
    ""
  )
  foreach (line IN LISTS doxyfile.contents)
    if (line MATCHES "^([A-Z_]+)( *=)[ ]?(.*)$")
      set(property "DOXYGEN_${CMAKE_MATCH_1}")
      set(genexp "${CMAKE_MATCH_1}${CMAKE_MATCH_2} $<GENEX_EVAL:$<TARGET_PROPERTY:${property}>>")
      # TODO: Get/Set the list of quotable properties somewhere...
      if (property IN_LIST quotables)
        # This is a very difficult generator expression to understand.
        # Effectively, we check if the *length* of the target property is 1.
        # If it is, we simply wrap the property in quotes
        # If it is greater than 1 (or 0), we prepend a quote to each item in
        # the list. We then append a quote to each item in the list. Finally,
        # we join them together with a single space separating them.
        # To ensure said space is *not* accidentally deleted, we've placed a
        # comment after it so that it is properly concatenated into the
        # resulting file.
        string(CONCAT genexp $<IF:
          $<EQUAL:$<LIST:LENGTH,$<GENEX_EVAL:$<TARGET_PROPERTY:${property}>>>,1>
          $<QUOTE>$<GENEX_EVAL:$<TARGET_PROPERTY:${property}>>$<QUOTE>,
          $<JOIN:
            $<LIST:APPEND,
              $<LIST:PREPEND,
                $<GENEX_EVAL:$<TARGET_PROPERTY:${property}>>,
                $<QUOTE>
              >,
              $<QUOTE>
            >, # The preceding space here MATTERS.
          >
        >)
      endif()
      define_property(TARGET
        INHERITED
        PROPERTY "${property}"
        INITIALIZE_FROM_VARIABLE "IXM_${property}")
      if (CMAKE_MATCH_3)
        set(IXM_${property} "${CMAKE_MATCH_3}"
          CACHE
          INTERNAL
          "Initial value for the 'DOXYGEN_${CMAKE_MATCH_1}' property")
        set(line "${genexp}")
      else()
        string(CONCAT line $<
          $<STREQUAL:$<GENEX_EVAL:$<TARGET_PROPERTY:${property}>>,>:
          "# "
        >${genexp})
      endif()
    endif()
    list(APPEND doxyfile.template "${line}")
  endforeach()
  list(JOIN doxyfile.template "\n" doxyfile.template)
  file(WRITE "${doxyfile.in}" "${doxyfile.template}")
  set_property(GLOBAL PROPERTY 🈯::ixm::doxygen::activated YES)
endfunction()

cmake_language(CALL 🈯::ixm::doxygen::activate)
