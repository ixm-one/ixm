cmake_language(CALL 🈯::ixm::experiment find.freebsd "40399db4-d83b-5e2a-b4e2-5bcb8a343dac")

# See intro(3) for what these various libraries are for 🙂
cmake_language(CALL ixm::find::library COMPONENT Bluetooth NAMES bluetooth HEADER bluetooth.h)
cmake_language(CALL ixm::find::library COMPONENT Calendar NAMES calendar HEADER calendar.h)
cmake_language(CALL ixm::find::library COMPONENT CAM NAMES cam HEADER camlib.h)
cmake_language(CALL ixm::find::library COMPONENT Encryption NAMES crypt)
cmake_language(CALL ixm::find::library COMPONENT UserlandCharacterDevice NAMES cuse HEADER cuse.h)
cmake_language(CALL ixm::find::library COMPONENT DeviceInfo NAMES devinfo HEADER devinfo.h)
cmake_language(CALL ixm::find::library COMPONENT DeviceStatistics NAMES devstats HEADER devstats.h)
cmake_language(CALL ixm::find::library COMPONENT Dispatch NAMES dispatch HEADER dispatch/dispatch.h)
cmake_language(CALL ixm::find::library COMPONENT DWARF NAMES dwarf HEADER libdwarf.h)
cmake_language(CALL ixm::find::library COMPONENT ELF NAMES elf HEADER libelf.h)
cmake_language(CALL ixm::find::library COMPONENT Fetch NAMES fetch HEADER fetch.h)
cmake_language(CALL ixm::find::library COMPONENT ConfigurationParser NAMES figpar HEADER figpar.h)
cmake_language(CALL ixm::find::library COMPONENT GPIO NAMES gpio HEADER libgpio.h)
cmake_language(CALL ixm::find::library COMPONENT GSS NAMES gssapi HEADER gssapi.h)
cmake_language(CALL ixm::find::library COMPONENT Jail NAMES jail HEADER jail.h)
cmake_language(CALL ixm::find::library COMPONENT KVM NAMES kvm HEADER kvm.h)
cmake_language(CALL ixm::find::library COMPONENT Math NAMES m HEADER math.h)
cmake_language(CALL ixm::find::library COMPONENT MessageDigest NAMES md)
cmake_language(CALL ixm::find::library COMPONENT PAM NAMES pam HEADER security/pam_appl.h)
cmake_language(CALL ixm::find::library COMPONENT PacketCapture NAMES pcap HEADER pcap/pcap.h)
cmake_language(CALL ixm::find::library COMPONENT PerformanceCounters NAMES pmc HEADER pmc.h)
cmake_language(CALL ixm::find::library COMPONENT SystemDecode NAMES sysdecode HEADER sysdecode.h)
cmake_language(CALL ixm::find::library COMPONENT TerminalCapabilities NAMES termcap HEADER term.h)
cmake_language(CALL ixm::find::library COMPONENT USB NAMES usb HEADER libusb.h)
cmake_language(CALL ixm::find::library COMPONENT VideoGraphics NAMES vgl HEADER vgl.h)

# Some user friendly aliases
set(FreeBSD_TermCap_FOUND ${FreeBSD_TerminalCapabilities_FOUND})
set(FreeBSD_CUSE_FOUND ${FreeBSD_UserlandCharacterDevice_FOUND})
set(FreeBSD_PCap_FOUND ${FreeBSD_PacketCapture_FOUND})
set(FreeBSD_PMC_FOUND ${FreeBSD_PerformanceCounters_FOUND})
set(FreeBSD_VGL_FOUND ${FreeBSD_VideoGraphics_FOUND})

cmake_language(CALL ixm::package::check)

cmake_language(CALL ixm::package::properties
  DESCRIPTION "FreeBSD C libraries"
  URL "https://man.freebsd.org/cgi/man.cgi?intro(3)")
