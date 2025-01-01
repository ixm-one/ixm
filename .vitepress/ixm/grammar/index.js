import Properties from "./properties";
import Variables from "./variables";
import Arguments from "./arguments";
import Commands from "./commands";
import Comment from "./comment";
import DocTags from "./doctags";

import * as Scopes from "../scopes";
import { InvokeOf, PARENS } from "../parse";

/**
 * @summary Mutates a simplified object model to the correct form for ingestion
 * by Shiki
 * @param {*} value
 */
function mutate(value) {
  switch (true) {
    case value instanceof RegExp:
      return value.source;
    case value instanceof Array:
      return value.map(mutate);
    case value instanceof Object: {
      const entries = Object.entries(value).map(([key, value]) => [
        key,
        mutate(value),
      ]);
      return Object.fromEntries(entries);
    }
    default:
      return value;
  }
}

export default mutate({
  displayName: `CMake`,
  fileTypes: [`cmake`, `cmake.in`, `CMakeLists.txt`],
  name: `cmake`,
  scopeName: `source.cmake`,
  patterns: [
    { include: `#comment` },
    { include: `#commands` },
    {
      name: "meta.function",
      comment: `Any generic command call`,
      applyEndPatternLast: true,
      begin: new InvokeOf(/\w+/),
      end: PARENS.CLOSE,
      beginCaptures: {
        1: { name: Scopes.FUNCTION_DEFAULT_LIBRARY },
        2: { name: Scopes.PARENS.OPEN },
      },
      endCaptures: { 1: { name: Scopes.PARENS.CLOSE } },
      patterns: [{ include: `#arguments` }],
    },
  ],
  repository: Object.assign(
    Properties,
    Variables,
    Arguments,
    Commands,
    Comment,
    DocTags,
  ),
});

// Guides on writing text mate grammars + regex syntax when we can't use JS syntax.
// https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
// https://github.com/RedCMD/TmLanguage-Syntax-Highlighter/blob/main/documentation/rules.md
// https://macromates.com/manual/en/language_grammars
// https://github.com/kkos/oniguruma/blob/master/doc/RE
