import { RuleConfigSeverity } from "@commitlint/types";

export default {
  extends: ["@commitlint/config-conventional"],
  defaultIgnores: true,
  rules: {
    "subject-case": [RuleConfigSeverity.Error, `always`, [`sentence-case`]],
    "scope-case": [RuleConfigSeverity.Error, `always`, [`kebab-case`]],
    "scope-enum": [
      RuleConfigSeverity.Error,
      `always`,
      [`actions`, `github`, `cmake`, `docs`, `renovate`, `config`],
    ],
  },
};
