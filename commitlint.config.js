import { RuleConfigSeverity } from "@commitlint/types";

const scopes = [`actions`, `cmake`, `docs`, `package`, `tool`];

export default {
  extends: ["@commitlint/config-conventional"],
  defaultIgnores: true,
  rules: {
    "subject-case": [RuleConfigSeverity.Error, `always`, [`lower-case`]],
    "scope-case": [RuleConfigSeverity.Error, `always`, [`kebab-case`]],
    "scope-enum": [RuleConfigSeverity.Error, `always`, scopes],
  },
};
