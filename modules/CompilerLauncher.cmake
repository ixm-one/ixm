include_guard(GLOBAL)

function (target_compiler_launcher target)
  cmake_parse_arguments(ARG "" "LAUNCHER" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})
  # It's fine if it's declared as a target later, we just want to reduce some
  # computation here
  if (NOT TARGET ${ARG_LAUNCHER})
    find_program(${ARG_LAUNCHER}_EXECUTABLE
      NAMES "${ARG_LAUNCHER}"
      VALIDATOR ixm::validate::executable
      DOC "Path to the ${ARG_LAUNCHER} executable")
    mark_as_advanced(${ARG_LAUNCHER}_EXECUTABLE)
  endif()
  # Though complicated this has the nice effect of not being a hard error.
  # Sadly it also means a target or path not existing is silent...
  string(CONCAT location $<IF:
    $<BOOL:$<TARGET_NAME_IF_EXISTS:${ARG_LAUNCHER}>>,
    $<IF:
      $<BOOL:$<TARGET_PROPERTY:${ARG_LAUNCHER},IMPORTED>>,
      $<TARGET_PROPERTY:${ARG_LAUNCHER},IMPORTED_LOCATION>,
      $<TARGET_FILE:${ARG_LAUNCHER}>
    >,
    $<PATH:CMAKE_PATH,${${ARG_LAUNCHER}_EXECUTABLE}>
  >)

  set(no.pch.timestamp SHELL:-Xclang$<SEMICOLON>-fno-pch-timestamp)
  string(CONCAT is.cache $<OR:
    $<STREQUAL:$<PATH:GET_STEM,${location}>,sccache>,
    $<STREQUAL:$<PATH:GET_STEM,${location}>,ccache>
  >)
  string(CONCAT debug.format $<IF:
    ${is.cache},
    Embedded,
    $<IF:
      $<BOOL:${CMAKE_MSVC_DEBUG_INFORMATION_FORMAT}>,
      ${CMAKE_MSVC_DEBUG_INFORMATION_FORMAT},
      $<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>
    >
  >)
  set_target_properties(${target}
    PROPERTIES
      XCODE_ATTRIBUTE_COMPILER_INDEX_STORE_ENABLE NO
      XCODE_ATTRIBUTE_CLANG_USE_RESPONSE_FILE NO
      XCODE_ATTRIBUTE_CLANG_ENABLE_MODULES NO

      MSVC_DEBUG_INFORMATION_FORMAT "${debug.format}")

  foreach (language IN LISTS ARG_PRIVATE ARG_PUBLIC)
    string(CONCAT is.cache $<AND:
      $<COMPILE_LANG_AND_ID:${language},AppleClang,Clang>,
      ${is.cache}
    >)
    set_target_properties(${target}
      PROPERTIES
        XCODE_ATTRIBUTE_${language}_COMPILER_LAUNCHER "${location}"
        ${language}_COMPILER_LAUNCHER "${location}")
    target_compile_options(${target}
      PRIVATE
        $<${is.cache}:${no.pch.timestamp}>)
  endforeach()

  foreach (language IN LISTS ARG_PUBLIC ARG_INTERFACE)
    set_target_properties(${target}
      PROPERTIES
        INTERFACE_XCODE_ATTRIBUTE_${language}_COMPILER_LAUNCHER "${location}"
        INTERFACE_${language}_COMPILER_LAUNCHER "${location}")
    target_compile_options(${target}
      INTERFACE
        $<${is.cache}:${no.pch.timestamp}>)
  endforeach()
endfunction()
