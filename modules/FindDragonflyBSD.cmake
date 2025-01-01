cmake_language(CALL 🈯::ixm::experiment find.dragonflybsd "4397a3e8-e0f3-5929-9b89-32c43e9cb2e4")

cmake_language(CALL ixm::find::library COMPONENT Curses NAME curses FILE curses.h)
cmake_language(CALL ixm::find::library COMPONENT TerminalCapabilities NAME termcap)
cmake_language(CALL ixm::find::library COMPONENT KVM NAME kvm)
cmake_language(CALL ixm::find::library COMPONENT Math NAME math)

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::pacakge::import)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "DragonflyBSD C libraries"
  URL "https://man.dragonflybsd.org/?command=intro&section=3")

if (TARGET ${CMAKE_FIND_PACKAGE_NAME}::Curses)
  target_link_libraries(${CMAKE_FIND_PACKAGE_NAME}::Curses
    INTERFACE
      $<TARGET_NAME_IF_EXISTS:${CMAKE_FIND_PACKAGE_NAME}::TerminalCapabilities>)
endif()
