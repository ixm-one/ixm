import Miscellaneous from "./miscellaneous";
import ControlFlow from "./control-flow";
import Directory from "./directory";
import Artifact from "./artifact";
import Datatype from "./datatype";
import Reserved from "./reserved";
import Property from "./property";
import Modules from "./modules";
import Scopes from "./scopes";
import Target from "./target";
import Find from "./find";

import { IncludesRule } from "../parse";

export default Object.assign(
  {
    commands: new IncludesRule(
      "miscellaneous.commands",
      "control.flow.commands",
      "directory.commands",
      "artifact.commands",
      "datatype.commands",
      "reserved.commands",
      "property.commands",
      "modules.commands",
      "target.commands",
      "scopes.commands",
      "find.commands",
    ),
  },
  Miscellaneous,
  ControlFlow,
  Directory,
  Artifact,
  Datatype,
  Reserved,
  Property,
  Modules,
  Target,
  Scopes,
  Find,
);
