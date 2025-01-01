import { EntrySet, Entry, Group } from "./group";
import * as Scopes from "../scopes";

class PropertyCommand extends Entry {
  constructor({ name, command, ...values }) {
    command ??= `${name.replaceAll(".", "_")}_property`;
    super({
      category: "property",
      scope: Scopes.KW_PROPERTY,
      name,
      command,
      contains: ["properties", "arguments"],
      ...values,
    });
  }
}

class PropertyCommandSet extends EntrySet {
  constructor({ name, command, ...methods }) {
    command ??= `${name.replaceAll(".", "_")}_property`;
    super({
      category: "property.methods",
      scope: Scopes.KW_PROPERTY,
      command,
      name,
      ...methods,
    });
  }
}

const definePropertyArguments = {
  variadic: /(?:BRIEF|FULL)_DOCS/,
  monadic: ["PROPERTY", "INITIALIZE_FROM_VARIABLE"],
  options: ["INHERITED"],
  contains: ["properties", "arguments"],
};

const getPropertyArguments = {
  variadic: "PROPERTY",
  options: ["SET", "DEFINED", /(?:BRIEF|FULL)_DOCS/],
  contains: ["properties", "arguments"],
};

const setPropertyArguments = {
  variadic: "PROPERTY",
  monadic: /(?:TARGET_)?DIRECTORY/,
  options: /APPEND(?:_STRING)?/,
  contains: ["properties", "arguments"],
};

export default new Group(
  { category: "property", type: PropertyCommand },
  // TODO: Change define|get|set to be {PropertyCommandSet}s
  new PropertyCommandSet({
    name: "define",
    global: definePropertyArguments,
    directory: definePropertyArguments,
    target: definePropertyArguments,
    source: definePropertyArguments,
    test: definePropertyArguments,
    variable: definePropertyArguments,
    cached_variable: definePropertyArguments,
  }),
  new PropertyCommandSet({
    name: "get",
    global: getPropertyArguments,
    directory: getPropertyArguments,
    target: getPropertyArguments,
    source: getPropertyArguments,
    test: getPropertyArguments,
    variable: getPropertyArguments,
    cache: getPropertyArguments,
  }),
  new PropertyCommandSet({
    name: "set",
    global: setPropertyArguments,
    directory: setPropertyArguments,
    target: setPropertyArguments,
    source: setPropertyArguments,
    test: setPropertyArguments,
    install: setPropertyArguments,
    cache: setPropertyArguments,
  }),
  { name: "get.directory", monadic: ["DIRECTORY", "DEFINITION"] },
  { name: "get.cmake" },
  { name: "get.source.file", monadic: /(?:TARGET_)?DIRECTORY/ },
  { name: "get.target" },
  { name: "get.test", monadic: "DIRECTORY" },

  {
    name: "set.directory",
    command: "set_directory_properties",
    parameters: "PROPERTIES",
  },
  {
    name: "set.source.files",
    command: "set_source_files_properties",
    monadic: /(?:TARGET_)?DIRECTORY/,
    variadic: "PROPERTIES",
  },
  {
    name: "set.target",
    command: "set_target_properties",
    variadic: "PROPERTIES",
  },
  {
    name: "set.tests",
    command: "set_test_properties",
    parameters: ["PROPERTIES", "DIRECTORY"],
  },
);
