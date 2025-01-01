import markdown from "@eslint/markdown";
import json from "@eslint/json";
import js from "@eslint/js";

import prettier from "eslint-config-prettier";
import globals from "globals";

/** @type {import('eslint').Linter.Config[]} */
export default [
  ...markdown.configs.recommended,
  { ignores: ["node_modules/**", ".vitepress/{dist,cache}/**"] },
  { languageOptions: { globals: globals.browser } },
  { files: ["**/*.js"], ...js.configs.recommended },
  {
    files: ["**/*.md"],
    language: `markdown/gfm`,
    rules: { "markdown/no-missing-label-refs": `off` },
  },
  {
    files: ["**/*.json"],
    ignores: ["package-lock.json"],
    language: `json/json`,
    ...json.configs.recommended,
  },
  prettier,
];
