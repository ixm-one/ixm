import { AnyOf, IncludesRule } from "../parse";
import * as Scopes from "../scopes";

export default {
  properties: new IncludesRule("properties.readwrite", "properties.readonly"),
  "properties.readwrite": {
    name: Scopes.PROPERTY,
    match: new AnyOf(
      /\w+_CLANG_TIDY_OPTIONS/,
      "IMPORTED_LOCATION",
      "VERSION",
      /ANDROID_(?:API(?:_MIN)?|ARCH)/,
    ),
  },
  /*
  "properties.readonly": {
    name: Scopes.PROPERTY_READONLY,
    match: new AnyOf(),
  },
*/
};
