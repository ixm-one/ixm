import { Entry, Group } from "./group";
import * as Scopes from "../scopes";

class ControlFlow extends Entry {
  constructor({ name, command, ...values }) {
    command ??= name;
    super({
      category: "control.flow",
      scope: Scopes.KW_CONTROL,
      command,
      name,
      ...values,
    });
  }
}

export default new Group(
  { category: "control.flow", type: ControlFlow },
  {
    name: "if",
    command: /(?:(?:end|else)?if)|else/,
    contains: ["parentheses", "conditions", "arguments"],
  },
  {
    name: "while",
    command: /(?:end)?while/,
    contains: ["parentheses", "conditions", "arguments"],
  },
  {
    name: "foreach",
    command: /(?:end)?foreach/,
    operators: ["RANGE", "IN", "ITEMS", /(?:ZIP_)?LISTS/],
  },
  { name: "break", contains: [] },
  { name: "continue", contains: [] },
  { name: "return", variadic: "PROPAGATE" },
);
