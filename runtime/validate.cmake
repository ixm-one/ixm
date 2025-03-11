include_guard(GLOBAL)

function (ixm::validate::executable result item)
  if (NOT IS_EXECUTABLE "${item}")
    set(${result} NO PARENT_SCOPE)
  endif()
endfunction()
