include_guard(GLOBAL)

include(FindPackageHandleStandardArgs)
include(FeatureSummary)

#[============================================================================[
# @summary Copies arguments to `OUTPUT_VARIABLE` for safely passing to
# `find_package` calls.
#
# @description Similar logic for this function is found in the
# `find_dependency` CMake command. However, this function *does not* perform
# the actual `find_package` call. As a result, this function is more useful
# when wrapping `find_package` calls, as well as for writing a custom
# `find_dependency` command.
#
# @param {identifier} OUTPUT_VARIABLE
# @param {option} [MODULE]
#]============================================================================]
function (ixm::package::arguments)
  cmake_parse_arguments(ARG "MODULE" "OUTPUT_VARIABLE" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::requires OUTPUT_VARIABLE)

  set(required-components)
  set(optional-components)
  set(arguments)

  set(package ${CMAKE_FIND_PACKAGE_NAME})

  if (${package}_FIND_VERSION_COMPLETE)
    list(APPEND arguments "${${package}_FIND_VERSION_COMPLETE}")
  endif()
  if (${package}_FIND_EXACT)
    list(APPEND arguments EXACT)
  endif()
  if (${package}_FIND_QUIETLY)
    list(APPEND arguments QUIET)
  endif()
  if (ARG_MODULE)
    list(APPEND arguments MODULE)
  endif()
  if (${package}_FIND_REQUIRED)
    list(APPEND arguments REQUIRED)
  endif()

  foreach (component IN LISTS ${package}_FIND_COMPONENTS)
    if (${package}_FIND_REQUIRED_${component})
      list(APPEND required-components ${component})
    else()
      list(APPEND optional-components ${component})
    endif()
  endforeach()

  if (optional-components)
    list(APPEND arguments OPTIONAL_COMPONENTS ${optional-components})
  endif()

  if (required-components)
    list(APPEND arguments COMPONENTS ${required-components})
  endif()

  if (${package}_FIND_REGISTRY_VIEW)
    list(APPEND arguments REGISTRY_VIEW ${${package}_FIND_REGISTRY_VIEW})
  endif()

  set(${${ARG_OUTPUT_VARIABLE}} ${arguments})
  return(PROPAGATE ${${ARG_OUTPUT_VARIABLE}})

endfunction()

#[[
set_property(GLOBAL APPEND PROPERTY <package>::components <component>...)
set_property(GLOBAL APPEND PROPERTY <package>::<component>::variables <variable>...)
set_property(GLOBAL APPEND PROPERTY <package>::<component>::targets <target>...)

]]

#[[
  package::components <component>...
    package::<component>::variables
    package::<component>::targets
      package::<component>::<target>::version
      package::<component>::<target>::program
      package::<component>::<target>::library
      package::<component>::<target>::include
      package::<component>::<target>::options::compile
      package::<component>::<target>::options::link
  for each component in components:
    check (required-vars ${variables})
    import(${target})
      add_library(${target} IMPORTED)
      target_include_directories(${target} INTERFACE ${${include}})
      set_property(${target} IMPORTED_LOCATION ${library})
  package::variables
  package::targets
  package::<target>::version
  package::<target>::program
  package::<target>::library
  package::<target>::include
  package::<target>::options::compile
  package::<target>::options::link
]]

#[[
Wrapper around find_package_handle_standard_args to make it easier to work
with.
]]
function (ixm::package::check)
  cmake_language(CALL 🈯::ixm::package::assert)
  cmake_language(CALL 🈯::ixm::package::prefix)
  unset(found)

  # We clean up the components *here* as it's quicker to do rather than "every
  # time we might append"
  get_property(components GLOBAL PROPERTY ${prefix}::components)
  list(REMOVE_DUPLICATES components)
  set_property(GLOBAL PROPERTY ${prefix}::components ${components})

  foreach (component IN LISTS components)
    cmake_language(CALL 🈯::ixm::package::component)
    list(APPEND found ${CMAKE_FIND_PACKAGE_NAME}_${component}_FOUND)
  endforeach()

  get_property(variables GLOBAL PROPERTY ${prefix}::variables)
  get_property(version GLOBAL PROPERTY ${prefix}::version)

  if (version)
    set(version VERSION_VAR ${version})
  endif()

  find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME}
    REQUIRED_VARS
      ${variables}
    ${version}
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS
    NAME_MISMATCHED)

  cmake_language(CALL ixm::package::import)

  return(PROPAGATE ${CMAKE_FIND_PACKAGE_NAME}_FOUND ${found})
endfunction()

