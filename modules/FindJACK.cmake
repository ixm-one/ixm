cmake_language(CALL ixm::find::program
  VERSION
  NAMES jackd
  PACKAGE
    COMPONENT Daemon)

cmake_language(CALL ixm::find::library
  NAMES
    jack64)

cmake_language(CALL ixm::find::header
  NAMES
    jack/jack.h)

cmake_language(CALL ixm::find::library
  NAMES
    jacknet64
  PATHS
    ENV ProgramFiles
  PACKAGE
    COMPONENT Net)

cmake_language(CALL ixm::find::library
  NAMES
    jackserver64
  PACKAGE
    COMPONENT Server)

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "JACK Audio Connection Kit"
  URL "https://jackaudio.org/")
