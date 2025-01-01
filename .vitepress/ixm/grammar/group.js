import {
  InvokeOf,
  SequenceOf,
  AnyOf,
  RegionRule,
  IncludesRule,
  PARENS,
} from "../parse";
import * as Scopes from "../scopes";

function prepareEntry(item, type) {
  for (const type of [Entry, EntrySet, Group]) {
    if (item instanceof type) {
      return item;
    }
  }
  return new type(item);
}

/**
 * @summary Operates like Object.assign, but correctly filters *and* groups the
 * assigned entries into the IncludesRule
 */
export class Group {
  constructor({ category, group, type }, ...definitions) {
    const ruleName = `${category}.${group ?? "commands"}`;
    if (type) {
      definitions = definitions.map((item) => prepareEntry(item, type));
    }
    this[ruleName] = new IncludesRule();
    Object.defineProperty(this, "category", {
      enumerable: false,
      writable: false,
      value: category,
    });
    Object.defineProperty(this, "ruleName", {
      enumerable: false,
      writable: false,
      value: ruleName,
    });
    this.#append(...definitions);
  }

  #append(...items) {
    items = items
      .filter((item) => item.ruleName !== this.ruleName)
      .filter((item) => item.ruleName.startsWith(this.category));
    const names = items.map((item) => item.ruleName);
    this[this.ruleName].appendInclude(...names);
    Object.assign(this, ...items);
    return this;
  }
}

/**
 * @summary Creates a repository entry with a key and the necessary fields.
 *
 * @description This type is not intended to be used as a rule, but rather
 * assigned or copied into another object to help create a larger rule
 * repository. Users can also inherit from this type to reduce boilerplate for
 * common actions.
 *
 * @example
 * export default {
 *   ...new Entry({
 *     category: `group`,
 *     name: `action`,
 *     command: `cmake_command`,
 *     options: ["SYSTEM"]
 *   }),
 * }
 *
 * @see {@link CommandSignature} for what arguments can be passed to the
 * constructor.
 * @see {@link EntrySet} for creating multiple repository item entries.
 */
export class Entry {
  /**
   * @param {string} category
   * @param {string} scope
   * @param {string} name
   * @param {string?} command
   */
  constructor({ category, scope, name, command, ...values }) {
    const ruleName = category ? `${category}.${name}` : `${name}`;
    this[ruleName] = new CommandSignature({
      patterns: new InvokeOf(command ?? name),
      scope,
      name,
      ...values,
    });
    Object.defineProperty(this, "ruleName", {
      enumerable: false,
      writable: false,
      value: ruleName,
    });
  }

  appendBeginPattern(pattern, capture) {
    const ruleName = this.ruleName;
    this[ruleName].appendBeginPattern(pattern, capture);
  }

  appendPattern(name, pattern) {
    const ruleName = this.ruleName;
    this[ruleName].appendPattern(name, pattern);
  }

  insertPattern(idx, name, pattern) {
    const ruleName = this.ruleName;
    this[ruleName].insertPattern(idx, name, pattern);
  }
}

/**
 * @summary creates multiple repository entries, where each meaningful entry is
 * a subcommand of a larger command.
 *
 * @description This type is not intended to be used as a rule, but rather
 * assigned or copied into another object to help create a larger rule
 * repository. Each key in the object that is not one of the named arguments
 * present is treated as a subcommand or "method".
 */
export class EntrySet {
  constructor({ category, scope, name, command, ...methods }) {
    const pattern = new InvokeOf(command ?? name);
    const prefix = `${category}.${name}`;

    Object.defineProperty(this, "ruleName", {
      enumerable: false,
      writable: false,
      value: prefix,
    });

    this[prefix] = new IncludesRule();

    for (const [key, value] of Object.entries(methods)) {
      const method = new AnyOf(value?.match ?? key.toUpperCase());
      const localScope = scope ?? value?.scope;
      const ruleName = `${prefix}.${key}`;

      this[ruleName] = new CommandSignature({
        scope: localScope,
        name,
        patterns: [pattern, method, /\s*/],
        ...value,
      });
      this[ruleName].appendCapture(Scopes.METHOD);
      this[prefix].appendInclude(ruleName);
    }
  }
}

/**
 * @summary Used to produce the initial object for any command signatures to be
 * matched.
 */
export class CommandSignature extends RegionRule {
  /**
   * @param {string?} scope
   * @param {string|RegExp|(string|RegExp)[]} patterns
   */
  constructor({ scope, patterns, ...values }) {
    super({ begin: new SequenceOf(...[].concat(patterns)), end: PARENS.CLOSE });
    this.applyEndPatternLast = true;
    this.beginCaptures = {
      1: { name: scope ?? Scopes.KW_COMMAND },
      2: { name: Scopes.PARENS.OPEN },
    };
    this.endCaptures = {
      1: { name: Scopes.PARENS.CLOSE },
    };

    const variadics = new AnyOf(values?.variadic);
    const monadics = new AnyOf(values?.monadic);
    const options = new AnyOf(values?.options);

    const operators = new AnyOf(values?.operators);
    const enums = new AnyOf(values?.enums);

    this.appendPattern(Scopes.KW_OPERATOR, operators)
      .appendPattern(Scopes.ENUM_MEMBER, enums)
      .appendPattern(Scopes.VARIADIC, variadics)
      .appendPattern(Scopes.MONADIC, monadics)
      .appendPattern(Scopes.OPTIONS, options)
      .appendInclude(...[].concat(values?.contains ?? `#arguments`));
  }

  appendBeginPattern(pattern, capture) {
    this.begin = new SequenceOf(this.begin, pattern);
    if (capture) {
      this.appendCapture(capture);
    }
  }
}
