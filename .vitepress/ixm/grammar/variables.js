import { AnyOf, SequenceOf, IncludesRule } from "../parse";
import * as Scopes from "../scopes";

export default {
  variables: new IncludesRule("variables.readwrite", "variables.readonly"),
  "variables.readwrite": {
    name: Scopes.VARIABLE,
    match: new AnyOf(
      new SequenceOf(
        "CMAKE_PROJECT",
        /(?:_[^$()#"\\\s]+)?/,
        /_INCLUDE(?:_BEFORE)?/,
      ),
      /CMAKE_(?:FIND_ROOT|MODULE|LIBRARY|PROGRAM)_PATH/,
      /CMAKE_(?:HOST_)?SYSTEM(?:_(?:PROCESSOR|NAME|VERSION))?/,
      /CMAKE_SYSTEM_(?:APPBUNDLE|FRAMEWORK|IGNORE(?:_PREFIX)?|INCLUDE|LIBRARY|PREFIX|PROGRAM)_PATH/,
      /CMAKE_TRY_COMPILE_(?:PLATFORM_(?:NO_)?VARIABLES|TARGET_TYPE|CONFIGURATION)/,
      /CMAKE_UNIT_BUILD(?:_BATCH_SIZE|_UNIQUE_ID)?/,
      /CMAKE_VS_PLATFORM_NAME(?:_DEFAULT)?/,
      /CMAKE_VS_PLATFORM_TOOLSET(?:_(?:CUDA(?:_CUSTOM_DIR)?|FORTRAN|HOST_ARCHITECTURE|VERSION))?/,
      /\w+_(?:LIBRARY|INCLUDE_DIR|EXECUTABLE|FOUND)/,
      /CMAKE_INSTALL_(?:BIN|LIB|INCLUDE|SBIN|LIBEXEC|SYSCONF|(?:SHARED|LOCAL)STATE|DATA|INFO|LOCALE|MAN|DOC)DIR/,
    ),
  },
  "variables.readonly": {
    name: Scopes.VARIABLE_READONLY,
    match: new AnyOf(
      /CMAKE_GENERATOR/,
      /PROJECT_(?:NAME|VERSION|(?:SOURCE|BINARY)_DIR)/,
      /ARG(?:N|V)/,
    ),
  },
};
