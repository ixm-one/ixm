cmake_language(CALL ixm::find::program VERSION OPTION --print-version)
cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "A fast C/C++ compiler cache"
  URL "https://ccache.dev")
