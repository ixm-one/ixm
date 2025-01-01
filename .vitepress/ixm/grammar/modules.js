import { Entry, Group } from "./group";
import * as Scopes from "../scopes";

class Function extends Entry {
  constructor({ name, command, ...values }) {
    super({
      category: "modules",
      scope: Scopes.FUNCTION_DEFAULT_LIBRARY,
      ...values,
      command,
      name,
    });
  }
}

export default new Group(
  { category: "modules", type: Function },
  {
    command: "find_package_handle_standard_args",
    name: "find.package.standard.args",
  },
  {
    command: "FetchContent_MakeAvailable",
    name: "fetchcontent.available",
  },
  {
    command: "FetchContent_Declare",
    name: "fetchcontent.declare",
    variadic: [
      "FIND_PACKAGE_ARGS",
      "HTTP_HEADER",
      /GIT_(?:SUBMODULES(?:_RECURSE)?|CONFIG)?/,
    ],
    monadic: [
      /URL(?:_(?:HASH|MD5))?/,
      /DOWNLOAD_(?:EXTRACT_TIMESTAMP|NO_(?:EXTRACT|PROGRESS))/,
      /(?:INACTIVITY_)?TIMEOUT/,
      /HTTP_(?:USERNAME|PASSWORD)/,
      /TLS_(?:VERIFY|CAINFO)/,
      /NETRC(?:_FILE)/,
      /GIT_(?:REPOSITORY|TAG|REMOTE_(?:NAME|UPDATE_STRATEGY)|SUBMODULES(?:_RECURSE)?|SHALLOW|PROGRESS)/,
    ],
    options: ["EXCLUDE_FROM_ALL", "SYSTEM", "OVERRIDE_FIND_PACKAGE"],
    enums: [
      "IGNORED",
      "OPTIONAL",
      "REQUIRED",
      "CHECKOUT",
      /REBASE(?:_CHECKOUT)?/,
    ],
  },
);
