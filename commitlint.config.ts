export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "scope-enum": [
      2,
      "always",
      ["client", "server", "shared", "ci", "deps"],
    ],
  },
};
