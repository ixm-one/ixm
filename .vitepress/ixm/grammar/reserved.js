import { Group, EntrySet, Entry } from "./group";

class ReservedCommandSet extends EntrySet {
  constructor({ name, command, ...methods }) {
    command ??= `cmake_${name.replaceAll(".", "_")}`;
    super({
      category: "reserved",
      command,
      name,
      ...methods,
    });
  }
}

class ReservedCommand extends Entry {
  constructor({ name, command, ...values }) {
    command ??= `cmake_${name.replaceAll(".", "_")}`;
    super({
      category: "reserved",
      command,
      name,
      ...values,
    });
  }
}

export default new Group(
  { category: "reserved", type: ReservedCommandSet },
  {
    name: "file.api",
    query: {
      variadic: ["CODEMODEL", "CACHE", "CMAKEFILES", "TOOLCHAINS"],
      monadic: "API_VERSION",
    },
  },
  {
    name: "language",
    get_message_log_level: null,
    call: null,
    exit: null,
    eval: { operators: "CODE" },
    defer: {
      operators: ["GET_CALL_IDS", /(?:(?:GET|CANCEL)_)?CALL/],
      monadic: ["DIRECTORY", /ID(?:_VAR)?/],
    },
    set_dependency_provider: {
      monadic: "SUPPORTED_METHODS",
      enums: ["FETCHCONTENT_MAKEAVAILABLE_SERIAL", "FIND_PACKAGE"],
    },
  },
  {
    name: "minimum_required",
    version: null,
  },
  { name: "parse_arguments", parse_argv: null, "": null },
  {
    name: "policy",
    version: null,
    get: null,
    set: { enums: ["NEW", "OLD"] },
    push: null,
    pop: null,
  },
  new ReservedCommand({
    name: "host.system.information",
    operators: ["QUERY", "WINDOWS_REGISTRY"],
    monadic: [
      "RESULT",
      /VALUE(?:_NAMES)?/,
      "SUBKEYS",
      "SEPARATOR",
      "ERROR_VARIABLE",
    ],
    enums: [
      /64(?:_32)?/,
      /32(?:_64)?/,
      "HOST",
      "TARGET",
      "BOTH",
      "FQDN",
      "HOSTNAME",
      "IS_64BIT",
      "MSYSTEM_PREFIX",
      /(?:TOTAL|AVAILABLE)_(?:VIRTUAL|PHYSICAL)_MEMORY/,
      /DISTRIB_\w+/,
      /HAS_(?:AMD_3DNOW(?:_PLUS)?|FPU|IA64|MMX(?:_PLUS)?|SERIAL_NUMBER|SSE(?:2|_(?:FP|MMX)?)?)/,
      /NUMBER_OF_(?:LOG|PHYS)ICAL_CORES/,
      /OS_(?:NAME|RELEASE|VERSION|PLATFORM)/,
      /PROCESSOR_(?:SERIAL_NUMBER|NAME|DESCRIPTION)/,
    ],
  }),
);
