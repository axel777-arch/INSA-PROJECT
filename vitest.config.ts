import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    setupFiles: ['tests/setup.ts'],
    // Auth integration tests share one database — run files sequentially.
    fileParallelism: false,
    testTimeout: 20000,
    hookTimeout: 20000,
  },
});
