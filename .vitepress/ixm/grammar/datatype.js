import { EntrySet, Group } from "./group";
import * as Scopes from "../scopes";

class DataEntrySet extends EntrySet {
  constructor({ name, command, ...methods }) {
    command ??= name;
    super({
      category: "datatype",
      scope: Scopes.TYPE,
      name,
      command,
      ...methods,
    });
  }
}

export default new Group(
  { category: `datatype`, type: DataEntrySet },
  {
    name: `list`,
    length: null,
    get: null,
    join: null,
    sublist: null,
    find: null,
    append: null,
    prepend: null,
    filter: {
      options: /(?:IN|EX)CLUDE/,
      monadic: "REGEX",
    },
    pop: { match: /POP_(?:FRONT|BACK)/ },
    remove: { match: /REMOVE_(?:DUPLICATES|ITEM|AT)/ },
    transform: {
      operators: [
        /(?:AP|PRE)PEND/,
        /TO(?:LOW|UPP)ER/,
        /(?:GENEX_)?STRIP/,
        "REPLACE",
      ],
      enums: ["AT", "FOR", "REGEX"],
    },
    reverse: null,
    sort: {
      monadic: ["COMPARE", "CASE", "ORDER"],
      enums: [
        "STRING",
        "FILE_BASENAME",
        "NATURAL",
        /(?:IN)?SENSITIVE/,
        /(?:A|DE)SCENDING/,
      ],
    },
  },
  {
    name: `string`,
    regex: { match: /REGEX\s*MATCH(?:ALL)?/ },
    find: { options: "REVERSE" },
    append: null,
    prepend: null,
    concat: null,
    join: null,
    case: { match: /TO(?:LOW|UPP)ER/ },
    length: null,
    substring: null,
    strip: { match: /(?:GENEX_)?STRIP/ },
    repeat: null,
    compare: {
      operators: [/(?:LESS|GREATER)(?:_EQUAL)?/, /(?:NOT)?EQUAL/],
    },
    hash: {
      match: /SHA(?:(?:3_)?(?:224|256|384|512)|1)|MD5/,
    },
    ascii: null,
    hex: null,
    configure: { options: ["@ONLY", "ESCAPE_QUOTES"] },
    make_c_identifier: null,
    random: {
      monadic: ["LENGTH", "ALPHABET", "RANDOM_SEED"],
    },
    timestamp: {
      options: "UTC",
    },
    uuid: {
      enums: ["MD5", "SHA1"],
      monadic: ["NAMESPACE", "NAME", "TYPE"],
      options: "UPPER",
    },
    json: {
      monadic: "ERROR_VARIABLE",
      operators: ["GET", "TYPE", "MEMBER", "REMOVE", "SET", "EQUAL"],
    },
  },
  {
    command: `cmake_path`,
    name: `path`,
    get: {
      operators: [
        /ROOT_(?:NAME|PATH|DIRECTORY)/,
        "FILENAME",
        "EXTENSION",
        "STEM",
        "RELATIVE_PART",
        "PARENT_PATH",
      ],
      options: "LAST_ONLY",
    },
    has: {
      match: [
        /HAS_(?:ROOT_(?:NAME|PATH|DIRECTORY))/,
        "HAS_FILENAME",
        "HAS_EXTENSION",
        "HAS_STEM",
        "HAS_RELATIVE_PART",
        "HAS_PARENT_PATH",
      ],
    },
    is: {
      match: /IS_(?:ABSOLUTE|RELATIVE)/,
    },
    prefix: { match: "IS_PREFIX", options: "NORMALIZE" },
    compare: { operators: /(?:NOT_)?EQUAL/ },
    set: { options: "NORMALIZE" },
    append: { match: /APPEND(?:_STRING)?/, monadic: "OUTPUT_VARIABLE" },
    filename: {
      match: /(?:REMOVE|REPLACE)_FILENAME/,
      monadic: "OUTPUT_VARIABLE",
    },
    extension: {
      match: /(?:REMOVE|REPLACE)_EXTENSION/,
      monadic: "OUTPUT_VARIABLE",
      options: "LAST_ONLY",
    },
    normal: { match: "NORMAL_PATH", monadic: "OUTPUT_VARIABLE" },
    path: {
      match: /(?:RELATIVE|ABSOLUTE)/,
      monadic: ["BASE_DIRECTORY", "OUTPUT_VARIABLE"],
      options: "NORMALIZE",
    },
    native: { match: /NATIVE_PATH/, options: "NORMALIZE" },
    convert: {
      operators: /TO_(?:CMAKE|NATIVE)_PATH_LIST/,
      options: "NORMALIZE",
    },
    hash: null,
  },
  {
    name: `file`,
    read: {
      monadic: ["OFFSET", "LIMIT", "HEX"],
    },
    strings: {
      monadic: [
        /LENGTH_M(?:AX|IN)IMUM/,
        /LIMIT_(?:COUNT|INPUT|OUTPUT)/,
        "REGEX",
        "ENCODING",
      ],
      options: ["NEWLINE_CONSUME", "NO_HEX_CONVERSION"],
      enums: /UTF-(?:8|(?:(?:16|32)(?:BE|LE)))/,
    },
    hash: {
      match: /SHA(?:(?:3_)?(?:224|256|384|512)|1)|MD5/,
    },
    timestamp: { options: "UTC" },
    write: null,
    append: null,
    touch: { match: /TOUCH(?:_NOCREATE)?/ },
    generate: {
      variadic: "FILE_PERMISSIONS",
      monadic: [
        "OUTPUT",
        "INPUT",
        "CONTENT",
        "CONDITION",
        "TARGET",
        "NEWLINE_STYLE",
      ],
      options: /(?:USE|NO)_SOURCE_PERMISSIONS/,
      enums: ["UNIX", "DOS", "WIN32", "LF", "CRLF"],
    },
    configure: {
      monadic: ["OUTPUT", "CONTENT", "NEWLINE_STYLE"],
      options: ["ESCAPE_QUOTES", "@ONLY"],
      enums: ["UNIX", "DOS", "WIN32", "LF", "CRLF"],
    },
    glob: {
      match: /GLOB(?:_RECURSE)/,
      monadic: ["LIST_DIRECTORIES", "RELATIVE"],
      options: ["CONFIGURE", "FOLLOW_SYMLINKS"],
    },
    mkdir: { match: "MAKE_DIRECTORY", monadic: "RESULT" },
    remove: { match: /REMOVE(?:_RECURSE)/ },
    rename: { monadic: "RESULT", options: "NO_REPLACE" },
    copy: {
      match: "COPY_FILE",
      monadic: "RESULT",
      options: ["ONLY_IF_DIFFERENT", "INPUT_MAY_BE_RECENT"],
    },
    install: {
      match: ["COPY", "INSTALL"],
      operators: "FILES_MATCHING",
      variadic: /(?:(?:DIRECTORY|FILE)_)?PERMISSIONS/,
      monadic: ["DESTINATION", "PATTERN", "REGEX"],
      options: [
        /(?:USE|NO)_SOURCE_PERMISSIONS/,
        "EXCLUDE",
        "FOLLOW_SYMLINK_CHAIN",
      ],
    },
    size: null,
    query: { match: "READ_SYMLINK" },
    create: {
      match: "CREATE_LINK",
      monadic: "RESULT",
      options: ["COPY_ON_ERROR", "SYMBOLIC"],
    },
    chmod: {
      match: /CHMOD(?:_RECURSE)?/,
      variadic: /(?:(?:DIRECTORY|FILE)_)?PERMISSIONS/,
    },
    "path.deprecated": {
      scope: Scopes.DEPRECATED,
      match: /(?:TO_(?:NATIVE|CMAKE)|RELATIVE)_PATH/,
    },
    path: {
      match: "REAL_PATH",
      monadic: "BASE_DIRECTORY",
      options: "EXPAND_TILDE",
    },
    bandwidth: {
      match: /(?:DOWN|UP)LOAD/,
      monadic: [
        "INACTIVITY_TIMEOUT",
        "LOG",
        "STATUS",
        "TIMEOUT",
        "USERPWD",
        "HTTPHEADER",
        /NETRC(?:_FILE)?/,
        /TLS_(?:VERSION|VERIFY|CAINFO)/,
        "EXPECTED_HASH",
        /RANGE_(?:START|END)/,
      ],
      options: "SHOW_PROGRESS",
      enums: ["IGNORED", "OPTIONAL", "REQUIRED"],
    },
    lock: {
      monadic: ["RESULT_VARIABLE", "TIMEOUT", "GUARD"],
      options: ["DIRECTORY", "RELEASE"],
      enums: ["FUNCTION", "FILE", "PROCESS"],
    },
    "archive.create": {
      match: "ARCHIVE_CREATE",
      variadic: "PATHS",
      monadic: [
        "OUTPUT",
        "FORMAT",
        /COMPRESSION(?:_LEVEL)?/,
        "MTIME",
        "WORKING_DIRECTORY",
      ],
      options: ["VERBOSE"],
    },
    "archive.extract": {
      match: "ARCHIVE_EXTRACT",
      variadic: "PATTERNS",
      monadic: ["INPUT", "DESTINATION"],
      options: ["LIST_ONLY", "VERBOSE", "TOUCH"],
    },
    runtime: {
      match: "GET_RUNTIME_DEPENDENCIES",
      variadic: [
        /(?:PRE|POST)_(?:INCLUDE|EXCLUDE)_REGEXES/,
        /POST_(?:INCLUDE|EXCLUDE)_FILES/,
        "BUNDLE_EXECUTABLE",
        "DIRECTORIES",
        "EXECUTABLES",
        "LIBRARIES",
        "MODULES",
      ],
      monadic: [
        /(?:UN)?RESOLVED_DEPENDENCIES_VAR/,
        "CONFLICTING_DEPENDENCIES_PREFIX",
      ],
    },
  },
);
