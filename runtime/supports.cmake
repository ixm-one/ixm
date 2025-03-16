include_guard(GLOBAL)

#[[
Checks if the interface executing CMake can render unicode characters, such as
emoji.
]]
function (🈯::ixm::supports::unicode)
  set(IXM_SUPPORTS_UNICODE NO)
  if (IXM_FORCE_UNICODE)
    set(IXM_SUPPORTS_UNICODE YES)
    return(PROPAGATE IXM_SUPPORTS_UNICODE)
  endif()

  # We're running under cmake-gui so we can just leave early
  if (CMAKE_EDIT_COMMAND MATCHES "cmake-gui")
    set(IXM_SUPPORTS_UNICODE YES)
    return(PROPAGATE IXM_SUPPORTS_UNICODE)
  endif()

  if ("$ENV{TERM}" STREQUAL "linux")
    set(IXM_SUPPORTS_UNICODE NO)
  elseif (CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(TERM alacritty xterm256-color)
    if (NOT "$ENV{CI}" STREQUAL "")
      set(IXM_SUPPORTS_UNICODE YES)
    elseif(NOT "$ENV{WT_SESSION}")
      set(IXM_SUPPORTS_UNICODE YES)
    elseif ("$ENV{ConEmuTask}" STREQUAL "{cmd:Cmder}")
      set(IXM_SUPPORTS_UNICODE YES)
    elseif ("$ENV{TERM_PROGRAM}" STREQUAL "vscode")
      set(IXM_SUPPORTS_UNICODE YES)
    elseif ("${ENV{TERM}" IN_LIST TERM)
      set(IXM_SUPPORTS_UNICODE YES)
    endif()
  else()
    foreach (env IN ITEMS "LC_ALL" "LC_TYPE" "LANG")
      if ("$ENV{${env}}" MATCHES "UTF-?8$")
        set(IXM_SUPPORTS_UNICODE YES)
      endif()
    endforeach()
  endif()
  return(PROPAGATE IXM_SUPPORTS_UNICODE)
endfunction()

#[[
Checks if the interface executing CMake can render hyperlinks using the ANSI
escape sequence extensions that have been popularized by iTerm and others.
]]
function (🈯::ixm::supports::hyperlinks)
  set(TERM xterm-kitty alacritty alacritty-direct)
  set(TERM_PROGRAM Hyper iTerm.app terminology WezTerm vscode)
  set(IXM_SUPPORTS_HYPERLINKS NO)
  if (DEFINED ENV{FORCE_HYPERLINK} AND NOT "$ENV{FORCE_HYPERLINK}" MATCHES "0" OR IXM_FORCE_HYPERLINKS)
    set(IXM_SUPPORTS_HYPERLINKS YES)
  endif()

  # We're running under cmake-gui so we can just leave early
  if (CMAKE_EDIT_COMMAND MATCHES "cmake-gui")
    set(IXM_SUPPORTS_HYPERLINKS NO)
    return(PROPAGATE IXM_SUPPORTS_HYPERLINKS)
  endif()

  if ("$ENV{VTE_VERSION}" GREATER_EQUAL "5000")
    set(IXM_SUPPORTS_HYPERLINKS YES)
  elseif ("$ENV{TERM_PROGRAM}" IN_LIST TERM_PROGRAM)
    set(IXM_SUPPORTS_HYPERLINKS YES)
  elseif ("$ENV{TERM}" IN_LIST TERM)
    set(IXM_SUPPORTS_HYPERLINKS YES)
  elseif ("$ENV{COLORTERM}" STREQUAL "xfce4-terminal")
    set(IXM_SUPPORTS_HYPERLINKS YES)
  else()
    foreach (var IN ITEMS DOMTERM WT_SESSION KONSOLE_SESSION)
      if (NOT "$ENV{${var}}" STREQUAL "")
        set(IXM_SUPPORTS_HYPERLINKS YES)
        break()
      endif()
    endforeach()
  endif()
  return(PROPAGATE IXM_SUPPORTS_HYPERLINKS)
endfunction()
