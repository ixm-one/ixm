/* TextMate scopes tied to VSCode names
 * https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide#predefined-textmate-scope-mappings
 */
export const NAMESPACE = "entity.name.namespace";
export const TYPE = "entity.name.type";
export const TYPE_DEFAULT_LIBRARY = "support.type";
export const STRUCT = "storage.type.struct";
export const CLASS = "entity.name.type.class";
export const CLASS_DEFAULT_LIBRARY = "support.class";
export const INTERFACE = "entity.name.type.interface";
export const ENUM = "entity.name.type.enum";
export const FUNCTION = "entity.name.function";
export const FUNCTION_DEFAULT_LIBRARY = "support.function";
export const METHOD = "entity.name.function.member";
export const MACRO = "entity.name.function.preprocessor";
export const VARIABLE = "variable.other.readwrite";
export const VARIABLE_READONLY = "variable.other.constant";
export const VARIABLE_READONLY_DEFAULTLIBRARY = "support.constant";
export const PARAMETER = "variable.parameter";
export const PROPERTY = "variable.other.property";
export const PROPERTY_READONLY = "variable.other.constant.property";
export const ENUM_MEMBER = "variable.other.enummember";
export const EVENT = "variable.other.event";

/* Generic */
export const NUMBER = "constant.numeric";
export const BOOLEAN = "constant.language";
export const CONSTANT_OTHER = "constant.other";
export const STRING = "string";
export const UNQUOTED = "string.unquoted";
export const DOUBLE_QUOTED = "string.quoted.double";
export const INTERPOLATED = "string.interpolated";
export const COMMENT = "comment";
export const KEYWORD = "keyword";
export const KW_CONTROL = "keyword.control";
export const KW_OPERATOR = "keyword.operator";
export const KW_OTHER = "keyword.other";
export const TAG = "entity.name.tag";
export const MODIFIER = "storage.modifier";
export const CHAR_ESCAPE = "constant.character.escape";
export const COMMENT_BLOCK = "comment.block";
export const COMMENT_LINE = "comment.line.number-sign";
export const DEPRECATED = "invalid.deprecated";

/* CMake/IXM specific */
export const VARIABLE_BUILTIN = "variable.language";
export const VARIABLE_BUILTIN_READONLY = "variable.language.readonly";
export const DEREFERENCE = "variable.other.dereference";
export const VERSION = "constant.numeric.version";
export const EXPR = "constant.other.expression";

export const TARGET_DEFAULT_LIBRARY = "support.target";
export const TARGET = "entity.name.target";
export const GENEXP = "entity.name.genexp";
export const MODULE = "support.other.module";

export const VARIADIC = "variable.parameter.kwarg.cmake.variadic";
export const OPTIONS = "variable.parameter.kwarg.cmake.options";
export const MONADIC = "variable.parameter.kwarg.cmake.monadic";

export const KW_ARTIFACT = "keyword.other.artifact";
export const KW_PROPERTY = "keyword.other.property";
export const KW_COMMAND = "keyword.other.command";
export const KW_TARGET = "keyword.other.target";
export const KW_SCOPE = "keyword.other.scope";
export const KW_FIND = "keyword.other.find";

export const DOLLAR = "punctuation.definition.dollar";
export const COMMA = "punctuation.definition.comma";
export const COLON = "punctuation.definition.colon";
export const QUOTE = "punctuation.definition.quote";
export const AT = "punctuation.definition.at";

export const ANGLE = Object.freeze({
  CLOSE: "punctuation.definition.angle.close",
  OPEN: "punctuation.definition.angle.open",
});

export const BRACE = Object.freeze({
  CLOSE: "punctuation.definition.brace.close",
  OPEN: "punctuation.definition.brace.open",
});

export const BRACKET = Object.freeze({
  CLOSE: "punctuation.definition.bracket.close",
  OPEN: "punctuation.definition.bracket.open",
});

export const PARENS = Object.freeze({
  CLOSE: "punctuation.definition.parentheses.close",
  OPEN: "punctuation.definition.parentheses.open",
});
