import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    setupFiles: ["src/__tests__/setup.ts"],
    include: ["src/__tests__/**/*.test.ts"],
    fileParallelism: false,
    env: {
      DB_PATH: ":memory:",
      JWT_SECRET: "test-secret-key",
    },
  },
});
