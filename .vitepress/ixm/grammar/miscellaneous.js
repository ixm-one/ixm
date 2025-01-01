import { Entry, EntrySet, Group } from "./group";
import * as Scopes from "../scopes";

class BuiltinCommand extends Entry {
  constructor({ name, command, ...values }) {
    command ??= name.replaceAll(".", "_");
    super({
      category: "miscellaneous",
      scope: Scopes.KW_OTHER,
      name,
      command,
      ...values,
    });
  }
}

class BuiltinCommandSet extends EntrySet {
  constructor({ name, command, ...methods }) {
    command ??= name;
    super({
      category: "miscellaneous",
      scope: Scopes.KW_OTHER,
      command,
      name,
      ...methods,
    });
  }
}

export default new Group(
  { category: "miscellaneous", type: BuiltinCommand },
  {
    name: "configure.file",
    variadic: /(?:(?:NO|USE)_SOURCE|FILE)_PERMISSIONS/,
    monadic: "NEWLINE_STYLE",
    options: [/(?:COPY|@)ONLY/, "ESCAPE_QUOTES"],
    enums: ["DOS", "UNIX", "WIN32", /(?:CR)?LF/],
  },
  {
    name: "execute.process",
    variadic: "COMMAND",
    monadic: [
      "ENCODING",
      "INPUT_FILE",
      "TIMEOUT",
      "WORKING_DIRECTORY",
      /(?:OUTPUT|ERROR)_(?:VARIABLE|FILE)/,
      /COMMAND_(?:ECHO|ERROR_IS_FATAL)/,
      /RESULTS?_VARIABLE/,
    ],
    options: [
      /(?:OUTPUT|ERROR)_(?:STRIP_TRAILING_WHITESPACE|QUIET)/,
      /ECHO_(?:OUTPUT|ERROR)_VARIABLE/,
    ],
    enums: ["LAST", "NONE", "OEM", /UTF-?8/, /A(?:NSI|NY|UTO)/],
  },
  { name: "include.guard", options: ["GLOBAL", "DIRECTORY"] },
  {
    name: "include",
    scope: Scopes.MACRO,
    monadic: ["RESULT_VARIABLE"],
    options: ["OPTIONAL", "NO_POLICY_SCOPE"],
  },
  { name: "mark.as.advanced", options: ["CLEAR", "FORCE"] },
  { name: "option" },
  {
    name: "project",
    variadic: "LANGUAGES",
    monadic: ["VERSION", "DESCRIPTION", "HOMEPAGE_URL"],
  },
  {
    name: "set",
    options: ["CACHE", "FORCE", "PARENT_SCOPE"],
    enums: ["BOOL", /FILE(?:PATH)?/, "STRING", "INTERNAL"],
  },
  {
    name: "source.group",
    parameters: ["TREE", "FILES", "REGULAR_EXPRESSION", "PREFIX"],
  },
  {
    name: "try.compile",
    variadic: [
      /LINK_(?:LIBRARIES|OPTIONS)/,
      /SOURCE_FROM_(?:CONTENT|FILE|VAR)/,
      "COMPILE_DEFINITIONS",
      "CMAKE_FLAGS",
      "SOURCES",
    ],
    monadic: [
      /\w+_STANDARD(?:_REQUIRED)?/,
      /(?:SOURCE|BINARY)_DIR/,
      /COPY_FILE(?:_ERROR)?/,
      /\w+_EXTENSIONS/,
      "PROJECT",
      "TARGET",
      "LOG_DESCRIPTION",
      "OUTPUT_VARIABLE",
      "SOURCES_TYPE",
    ],
    options: ["NO_CACHE", "NO_LOG"],
  },
  {
    name: "try.run",
    variadic: [
      /LINK_(?:OPTIONS|LIBRARIES)/,
      "COMPILE_DEFINITIONS",
      "CMAKE_FLAGS",
      "SOURCES",
      "ARGS",
    ],
    monadic: [
      /(?:(?:COMPILE|RUN)_)?OUTPUT_VARIABLE/,
      /RUN_OUTPUT_STD(?:ERR|OUT)_VARIABLE/,
      /\w+_STANDARD(?:_REQUIRED)?/,
      /COPY_FILE(?:_ERROR)?/,
      /\w+_EXTENSIONS/,
      "WORKING_DIRECTORY",
      "LINKER_LANGUAGE",
    ],
  },
  { name: "unset", options: ["CACHE", "PARENT_SCOPE"] },
  { name: "variable_watch" },
  new BuiltinCommandSet({
    name: "export",
    targets: {
      monadic: ["NAMESPACE", "FILE", "CXX_MODULES_DIRECTORY"],
      options: ["APPEND", "EXPORT_LINK_INTERFACE_LIBRARIES"],
    },
    export: {
      monadic: ["NAMESPACE", "FILE", "CXX_MODULES_DIRECTORY", "ANDROID_MK"],
      options: ["EXPORT_PACKAGE_DEPENDENCIES"],
    },
    package: null,
    setup: {
      monadic: [
        "PACKAGE_DEPENDENCY",
        "ENABLED",
        "TARGET",
        "XCFRAMEWORK_LOCATION",
      ],
      variadic: "EXTRA_ARGS",
      enums: "AUTO",
    },
  }),
  new BuiltinCommandSet({
    name: "math",
    expr: {
      monadic: "OUTPUT_FORMAT",
      options: /(?:HEXA)?DECIMAL/,
    },
  }),
  new BuiltinCommandSet({
    name: "message",
    check_start: null,
    check_pass: null,
    check_fail: null,
    author_warning: null,
    configure_log: null,
    deprecation: null,
    fatal_error: null,
    send_error: null,
    verbose: null,
    notice: null,
    status: null,
    trace: null,
    debug: null,
  }),
  new BuiltinCommandSet({
    name: "install",
    targets: {
      variadic: ["RUNTIME_DEPENDENCIES", "PERMISSIONS", "CONFIGURATIONS"],
      monadic: [
        /(?:NAMELINK_)?COMPONENT/,
        "RUNTIME_DEPENDENCY_SET",
        "DESTINATION",
        "EXPORT",
      ],
      options: ["OPTIONAL", "EXCLUDE_FROM_ALL", /NAMELINK_(?:ONLY|SKIP)/],
      operators: [
        /(?:PUBLIC|PRIVATE)_HEADER/,
        "CXX_MODULES_BMI",
        "FRAMEWORK",
        "RESOURCE",
        "FILE_SET",
        "ARCHIVE",
        "LIBRARY",
        "RUNTIME",
        "OBJECTS",
        "BUNDLE",
      ],
    },
    // TODO: Finish implementing this.
    imported_runtime_artifacts: null,
    export_android_mk: { monadic: "DESTINATION" },
    package_info: {
      variadic: [
        /DEFAULT_(?:TARGETS|CONFIGURATIONS)/,
        "PERMISSIONS",
        "CONFIGURATIONS",
      ],
      monadic: [
        "EXPORT",
        "APPENDIX",
        "DESTINATION",
        "VERSION",
        "COMPAT_VERSION",
        "VERSION_SCHEMA",
        "COMPONENT",
      ],
      option: ["LOWER_CASE_FILE", "EXCLUDE_FROM_ALL"],
    },
    // TODO: Finish implementing this.
    runtime_dependency_set: null,
    // TODO: Finish implementing this.
    directory: null,
    // TODO: Finish implementing this.
    programs: null,
    // TODO: Finish implementing this.
    script: null,
    // TODO: Finish implementing this.
    export: null,
    // TODO: Finish implementing this.
    files: null,
    // TODO: Finish implementing this.
    code: null,
  }),
  /*{
    parameters: [
      "APPENDIX",
      "ARCHIVE",
      "BUNDLE",
      "COMPONENT",
      "CONFIGURATIONS",
      "DESTINATION",
      "FRAMEWORK",
      "INCLUDES",
      "LIBRARY",
      "NAMESPACE",
      "OBJECTS",
      "PATTERN",
      "PERMISSIONS",
      "REGEX",
      "RENAME",
      "RESOURCE",
      "RUNTIME",
      "TYPE",
      /(?:(?:FILE|DIRECTORY|USE_SOURCE)_)?PERMISSIONS/,
      /(COMPAT_)?VERSION(_SCHEMA)?/,
      /(PRE|POST)_(INCLUDE|EXCLUDE)_(REGEXES|FILES)/,
      /CXX_MODDULES_(BMI|DIRECTORY)/,
      /DEFAULT_(TARGETS|CONFFIGURATIONS)/,
      /EXPORT(?:_(LINK_INTERFACE_LIBRARIES|PACKAGE_DEPENDENCIES))?/,
      /FILE(_SET)?/,
      /NAMELINK_(?:COMPONENT|ONLY|SKIP)/,
      /P(?:UBLIC|RIVATE)_HEADER/,
      /RUNTIME_DEPENDENC(?:IES|Y_SET)/,
    ],
    options: [
      "ALL_COMPONENTS",
      "FILES_MATCHING",
      "LOWER_CASE_FILE",
      "MESSAGE_NEVER",
      "OPTIONAL",
      /EXCLUDE(?:_FROM_ALL)?/,
    ],
  },*/
);
