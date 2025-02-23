include(CompilerLauncher)

cmake_language(CALL ixm::find::program
  NAMES ccache
  DESCRIPTION "Path to ccache executable"
  VERSION
    OPTION --print-version)

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::import)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "A fast C/C++ compiler cache"
  URL "https://ccache.dev")
