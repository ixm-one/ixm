/**
 * @summary Base class for all rules and patterns. Allows us to know if the
 * regular expression was constructed with an undefined or other false-ish
 * value.
 */
export class Pattern extends RegExp {
  /**
   * @param {string} separator
   * @param {string|RegExp|(string|RegExp)[]} patterns
   * @returns {(undefined|string)}
   */
  static join(separator, patterns) {
    const empty = [];
    const joined = empty
      .concat(patterns ?? [])
      .map((pattern) => (pattern instanceof RegExp ? pattern.source : pattern))
      .join(separator);
    if (joined.length !== 0) {
      return joined;
    }
  }

  /**
   * @summary Allows users to know if a Pattern was constructed with
   * `undefined` or similar "empty" values.
   * @returns {boolean}
   */
  get isEmpty() {
    return this.source === "(?:)";
  }
}

/**
 * @summary Creates a regular expression that combines all patterns passed to
 * the constructor.
 */
export class SequenceOf extends Pattern {
  /**
   * @param {string|RegExp|(string|RegExp)[]} patterns
   */
  constructor(...patterns) {
    super(Pattern.join("", patterns) ?? "");
  }
}

/**
 * @summary Creates a regular expression that matches any word passed to the
 * constructor.
 *
 * @description The resulting regular expression will also have a capture
 * implicitly added to itself.
 */
export class AnyOf extends Pattern {
  /**
   * @param {string|RegExp|(string|RegExp)[]} words
   */
  constructor(...words) {
    let pattern = Pattern.join("|", (words ?? []).flat());
    pattern &&= `\\b(${pattern})\\b`;
    super(pattern);
  }
}
