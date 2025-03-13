cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MESSAGE_CONTEXT ixm)

include(CMakeDependentOption)
include(CMakePrintHelpers)

block (SCOPE_FOR VARIABLES) # Setting internal variables
  message(TRACE "Setting internal variables")
  set(IXM_FILES_DIR "${CMAKE_BINARY_DIR}/.ixm" CACHE INTERNAL "")
  set(IXM_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "IXM Root Directory")
endblock()

block (SCOPE_FOR VARIABLES) # Setting global variables
  message(TRACE "Setting global variables")
  set(CMAKE_DISABLE_IN_SOURCE_BUILD YES CACHE BOOL "")
  set(CMAKE_DISABLE_SOURCE_CHANGES YES CACHE BOOL "")
endblock()

block (SCOPE_FOR VARIABLES)
  message(TRACE "Setting default properties")
  set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMake")
  set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED YES) # Removes CDash Targets
endblock()

block (SCOPE_FOR VARIABLES) # Setting default CMake policies
  message(TRACE "Setting default CMake policies")
  if (NOT 🈯::ixm::${CMAKE_VERSION}::policies)
    include("${CMAKE_CURRENT_LIST_DIR}/runtime/policies.cmake")
    set(🈯::ixm::${CMAKE_VERSION}::policies YES CACHE INTERNAL "")
    mark_as_advanced(🈯::ixm::${CMAKE_VERSION}::policies)
  endif()
endblock()

block (SCOPE_FOR VARIABLES) # Defining global properties
  message(TRACE "Defining global properties")

  define_property(GLOBAL PROPERTY 🈯::ixm::supports::hyperlinks
    BRIEF_DOCS "Whether the current interface executing CMake supports rendering ANSI escape hyperlinks.")

  define_property(GLOBAL PROPERTY 🈯::ixm::supports::unicode
    BRIEF_DOCS "Whether the current interface executing CMake supports rendering Unicode characters.")
endblock()

block (SCOPE_FOR VARIABLES) # Include internal source files
  message(TRACE "Including IXM's internal source files")
  include("${CMAKE_CURRENT_LIST_DIR}/runtime/supports.cmake")
endblock()

block (SCOPE_FOR VARIABLES) # Setting internal properties
  message(TRACE "Setting internal properties")
  if (NOT DEFINED IXM_SUPPORTS_HYPERLINKS)
    cmake_language(CALL 🈯::ixm::supports::hyperlinks)
  endif()
  if (NOT DEFINED IXM_SUPPORTS_UNICODE)
    cmake_language(CALL 🈯::ixm::supports::unicode)
  endif()
  set_property(GLOBAL PROPERTY 🈯::ixm::supports::hyperlinks ${IXM_SUPPORTS_HYPERLINKS})
  set_property(GLOBAL PROPERTY 🈯::ixm::supports::unicode ${IXM_SUPPORTS_UNICODE})
endblock()

message(TRACE "Including IXM internal source files")
include("${CMAKE_CURRENT_LIST_DIR}/runtime/validate.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/runtime/features.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/runtime/package.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/runtime/common.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/runtime/check.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/runtime/find.cmake")

file(MAKE_DIRECTORY "${IXM_FILES_DIR}")

block (SCOPE_FOR VARIABLES) # Setting DEFER calls
  message(TRACE "Setting DEFER calls")
  cmake_language(DEFER
    DIRECTORY "${CMAKE_SOURCE_DIR}"
    CALL cmake_file_api
    QUERY
      API_VERSION 1
      CMAKEFILES 1
      TOOLCHAINS 1
      CODEMODEL 2
      CACHE 2)
endblock()

message(TRACE "Mutating CMAKE_MODULE_PATH")
list(PREPEND CMAKE_MODULE_PATH "${IXM_ROOT_DIR}/modules")
return(PROPAGATE CMAKE_MODULE_PATH)
