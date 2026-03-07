# Server Package Instructions (@pendulum/server)

## Overview

Express 5 REST API with JWT authentication and save game system. Uses `node:sqlite` (built-in Node 24+) for persistence.

## Architecture

```
packages/server/src/
  index.ts           # Entry point — starts HTTP server
  app.ts             # Express app setup (middleware, routes)
  db/                # Database initialization (node:sqlite)
  middleware/         # Auth middleware (JWT verification)
  routes/            # API route handlers
  __tests__/         # Vitest test suite
    setup.ts         # Test setup (in-memory DB)
```

## Key Patterns

### Express 5
- Uses Express 5 (`express@5.0.0`) — async error handling is built in
- Route handlers can be `async` without wrapper functions
- Errors thrown in async handlers are automatically caught

### Authentication
- Username + passphrase (bcrypt hashed)
- JWT tokens for session management
- No email required — simple game auth

### Database
- `node:sqlite` — built-in SQLite in Node.js 24+
- `:memory:` for tests, file-based for production
- Schema initialized on first connection

### Testing
- Vitest with supertest for HTTP assertions
- `setup.ts` initializes in-memory database before each test
- Environment variables: `DB_PATH=:memory:`, `JWT_SECRET=test-secret-key`

## Build & Run

```bash
pnpm run build:shared       # Must build shared types first
pnpm --filter @pendulum/server dev     # Development with hot reload (tsx)
pnpm --filter @pendulum/server test    # Run tests
pnpm --filter @pendulum/server run typecheck  # Type check
```

## Coding Standards

- Strict TypeScript — no `any` types
- ESM only (`type: "module"` in package.json)
- Import from `@pendulum/shared` for shared types
- All routes return typed JSON responses
- Error responses use `ApiError` type from shared
