include_guard(GLOBAL)

# CMake 3.31
set(CMAKE_POLICY_DEFAULT_CMP0181 NEW CACHE STRING "De-duplication of static libraries on link lines keeps first occurrence.")
set(CMAKE_POLICY_DEFAULT_CMP0180 NEW CACHE STRING "project() always sets <PROJECT_NAME>_* as normal variables")
set(CMAKE_POLICY_DEFAULT_CMP0177 NEW CACHE STRING "install() DESTINATION paths are normalized.")
set(CMAKE_POLICY_DEFAULT_CMP0176 NEW CACHE STRING "execute_process() ENCODING is UTF-8 by default.")
set(CMAKE_POLICY_DEFAULT_CMP0175 NEW CACHE STRING "add_custom_command() rejects invalid arguments.")
set(CMAKE_POLICY_DEFAULT_CMP0174 NEW CACHE STRING
  "cmake_parse_arguments(PARSE_ARGV) defines a variable for an empty string after a single-value keyword")
set(CMAKE_POLICY_DEFAULT_CMP0172 NEW CACHE STRING
  "The CPack module enables per-machine installation by default in the CPack WiX Generator")
set(CMAKE_POLICY_DEFAULT_CMP0171 NEW CACHE STRING "codegen is a reserved target name")

# CMake 3.29
set(CMAKE_POLICY_DEFAULT_CMP0160 NEW CACHE STRING "More read-only target properties now error when trying to set them.")

set(CMAKE_POLICY_DEFAULT_CMP0144 NEW CACHE STRING "find_package uses upper-case PACKAGENAME_ROOT variables.")

set(CMAKE_POLICY_DEFAULT_CMP0130 NEW CACHE STRING "while() diagnoses condition evaluation errors")

set(CMAKE_POLICY_DEFAULT_CMP0125 NEW CACHE STRING "find_<...>() have consistent cache var behavior")
set(CMAKE_POLICY_DEFAULT_CMP0124 NEW CACHE STRING "foreach() loop variables are scoped")
set(CMAKE_POLICY_DEFAULT_CMP0121 NEW CACHE STRING "list() detects invalid indices")

set(CMAKE_POLICY_DEFAULT_CMP0116 NEW CACHE STRING "Ninja transform DEPFILES in add_custom_command()")

set(CMAKE_POLICY_DEFAULT_CMP0092 NEW CACHE STRING "MSVC warning flags removed by default")
set(CMAKE_POLICY_DEFAULT_CMP0091 NEW CACHE STRING "MSVC uses CMAKE_MSVC_RUNTIME_LIBRARY")
set(CMAKE_POLICY_DEFAULT_CMP0090 NEW CACHE STRING "export(PACKAGE) does not populate package registry")

set(CMAKE_POLICY_DEFAULT_CMP0077 NEW CACHE STRING "option() honors normal variables")
