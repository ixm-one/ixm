import { Pattern, SequenceOf, AnyOf } from "./common";
import { PARENS } from "./patterns";

/**
 * @summary The most "basic" of rules. Barely sets anything up.
 */
class Rule {
  constructor() {
    this.patterns = [];
  }

  /**
   * @param {string} name
   * @param {Pattern} pattern
   */
  appendPattern(name, pattern) {
    if (!pattern.isEmpty) {
      this.patterns.push({ match: pattern, name });
    }
    return this;
  }

  insertPattern(idx, name, pattern) {
    if (!pattern.isEmpty) {
      this.patterns.splice(idx, 0, { match: pattern, name });
    }
    return this;
  }

  /**
   * @param {...string} names
   */
  appendInclude(...names) {
    const empty = [];
    const includes = empty
      .concat(names ?? [])
      .filter((name) => name)
      .map((name) => {
        const include = name.startsWith("#") ? name : `#${name}`;
        return { include };
      });
    if (includes.length !== 0) {
      this.patterns.push(...includes);
    }
    return this;
  }
}

/**
 * @summary A basic rule for grouping includes together easily
 */
export class IncludesRule extends Rule {
  /**
   * @param {...string} names
   */
  constructor(...names) {
    super();
    if (names?.length) {
      this.appendInclude(...names);
    }
  }
}

/**
 * @summary A rule with a single pattern to match against.
 */
export class PatternRule extends Rule {
  constructor(name, pattern) {
    super();
    this.captures = {};
    this.match = pattern;
    this.name = name;
  }

  /**
   * @param {number} index
   * @param {string} name
   */
  insertCapture(index, name) {
    this.captures[index] = { name };
    return this;
  }

  /**
   * @param {string} name
   */
  appendCapture(name) {
    const idx = Object.keys(this.captures).length + 1;
    return this.insertCapture(idx, name);
  }
}

/**
 * @summary Used to create more complex region rules.
 */
export class RegionRule extends Rule {
  /**
   * @param {string|Pattern} begin
   * @param {string|RegExp} end
   */
  constructor({ begin, end }) {
    super();
    this.beginCaptures = {};
    this.endCaptures = {};
    this.begin = new Pattern(begin);
    this.end = new Pattern(end);
  }

  /**
   * @param {number} index
   * @param {string} name
   */
  insertCapture(index, name) {
    this.beginCaptures[index] = { name };
    return this;
  }

  /**
   * @param {string} name
   */
  appendCapture(name) {
    const idx = Object.keys(this.beginCaptures).length + 1;
    return this.insertCapture(idx, name);
  }
}

/**
 * @summary Represents the opening sequence of a CMake command invocation
 */
export class InvokeOf extends SequenceOf {
  constructor(...command) {
    super(/^\s*/, new AnyOf(...command), /\s*/, PARENS.OPEN, /\s*/);
  }
}
