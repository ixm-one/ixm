include_guard(GLOBAL)

include(ParentScope)

function (any_of output condition)
  set(${output} FALSE)
  foreach (var IN LISTS ARGN)
    if (${condition} ${var})
      set(${output} TRUE)
      break()
    endif()
  endforeach()
  parent_scope(${output})
endfunction ()

function (all_of output condition)
  set(${output} TRUE)
  foreach (var IN LISTS ARGN)
    if (NOT (${condition} ${var}))
      set(${output} FALSE)
      break()
    endif ()
  endforeach ()
  parent_scope(${output})
endfunction ()