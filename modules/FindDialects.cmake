foreach (component IN ITEMS "Exceptions" "RTTI" "Math")
  if (component IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (CMAKE_CXX_COMPILER_ID MATCHES "(GNU|Clang|MSVC)")
      set(${CMAKE_FIND_PACKAGE_NAME}_${component}_FOUND YES)
    endif()
  endif()
endforeach()

if ("Library" IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  if (CMAKE_CXX_COMPILER_ID MATCHES "(GNU|Clang)")
    set(${CMAKE_FIND_PACKAGE_NAME}_Library_FOUND YES)
  endif()
endif()

find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME}
  REQUIRED_VARS
    CMAKE_CXX_COMPILER_ID
  HANDLE_COMPONENTS)

if (${CMAKE_FIND_PACKAGE_NAME}_Exceptions_FOUND AND NOT TARGET ${CMAKE_FIND_PACKAGE_NAME}::Exceptions::On)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::Exceptions::Off INTERFACE IMPORTED)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::Exceptions::On INTERFACE IMPORTED)

  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::Exceptions::Off
    INTERFACE
      $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-fno-exceptions>
      $<$<CXX_COMPILER_ID:MSVC>:/Ehs->)
  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::Exceptions::On
    INTERFACE
      $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-fexceptions>
      $<$<CXX_COMPILER_ID:MSVC>:/Ehsc>)
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_RTTI_FOUND AND NOT TARGET ${CMAKE_FIND_PACKAGE_NAME}::RTTI::On)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::RTTI::Off INTERFACE IMPORTED)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::RTTI::On INTERFACE IMPORTED)

  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::RTTI::Off
    INTERFACE
      $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-fno-rtti>
      $<$<CXX_COMPILER_ID:MSVC>:/GR->)
  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::RTTI::On
    INTERFACE
      $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-frtti>
      $<$<CXX_COMPILER_ID:MSVC>:/GR>)
endif()

if (${CMAKE_FIND_PACKAGE_NAME}_Math_FOUND AND NOT TARGET ${CMAKE_FIND_PACKAGE_NAME}::Math::Fast)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::Math::Precise INTERFACE IMPORTED)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::Math::Strict INTERFACE IMPORTED)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::Math::Fast INTERFACE IMPORTED)

  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::Math::Precise
    INTERFACE
      $<$<CXX_COMPILER_ID:Clang,AppleClang>-fp-model=precise>
      $<$<CXX_COMPILER_ID:MSVC>:/fp:precise>)

  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::Math::Strict
    INTERFACE
      $<$<CXX_COMPILER_ID:Clang,AppleClang>:-fp-model=strict>
      $<$<CXX_COMPILER_ID:MSVC>:/fp:strict>)

  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::Math::Fast
    INTERFACE
      $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-ffast-math>
      $<$<CXX_COMPILER_ID:MSVC>:/fp:fast>)
  target_compile_definitions(${CMAKE_FIND_PACKAGE_NAME}::Math::Fast
    INTERFACE
      $<$<CXX_COMPILER_ID:GNU,MSVC>:__FAST_MATH__>)
endif()

# TODO: Implement this properly with some checking/behavior
#if (${CMAKE_FIND_PACKAGE_NAME}_Barebones_FOUND AND NOT TARGET ${CMAKE_FIND_PACKAGE_NAME}::Barebones::On)
#  add_library(${CMAKE_FIND_PACKAGE_NAME}::Barebones::On INTERFACE IMPORTED)
#
#  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::Barebones::On
#    INTERFACE
#      $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-nostdinc>
#      $<$<CXX_COMPILER_ID:MSVC>:/X>)
#
#  target_link_options(${CMAKE_FIND_PACKAGE_NAME}::Barebones::On
#    INTERFACE
#      $<$<LINK_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:-nostdlib>
#      $<$<LINK_LANG_AND_ID:CXX,MSVC>:/NODEFAULTLIB>)
#endif()

if (${CMAKE_FIND_PACKAGE_NAME}_Library_FOUND AND NOT TARGET ${CMAKE_FIND_PACKAGE_NAME}::Library::Off)
  add_library(${CMAKE_FIND_PACKAGE_NAME}::Library::Off INTERFACE IMPORTED)

  target_compile_options(${CMAKE_FIND_PACKAGE_NAME}::Library::Off
    INTERFACE
      $<$<CXX_COMPILER_ID:Gnu,Clang,AppleClang>:-nostdinc++>
      $<$<CXX_COMPILER_ID:MSVC>:/X>)

  target_link_options(${CMAKE_FIND_PACKAGE_NAME}::Library::Off
    INTERFACE
      $<$<LINK_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:-nostdlib++>
      $<$<LINK_LANG_AND_ID:CXX,MSVC>:/NODEFAULTLIB>)
endif()
