cmake_language(CALL 🈯::ixm::experiment find.linux "23beb332-b5c8-575b-9dc3-b27402b3d099")

# This does NOT follow the LSB as the LSB is now considered "dead"
# https://web.archive.org/web/20240122163643/https://lists.linuxfoundation.org/pipermail/lsb-discuss/2023-February/008278.html
cmake_language(CALL ixm::find::library COMPONENT DynamicLoader NAMES dl)
cmake_language(CALL ixm::find::library COMPONENT Cryptography NAMES crypt)
cmake_language(CALL ixm::find::library COMPONENT Unwind NAMES gcc_s)
cmake_language(CALL ixm::find::library COMPONENT Realtime NAMES rt)
cmake_language(CALL ixm::find::library COMPONENT PAM NAMES pam)
cmake_language(CALL ixm::find::library COMPONENT Math NAMES m)

cmake_language(CALL ixm::package::check)

cmake_language(CALL ixm::package::properties
  DESCRIPTION "The Linux Standard Base Libraries")
