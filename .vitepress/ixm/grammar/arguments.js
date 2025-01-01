import {
  IncludesRule,
  SequenceOf,
  AnyOf,
  PARENS,
  PARAMETER,
  UNQUOTED,
  TARGET,
} from "../parse";
import * as Scopes from "../scopes";

const GENERATOR_EXPRESSIONS = [
  "AND",
  "ANGLE-R",
  "BOOL",
  "COMMA",
  "CONFIG",
  "FILTER",
  "IF",
  "INSTALL_PREFIX",
  "IN_LIST",
  "JOIN",
  "LINK_ONLY",
  "LIST", // TODO: We need to support `LIST:METHOD`
  "MAKE_C_IDENTIFIER",
  "NOT",
  "OR",
  "PATH", // TODO: We need to support `PATH:METHOD`
  "PATH_EQUAL",
  "PLATFORM_ID",
  "QUOTE",
  "REMOVE_DUPLICATES",
  "SEMICOLON",
  "SHELL_PATH",
  "TARGET_BUNDLE_CONTENT_DIR",
  /(?:BUILD(?:_LOCAL)?|INSTALL)_INTERFACE/,
  /(?:C|CXX|CUDA|OBJC|OBJCXX|Fortran|HIP|ISPC)_COMPILER_(?:VERSION|ID|FRONTEND_VARIANT)/,
  /(?:DEVICE|HOST)_LINK/,
  /(?:LINK|COMPILE)_(?:LANG(?:UAGE|_AND_ID)|ONLY|FEATURES)/,
  /(?:LOWER|UPPER)_CASE/,
  /(?:OUTPUT|COMMAND)_CONFIG/,
  /(?:STR)?EQUAL/,
  /(?:TARGET_)?GENEX_EVAL/,
  /LINK_(?:LIBRARY|GROUP)/, // TODO: We need to support LINK_\w+:FEATURE
  /TARGET_(?:(?:BUNDLE|PDB|SONAME|IMPORT|LINKER(?:LIBRARY)?)_)?FILE(?:_(?:(?:BASE_)?NAME|PREFIX|SUFFIX|DIR))?/,
  /TARGET_(?:(?:NAME_IF)?EXISTS|NAME|POLICY|PROPERTY|OBJECTS|RUNTIME_DLLS(?:_DIR)?)/,
  /VERSION_(?:(?:LESS|GREATER)_)?(?:EQUAL)?/,
];

class Dereference {
  constructor(name) {
    this.applyEndPatternLast = true;
    this.begin = /(\$)(CACHE|ENV)?(\{)/;
    this.end = /(\})/;
    this.name = name;
    this.beginCaptures = {
      1: { name: Scopes.DOLLAR },
      2: { name: Scopes.TAG },
      3: { name: Scopes.BRACE.OPEN },
    };
    this.endCaptures = { 1: { name: Scopes.BRACE.CLOSE } };
    this.patterns = [
      { include: "#dereference" },
      { include: "#variables" },
      { match: /[^}]+/, name: Scopes.UNQUOTED },
    ];
  }
}

export default {
  arguments: new IncludesRule(
    "genexp",
    "string",
    "version",
    "number",
    "boolean",
    "variables",
    "dereference",
    "parameter",
    "unquoted",
    "comment",
  ),
  parameter: { name: Scopes.PARAMETER, match: PARAMETER },
  unquoted: { name: Scopes.UNQUOTED, match: UNQUOTED },
  target: { name: Scopes.TARGET, match: TARGET },
  version: { name: Scopes.VERSION, match: /\b\d+(?:[.]\d+){1,4}\b/ },
  number: { name: Scopes.NUMBER, match: /\b\d+\b/ },
  string: new IncludesRule("string.basic", "string.multiline"),
  boolean: {
    name: Scopes.BOOLEAN,
    match: new AnyOf(
      "FALSE",
      "IGNORE",
      /O(?:FF|N)/,
      /TRUE/,
      /NO?/,
      /Y(?:ES)?/,
      /(?:\w+-)?NOTFOUND/,
    ),
  },
  interpolated: new Dereference(Scopes.INTERPOLATED),
  dereference: new Dereference(Scopes.DEREFERENCE),
  genexp: new IncludesRule("genexp.named", "genexp.boolean"),
  "genexp.boolean": {
    name: "meta.generator.expression",
    applyEndPatternLast: true,
    begin: new SequenceOf(/([$])/, /(<)/),
    end: /(>)/,
    beginCaptures: {
      1: { name: Scopes.DOLLAR },
      2: { name: Scopes.ANGLE.OPEN },
    },
    endCaptures: { 1: { name: Scopes.ANGLE.CLOSE } },
    patterns: [{ include: "#genexp.named" }],
  },
  "genexp.named": {
    name: "meta.generator.expression",
    applyEndPatternLast: true,
    begin: new SequenceOf(
      /([$])/,
      /(<)/,
      new AnyOf(...GENERATOR_EXPRESSIONS),
      /(:)?/,
    ),
    end: /(>)/,
    beginCaptures: {
      1: { name: Scopes.DOLLAR },
      2: { name: Scopes.ANGLE.OPEN },
      3: { name: Scopes.GENEXP },
      4: { name: Scopes.COLON },
    },
    endCaptures: { 1: { name: Scopes.ANGLE.CLOSE } },
    patterns: [
      { match: /,/, name: Scopes.COMMA },
      { include: "#properties" },
      { include: "#dereference" },
      { include: "#genexp" },
      { match: /[^$()#",\\\s>]+/, name: Scopes.UNQUOTED },
    ],
  },
  "string.basic": {
    applyEndPatternLast: true,
    name: Scopes.DOUBLE_QUOTED,
    begin: /(")/,
    end: /(")/,
    beginCaptures: { 1: { name: Scopes.QUOTE } },
    endCaptures: { 1: { name: Scopes.QUOTE } },
    patterns: [{ include: "#string.escape" }, { include: "#interpolated" }],
  },
  "string.multiline": {
    name: "string.other.multiline.cmake",
    begin: /\[(=*)\[/,
    end: /\]\1\]/,
  },
  "string.escape": { name: Scopes.CHAR_ESCAPE, match: /\\(?:.|$)/ },
  parentheses: {
    begin: PARENS.OPEN,
    end: PARENS.CLOSE,
    applyEndPatternLast: true,
    beginCaptures: { 1: { name: Scopes.PARENS.OPEN } },
    endCaptures: { 1: { name: Scopes.PARENS.CLOSE } },
    patterns: [
      { include: "#parentheses" },
      { include: "#conditions" },
      { include: "#arguments" },
    ],
  },
  conditions: {
    patterns: [
      {
        name: "keyword.operator.comparison.cmake",
        match: new AnyOf(
          "AND",
          "OR",
          /(?:VERSION_|STR)?(?:(?:LESS|GREATER)(?:_EQUAL)?|EQUAL)/,
          "IS_NEWER_THAN",
          "PATH_EQUAL",
          "MATCHES",
          "IN_LIST",
        ),
      },
      {
        name: "keyword.operator.unary.cmake",
        match: new AnyOf(
          "NOT",
          "COMMAND",
          "POLICY",
          "TARGET",
          "TEST",
          "DEFINED",
          "EXISTS",
          /IS_(?:READABLE|WRITABLE|EXECUTABLE|DIRECTORY|SYMLINK|ABSOLUTE)/,
        ),
      },
    ],
  },
};
