import { RuleConfigSeverity } from "@commitlint/types";

export default {
  extends: ["@commitlint/config-conventional"],
  defaultIgnores: true,
  rules: { "scope-case": [RuleConfigSeverity.Error, `always`, [`kebab-case`]] },
};
