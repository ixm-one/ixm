cmake_language(CALL ixm::find::program
  NAMES clang-tidy
  DESCRIPTION "Path to clang-tidy executable"
  VERSION)

cmake_language(CALL ixm::package::check)
cmake_language(CALL ixm::package::import)
cmake_language(CALL ixm::package::properties
  DESCRIPTION "Clang based C++ linter tool."
  URL "https://clang.llvm.org/extra/clang-tidy")

foreach (language IN ITEMS OBJCXX OBJC CXX C)
  define_property(TARGET
    PROPERTY ${language}_CLANG_TIDY_OPTIONS INHERITED
    INITIALIZE_FROM_VARIABLE IXM_${language}_CLANG_TIDY_OPTIONS)
endforeach()
