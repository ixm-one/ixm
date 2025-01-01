import { SequenceOf, AnyOf } from "../parse";
import * as Scopes from "../scopes";

class Tag {
  constructor({ names, type = undefined, patterns = [] }) {
    const tag = new AnyOf(names);
    const partialPatterns = type ? [{ include: `#doctags.${type}.type` }] : [];
    this.begin = new SequenceOf(
      /(?<=#\s*)/,
      `((@)(?:${tag.source}))`,
      /\s*/,
      type ? "(?={)" : "",
    );
    this.end = /\s+/;
    this.beginCaptures = { 1: { name: Scopes.TAG }, 2: { name: Scopes.AT } };
    this.patterns = partialPatterns.concat(patterns);
  }
}

class Scope {
  constructor(name) {
    this.beginCaptures = { 1: { name: name.OPEN } };
    this.endCaptures = { 1: { name: name.CLOSE } };
  }
}

class Type extends Scope {
  constructor({ scopes, types }) {
    super(Scopes.BRACE);
    const scope = new AnyOf(scopes);
    types ??= [/[^:}]+/];
    // TODO: Fix word boundary issue.
    types = new AnyOf(types.concat(/[*]/));
    this.begin = /({)/;
    this.end = /(})\s*/;
    this.patterns = [
      {
        name: "meta.type",
        match: `(?:${scope.source}(:))?${types.source}`,
        captures: {
          1: { name: Scopes.MODIFIER },
          2: { name: Scopes.COLON },
          3: { name: Scopes.TYPE },
        },
      },
      { name: Scopes.COMMA, match: /,/ },
    ];
  }
}

export default {
  documentation: {
    name: "comment.block.documentation.cmake",
    patterns: [
      { include: "#doctags.@argument" },
      { include: "#doctags.@author" },
      { include: "#doctags.@copyright" },
      { include: "#doctags.@defines" },
      { include: "#doctags.@deprecated" },
      { include: "#doctags.@description" },
      { include: "#doctags.@error" },
      { include: "#doctags.@example" },
      { include: "#doctags.@file" },
      { include: "#doctags.@ignore" },
      { include: "#doctags.@license" },
      { include: "#doctags.@module" },
      { include: "#doctags.@property" },
      { include: "#doctags.@readonly" },
      { include: "#doctags.@return" },
      { include: "#doctags.@see" },
      { include: "#doctags.@since" },
      { include: "#doctags.@summary" },
      { include: "#doctags.@target" },
      { include: "#doctags.@todo" },
      { include: "#doctags.@version" },
      { include: "#doctags.@warning" },
    ],
  },
  "doctags.@argument": new Tag({
    names: ["argument", "parameter", "param", "arg"],
    type: "argument",
    patterns: [
      { include: "#doctags.name" },
      { include: "#doctags.assignment" },
    ],
  }),
  "doctags.@author": new Tag({
    names: "author",
    patterns: [
      { name: "markup.other.author", match: /[^<]+|$/ },
      { include: "#doctags.email" },
    ],
  }),
  "doctags.@copyright": new Tag({
    names: "copyright",
    patterns: [
      { match: /[^\d]+/, name: "markup.other.copyright" },
      { include: "#number" },
    ],
  }),
  "doctags.@defines": new Tag({
    names: /defines?/,
    type: "argument",
    patterns: [{ include: "#doctags.name" }],
  }),
  "doctags.@deprecated": new Tag({ names: "deprecated" }),
  "doctags.@description": new Tag({ names: ["description", "desc"] }),
  "doctags.@error": new Tag({ names: ["errors?", "fatal"] }),
  "doctags.@example": new Tag({ names: "example" }),
  "doctags.@ignore": new Tag({
    names: "ignore",
    patterns: [{ include: "#doctags.name" }],
  }),
  "doctags.@license": new Tag({
    names: "license",
    patterns: [{ match: /\S+/, name: "markup.other.license" }],
  }),
  "doctags.@module": new Tag({
    names: "module",
    patterns: [{ match: /\S+/, name: Scopes.MODULE }],
  }),
  "doctags.@file": new Tag({ names: ["file", "overview"] }),
  "doctags.@property": new Tag({
    names: ["property", "prop"],
    type: "property",
    patterns: [{ include: "#doctags.name" }],
  }),
  "doctags.@return": new Tag({ names: /returns?/, type: "argument" }),
  "doctags.@readonly": new Tag({ names: "readonly" }),
  "doctags.@summary": new Tag({ names: "summary" }),
  "doctags.@target": new Tag({
    names: "target",
    type: "target",
    patterns: [{ include: "#doctags.target" }],
  }),
  "doctags.@see": new Tag({
    names: "see",
    patterns: [{ match: /.+/, name: Scopes.CONSTANT_OTHER }],
  }),
  "doctags.@since": new Tag({
    names: "since",
    patterns: [{ include: "#version" }],
  }),
  "doctags.@todo": new Tag({ names: "todo" }),
  "doctags.@version": new Tag({
    names: "version",
    patterns: [{ include: "#version" }],
  }),
  "doctags.@warning": new Tag({ names: /warn(?:ing|s)?/ }),
  /* support entries */
  "doctags.email": {
    begin: /(<)/,
    end: /(>)/,
    contentName: "markup.other.email",
    ...new Scope(Scopes.ANGLE),
  },
  "doctags.name": { name: "variable.parameter.cmake", match: /(?:\w|[.])+/ },
  "doctags.target": { name: "storage.type.target", match: /\S+/ },
  "doctags.property.type": new Type({
    scopes: ["global", "directory", "target", "source", "install", "cache"],
  }),
  "doctags.target.type": new Type({
    scopes: ["imported", "global"],
    types: [
      "static",
      "shared",
      "module",
      "object",
      "interface",
      "unknown",
      "custom",
    ],
  }),
  "doctags.argument.type": new Type({
    scopes: ["cache", "internal"],
    types: [
      /\*/,
      "bool",
      "command",
      "filepath",
      "integer",
      "list",
      "option",
      "path",
      "ref(?:erence)?",
      "string",
      "target",
      "test",
      "version",
    ],
  }),
  // TODO: Make the second pattern an `=` followed by a generator expression
  "doctags.assignment": {
    begin: /(\[)/,
    end: /(\])/,
    applyEndAfterLast: true,
    ...new Scope(Scopes.BRACKET),
    patterns: [
      { include: "#doctags.name" },
      {
        match: /(=([^\]]+))/,
        captures: { 1: Scopes.KW_OPERATOR, 2: Scopes.EXPR },
      },
    ],
  },
};
