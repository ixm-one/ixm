import { Entry, Group } from "./group";
import * as Scopes from "../scopes";
import { TARGET } from "../parse";

class ArtifactCommand extends Entry {
  constructor({ name, command, ...values }) {
    command ??= name.replaceAll(".", "_");
    super({
      category: "artifact",
      scope: Scopes.KW_ARTIFACT,
      command: `add_${command}`,
      name,
      ...values,
    });
    this.appendBeginPattern(TARGET, Scopes.TARGET);
  }
}

export default new Group(
  { category: "artifact", type: ArtifactCommand },
  {
    name: "custom.command",
    variadic: [
      "OUTPUT",
      "COMMAND",
      "DEPENDS",
      "BYPRODUCTS",
      "IMPLICIT_DEPENDS",
    ],
    monadic: [
      "MAIN_DEPENDENCY",
      "COMMENT",
      "WORKING_DIRECTORY",
      "DEPFILE",
      /JOB_(?:POOL|SERVER_AWARE)/,
    ],
    options: [
      "VERBATIM",
      "APPEND",
      "USES_TERMINAL",
      "CODEGEN",
      "COMMAND_EXPAND_LISTS",
      "DEPENDS_EXPLICIT_ONLY",
    ],
  },
  {
    name: "custom.target",
    variadic: ["COMMAND", "DEPENDS", "BYPRODUCTS", "SOURCES"],
    monadic: ["COMMENT", "WORKING_DIRECTORY", /JOB_(?:POOL|SERVER_AWARE)/],
    options: ["VERBATIM", "USES_TERMINAL", "COMMAND_EXPAND_LISTS", "ALL"],
  },
  { name: "dependencies" },
  {
    name: "library",
    enums: [
      "ALIAS",
      "STATIC",
      "SHARED",
      "MODULE",
      "OBJECT",
      "INTERFACE",
      "UNKNOWN",
    ],
    options: ["IMPORTED", "GLOBAL", "EXCLUDE_FROM_ALL"],
  },
  {
    name: "executable",
    enums: "ALIAS",
    options: [
      "IMPORTED",
      "GLOBAL",
      "EXCLUDE_FROM_ALL",
      "WIN32",
      "MACOSX_BUNDLE",
    ],
  },
  {
    name: "test",
    variadic: ["COMMAND", "CONFIGURATIONS"],
    monadic: "WORKING_DIRECTORY",
    options: "COMMAND_EXPAND_LISTS",
  },
);
