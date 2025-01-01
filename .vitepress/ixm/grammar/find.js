import { Entry, Group } from "./group";
import * as Scopes from "../scopes";

class FindCommand extends Entry {
  constructor({ name, ...values }) {
    super({
      category: "find",
      command: `find_${name}`,
      scope: Scopes.KW_FIND,
      name,
      operators: "ENV",
      enums: ["64", "32", "64_32", "32_64", "HOST", "TARGET", "BOTH"],
      variadic: ["NAMES", "HINTS", /PATH(?:_SUFFIXE)?S/],
      monadic: ["REGISTRY_VIEW", "VALIDATOR", "DOC"],
      options: [
        "BOTH",
        "CMAKE_FIND_ROOT_PATH_BOTH",
        "HOST",
        "NO_CACHE",
        "REQUIRED",
        "TARGET",
        /(?:ONLY|NO)_CMAKE_FIND_ROOT_PATH/,
        /32(?:_64)?/,
        /64(?:_32)?/,
        /NO_(?:CMAKE|SYSTEM)_ENVIRONMENT_PATH/,
        /NO_(?:DEFAULT|PACKAGE_ROOT|CMAKE)_PATH/,
        /NO_CMAKE_(?:(?:SYSTEM_)?PATH|INSTALL_PREFIX)/,
        ...(values?.options ?? []),
      ],
    });
  }
}

export default new Group(
  { category: "find", type: FindCommand },
  { name: "program", options: ["NAMES_PER_DIR"] },
  { name: "library", options: ["NAMES_PER_DIR"] },
  { name: "file" },
  { name: "path" },
  {
    name: "package",
    variadic: [/(?:OPTIONAL_)?COMPONENTS/, "CONFIGS"],
    options: [
      /NO_(?:MODULE|POLICY_SCOPE)/,
      "BYPASS_PROVIDERS",
      "GLOBAL",
      "CONFIG",
      "EXACT",
      "QUIET",
    ],
  },
);
