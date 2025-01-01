import { Entry, Group } from "./group";
import * as Scopes from "../scopes";

class DirectoryCommand extends Entry {
  constructor({ name, command, ...values }) {
    command ??= name.replaceAll(".", "_");
    super({ category: "directory", name, command, ...values });
  }
}

export default new Group(
  { category: "directory", type: DirectoryCommand },
  { name: "compile.definitions", command: "add_compile_definitions" },
  { name: "compile.options", command: "add_compile_options" },
  { name: "include.directories", options: ["AFTER", "BEFORE", "SYSTEM"] },
  { name: "link.directories", options: ["AFTER", "BEFORE"] },
  { name: "link.options", command: "add_link_options" },
  { name: "link.libraries" },
  {
    name: "add",
    scope: Scopes.MACRO,
    command: "add_subdirectory",
    options: ["EXCLUDE_FROM_ALL", "SYSTEM"],
  },
);
