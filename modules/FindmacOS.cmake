# TODO: wrap find_package and include the find_package(Darwin) quietly from
# here, then handle the resulting `_FOUND` variables.
cmake_language(CALL 🈯::ixm::experiment find.macOS "53843e8f-153e-5a5a-8e4c-af0f7c33c53d")

cmake_language(CALL 🈯::ixm::package::check)
cmake_language(CALL 🈯::ixm::package::import)
