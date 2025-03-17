import { RuleConfigSeverity } from "@commitlint/types";

export default {
  extends: ["@commitlint/config-conventional"],
  defaultIgnores: true,
  rules: {
    "subject-case": [RuleConfigSeverity.Error, `always`, [`lower-case`]],
    "scope-case": [RuleConfigSeverity.Error, `always`, [`kebab-case`]],
  },
};
