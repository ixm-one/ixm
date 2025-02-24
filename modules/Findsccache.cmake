cmake_language(CALL ixm::package::program VERSION)
cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "ccache with cloud storage"
  URL "https://github.com/mozilla/sccache")
