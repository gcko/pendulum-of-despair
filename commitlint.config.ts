export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "docs",
        "style",
        "refactor",
        "test",
        "chore",
        "build",
        "perf",
        "revert",
        "ci",
      ],
    ],
    "scope-enum": [
      2,
      "always",
      ["client", "server", "shared", "ci", "deps"],
    ],
  },
};
