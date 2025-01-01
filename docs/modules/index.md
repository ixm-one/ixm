---
title: Modules
order: 2
next:
  text: ExtractAutoconfVersion
  link: ./extract-autoconf-version
---

# Modules

 IXM provides several CMake modules that are entirely opt-in, much like CMake's
 builtin modules. These are much more focused on feature behavior. For example,
 we provide a common operation used by projects that provide both autotools and
 CMake based build systems, namely [extracting the value found in the
 `configure.ac` file](./extract-autoconf-version).
