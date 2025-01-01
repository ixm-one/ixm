import { Entry, Group } from "./group";
import * as Scopes from "../scopes";
import { Pattern } from "../parse";

class Scope extends Entry {
  constructor({ name, ...values }) {
    const command = new Pattern(`(?:end)?${name}`);
    super({
      category: "scopes",
      scope: Scopes.KW_SCOPE,
      command,
      name,
      ...values,
    });
  }
}

class CommandScope extends Scope {
  constructor({ name, ...values }) {
    const identifier = /(?:\b([^\s)]+)\b)?\s*/;
    super({ name, ...values });
    this.appendBeginPattern(identifier, Scopes.FUNCTION);
    this.insertPattern(0, Scopes.PARAMETER, identifier);
  }
}

export default new Group(
  { category: "scopes", type: CommandScope },
  new Scope({
    name: "block",
    operators: ["SCOPE_FOR", "PROPAGATE"],
    enums: ["POLICIES", "VARIABLES"],
  }),
  { name: "function" },
  { name: "macro" },
);
