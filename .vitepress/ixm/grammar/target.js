import { Entry, Group } from "./group";
import { TARGET } from "../parse";
import * as Scopes from "../scopes";

class TargetCommand extends Entry {
  constructor({ name, command, ...values }) {
    const defaults = ["INTERFACE", "PUBLIC", "PRIVATE"];
    const variadic = defaults.concat(values?.variadic ?? []);
    delete values?.variadic;
    command ??= name.replaceAll(".", "_");
    super({
      category: "target",
      scope: Scopes.KW_TARGET,
      command: `target_${command}`,
      name,
      variadic,
      ...values,
    });
    this.appendBeginPattern(TARGET, Scopes.TARGET);
  }
}

export default new Group(
  { category: "target", type: TargetCommand },
  { name: "compile.definitions" },
  { name: "compile.features" },
  { name: "compile.options", options: ["BEFORE"] },
  { name: "include.directories", options: ["SYSTEM", "AFTER", "BEFORE"] },
  { name: "link.directories", options: ["BEFORE"] },
  { name: "link.libraries", contains: ["target", "arguments"] },
  { name: "link.options" },
  { name: "precompile.headers", monadic: ["REUSE_FROM"] },
  {
    name: "sources",
    variadic: ["BASE_DIRS", "FILES"],
    monadic: ["TYPE", "FILE_SET"],
    enums: ["HEADERS", "CXX_MODULES"],
  },
);
