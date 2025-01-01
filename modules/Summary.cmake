include_guard(GLOBAL)
cmake_language(CALL 🈯::ixm::experiment module.summary "c9035a6c-d142-5f37-922a-1b54e1a75018")

include(FeatureSummary)

#[[
This is a more powerful version of feature_summary(WHAT ALL), in that it will
generate markdown as the output.

Additionally, this function has knowledge of the GITHUB_STEP_SUMMARY
environment variable and will output to it automatically if not `OUTPUT`
parameter is provided.

Finally, users can opt to pipe the output into CLI rendering tool if desired. Said tool can be an `IMPORTED` target, a 
]]
function (ixm::summarize)
  cmake_parse_arguments(ARG "" "PAGER;OUTPUT" "" ${ARGN})

  if (NOT ARG_OUTPUT AND DEFINED ENV{CI} AND "$ENV{GITHUB_ACTIONS}")
    cmake_path(CONVERT "$ENV{GITHUB_STEP_SUMMARY}" TO_CMAKE_PATH_LIST ARG_OUTPUT NORMALIZE)
  endif()

  get_property(pkg.required.types GLOBAL PROPERTY FeatureSummary_PKG_REQUIRED_TYPES)
  get_property(pkg.types GLOBAL PROPERTY FeatureSummary_PKG_TYPES)

  get_property(enabled.features GLOBAL PROPERTY ENABLED_FEATURES)
  get_property(disabled.features GLOBAL PROPERTY DISABLED_FEATURES)

  message(STATUS "----------------------------------")
  message(STATUS "ixm::summarize")
  message(STATUS "----------------------------------")

  foreach (feature IN LISTS enabled.features)
    get_property(description GLOBAL PROPERTY "_CMAKE_${feature}_DESCRIPTION")
    message(STATUS "enabled feature: ${feature} - ${description}")
  endforeach()

  foreach (feature IN LISTS disabled.features)
    message(STATUS "disabled feature: ${feature}")
  endforeach()

  get_property(packages GLOBAL PROPERTY "PACKAGES_FOUND")
  message(STATUS "Found Packages")
  foreach (package IN LISTS packages)
    get_property(transitive GLOBAL PROPERTY "_CMAKE_${package}_TRANSITIVE_DEPENDENCY")
    get_property(description GLOBAL PROPERTY "_CMAKE_${package}_DESCRIPTION")
    get_property(quiet GLOBAL PROPERTY "_CMAKE_${package}_QUIET")
    get_property(type GLOBAL PROPERTY "_CMAKE_${package}_TYPE")
    get_property(url GLOBAL PROPERTY "_CMAKE_${package}_URL")
    if (transitive OR quiet)
      continue()
    endif()
    message(STATUS "package: ${package} - ${type} | ${url} | ${description} (transitive: ${transitive}, quiet: ${quiet})")
  endforeach()

  message(STATUS "----------------------------------")

  get_property(packages GLOBAL PROPERTY "PACKAGES_NOT_FOUND")
  message(STATUS "Missing Packages")
  foreach (package IN LISTS packages)
    get_property(transitive GLOBAL PROPERTY "_CMAKE_${package}_TRANSITIVE_DEPENDENCY")
    get_property(quiet GLOBAL PROPERTY "_CMAKE_${package}_QUIET")
    get_property(type GLOBAL PROPERTY "_CMAKE_${package}_TYPE")
    message(STATUS "package: ${package} - ${type} (transitive: ${transitive}, quiet: ${quiet})")
  endforeach()
endfunction()
