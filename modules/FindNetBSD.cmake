cmake_language(CALL 🈯::ixm::experiment find.netbsd "96831b14-57c0-5b90-bb6f-c53082aa235c")

cmake_language(CALL ixm::find::library COMPONENT ASN1 NAMES asn1)
cmake_language(CALL ixm::find::library COMPONENT BZip2 NAMES bz2)
cmake_language(CALL ixm::find::library COMPONENT CommonError NAMES com_err)
cmake_language(CALL ixm::find::library COMPONENT Encryption NAMES crypt)
cmake_language(CALL ixm::find::library COMPONENT Crypto NAMES crypto)
cmake_language(CALL ixm::find::library COMPONENT Curses NAMES curses)
cmake_language(CALL ixm::find::library COMPONENT DeviceMapper NAMES dm)
cmake_language(CALL ixm::find::library COMPONENT Edit NAMES edit FILE histedit.h)
cmake_language(CALL ixm::find::library COMPONENT Form NAMES form FILE form.h)
cmake_language(CALL ixm::find::library COMPONENT Hesiod NAMES hesiod FILE hesiod.h)
cmake_language(CALL ixm::find::library COMPONENT Intl NAMES intl FILE libintl.h)
cmake_language(CALL ixm::find::library COMPONENT IPSec NAMES ipsec FILE netipsec/ipsec.h)
# TODO: place kerberos checks here.
cmake_language(CALL ixm::find::library COMPONENT KVM NAMES kvm)
cmake_language(CALL ixm::find::library COMPONENT Math NAMES m FILE math.h)
cmake_language(CALL ixm::find::library COMPONENT Menu NAMES menu FILE menu.h)
cmake_language(CALL ixm::find::library COMPONENT Virtualization NAMES nvmm FILES nvmm.h)
cmake_language(CALL ixm::find::library COMPONENT Audio NAMES ossaudio FILE soundcard.h)
cmake_language(CALL ixm::find::library COMPONENT Panel NAMES panel FILE panel.h)
cmake_language(CALL ixm::find::library COMPONENT PacketCapture NAMES pcap FILE pcap/pcap.h)
cmake_language(CALL ixm::find::library COMPONENT PCI NAMES pci FILE pci.h)
cmake_language(CALL ixm::find::library COMPONENT RemoteTape NAMES rmt FILE rmt.h)
cmake_language(CALL ixm::find::library COMPONENT RPC NAMES rpcsvc FILE rpc/rpc.h)
cmake_language(CALL ixm::find::library COMPONENT SKey NAMES skey FILE skey.h)
cmake_language(CALL ixm::find::library COMPONENT SSL NAMES ssl FILE openssl/ssl.h)
cmake_language(CALL ixm::find::library COMPONENT TelNet NAMES telnet)
cmake_language(CALL ixm::find::library COMPONENT TermInfo NAMES terminfo FILE term.h)
cmake_language(CALL ixm::find::library COMPONENT USB NAMES usbhid FILE usbhid.h)
cmake_language(CALL ixm::find::library COMPONENT Wrap NAMES wrap FILE tcpd.h)
cmake_language(CALL ixm::find::library COMPONENT Utilities NAMES util FILE util.h)

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::import)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "NetBSD C Libraries"
  URL "https://man.netbsd.org/intro.3")
