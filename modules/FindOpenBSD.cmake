cmake_language(CALL 🈯::ixm::experiment find.openbsd "728c1986-c09d-5689-af08-08981918ce16")

cmake_language(CALL ixm::find::library COMPONENT AgentX.Profile TARGET AgentX::Profile NAMES agentx_p HEADERS agentx.h)
cmake_language(CALL ixm::find::library COMPONENT CBOR.Profile TARGET CBOR::Profile NAMES cbor_p)
cmake_language(CALL ixm::find::library COMPONENT Crypto.Profile TARGET Crypto::Profile NAMES crypto_p)
cmake_language(CALL ixm::find::library COMPONENT Curses.Profile TARGET Curses::Profile NAMES curses_p)
cmake_language(CALL ixm::find::library COMPONENT Edit.Profile TARGET Edit::Profile NAMES edit_p HEADER histedit.h)
cmake_language(CALL ixm::find::library COMPONENT ELF.Profile TARGET ELF::Profile NAMES elf_p HEADER libelf.h)
cmake_language(CALL ixm::find::library COMPONENT Event.Profile TARGET Event::Profile NAMES event_p HEADER event.h)
cmake_language(CALL ixm::find::library COMPONENT Backtrace.Profile TARGET Backtrace::Profile NAMES execinfo_p HEADER execinfo.h)
cmake_language(CALL ixm::find::library COMPONENT Expat.Profile TARGET Expat::Profile NAMES expat_p)
cmake_language(CALL ixm::find::library COMPONENT FIDO2.Profile TARGET FIDO2::Profile NAMES fido2_p)

cmake_language(CALL ixm::find::library COMPONENT AgentX NAMES agentx HEADERS agentx.h)
cmake_language(CALL ixm::find::library COMPONENT CBOR NAMES cbor)
cmake_language(CALL ixm::find::library COMPONENT Crypto NAMES crypto)
cmake_language(CALL ixm::find::library COMPONENT Curses NAMES curses)
cmake_language(CALL ixm::find::library COMPONENT Edit NAMES edit HEADER histedit.h)
cmake_language(CALL ixm::find::library COMPONENT ELF NAMES elf HEADER libelf.h)
cmake_language(CALL ixm::find::library COMPONENT Event NAMES event HEADER event.h)
cmake_language(CALL ixm::find::library COMPONENT Backtrace NAMES execinfo HEADER execinfo.h)
cmake_language(CALL ixm::find::library COMPONENT Expat NAMES expat)
cmake_language(CALL ixm::find::library COMPONENT FIDO2 NAMES fido2)
cmake_language(CALL ixm::find::library COMPONENT Form NAMES form HEADER form.h)
cmake_language(CALL ixm::find::library COMPONENT Fuse NAMES fuse HEADER fuse.h)
cmake_language(CALL ixm::find::library COMPONENT Keynote NAMES keynote HEADER keynote.h)
cmake_language(CALL ixm::find::library COMPONENT KVM NAMES kvm HEADER kvm.h)
cmake_language(CALL ixm::find::library COMPONENT Math NAMES m HEADER math.h)
cmake_language(CALL ixm::find::library COMPONENT Menu NAMES menu HEADER menu.h)
cmake_language(CALL ixm::find::library COMPONENT Panel NAMES panel HEADER panel.h)
cmake_language(CALL ixm::find::library COMPONENT PacketCapture NAMES pcap HEADER pcap.h)
cmake_language(CALL ixm::find::library COMPONENT Radius NAMES radius HEADER radius.h)
cmake_language(CALL ixm::find::library COMPONENT Readline NAMES readline HEADER readline/readline.h)
cmake_language(CALL ixm::find::library COMPONENT RPC NAMES rpcsvc HEADER rpc/rpc.h)
cmake_language(CALL ixm::find::library COMPONENT S/Key NAMES skey HEADER skey.h)
cmake_language(CALL ixm::find::library COMPONENT SoundIO NAMES sndio HEADER sndio.h)
cmake_language(CALL ixm::find::library COMPONENT TLS NAMES tls HEADER tls.h)
cmake_language(CALL ixm::find::library COMPONENT HID NAMES usbhid HEADER usbhid.h)

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::import)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "OpenBSD C Libraries"
  URL "https://man.openbsd.org/intro.3")

foreach (library IN ITEMS Edit Form Menu Panel)
  if (TARGET ${CMAKE_FIND_PACKAGE_NAME}::${library})
    target_link_libraries(${CMAKE_FIND_PACKAGE_NAME}::${library}
      INTERFACE
        $<TARGET_NAME_IF_EXISTS:${CMAKE_FIND_PACKAGE_NAME}::Curses>)
  endif()
endforeach()

if (TARGET ${CMAKE_FIND_PACKAGE_NAME}::Keynote)
  target_link_libraries(${CMAKE_FIND_PACKAGE_NAME}::Keynote
    INTERFACE
      $<TARGET_NAME_IF_EXISTS:${CMAKE_FIND_PACKAGE_NAME}::Crypto>
      $<TARGET_NAME_IF_EXISTS:${CMAKE_FIND_PACKAGE_NAME}::Math>)
endif()