#[[
Generates IMPORTED targets for all targets that were bookkept inside of the
find_package(MODULE) file
]]
function (ixm::package::import)
  cmake_language(CALL 🈯::ixm::package::assert)
  set(prefix ${CMAKE_FIND_PACKAGE_NAME})

  get_property(components GLOBAL PROPERTY ${prefix}::components)

  foreach (component IN LISTS components)
    get_property(targets GLOBAL PROPERTY ${prefix}::${component}::targets)
    foreach (target IN LISTS targets)
      cmake_language(CALL ixm::package::target
        COMPONENT ${component}
        TARGET ${target})
    endforeach()
  endforeach()
  get_property(targets GLOBAL PROPERTY ${prefix}::targets)
  foreach (target IN LISTS targets)
    cmake_language(CALL ixm::package::target TARGET ${target})
  endforeach()
endfunction()

function (ixm::package::target)
  cmake_parse_arguments(ARG "" "COMPONENT;TARGET" "" ${ARGN})
  cmake_language(CALL 🈯::ixm::requires TARGET)
  cmake_language(CALL 🈯::ixm::package::assert)
  cmake_language(CALL 🈯::ixm::package::prefix)
  # Each variable contains a variable name, thus we need to "expand" it out.
  get_property(version GLOBAL PROPERTY ${prefix}::{${ARG_TARGET}}::version)
  get_property(program GLOBAL PROPERTY ${prefix}::{${ARG_TARGET}}::program)
  get_property(library GLOBAL PROPERTY ${prefix}::{${ARG_TARGET}}::library)
  get_property(include GLOBAL PROPERTY ${prefix}::{${ARG_TARGET}}::include)
  get_property(compile GLOBAL PROPERTY ${prefix}::{${ARG_TARGET}}::options::compile)
  get_property(link GLOBAL PROPERTY ${prefix}::{${ARG_TARGET}}::options::link)
  if (program AND library)
    string(CONFIGURE [[
      PACKAGE: @CMAKE_FIND_PACKAGE_NAME@
      COMPONENT: @component@
      TARGET: @target@
      PROBLEM: An executable and library variable have been set for a target.
    ]] error-message @ONLY)
    message(FATAL_ERROR "${error-message}")
  endif()

  # Targets can only have ONE location, so appending to a list and then
  # removing empty items is ideal
  set(location "${program}" "${library}")
  list(REMOVE_ITEM location "")
  set(command add_library)
  set(arguments UNKNOWN)

  if (program)
    set(command add_executable)
    set(arguments)
  endif()

  # If there's no location, then it's an INTERFACE library
  if (NOT location)
    set(arguments INTERFACE)
  endif()

  cmake_language(CALL ${command} ${ARG_TARGET} ${arguments} IMPORTED)
  # IMPORTED targets can have any properties set, so it doesn't really matter
  # if we add include directories to executables.
  target_include_directories(${target} INTERFACE ${include})
  target_compile_options(${target} INTERFACE ${compile})
  target_link_options(${target} INTERFACE ${link})

  # INTERFACE libraries don't like having non INTERFACE properties set, after
  # all.
  if (location)
    set_target_properties(${target}
      PROPERTIES
        IMPORTED_LOCATION "${location}"
        VERSION "${version}"
    )
  endif()
endfunction()

#[[ Wrapper around set_package_properties to make it easier to work with ]]
function (ixm::package::properties)
  cmake_language(CALL 🈯::ixm::package::assert)
  set_package_properties(${CMAKE_FIND_PACKAGE_NAME}
    PROPERTIES
      ${ARGN})
endfunction()

macro(🈯::ixm::package::component)
  get_property(variables GLOBAL PROPERTY ${prefix}::${component}::variables)
  set(package ${CMAKE_FIND_PACKAGE_NAME}_${component})
  # TODO: Replace find_package_handle_standard_args in the future so this is
  # easier to work with, instead of technically being a hack.
  set(${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY YES)
  find_package_handle_standard_args(${package} REQUIRED_VARS ${variables})
  set(${package}_FOUND ${${package_FOUND}} PARENT_SCOPE)
endmacro()

macro(🈯::ixm::package::assert)
  if (NOT DEFINED CMAKE_FIND_PACKAGE_NAME)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} may only be called within the context of a find_package file.")
  endif()
endmacro()

# Sets the property prefix
macro(🈯::ixm::package::prefix)
  set(prefix ${CMAKE_FIND_PACKAGE_NAME})
  if (ARG_COMPONENT)
    set(prefix ${prefix}::${ARG_COMPONENT})
  endif()
endmacro()
