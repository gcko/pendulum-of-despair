# TypeScript Monorepo Refactor — Design Document

**Date:** 2026-03-07
**Status:** Approved

## Goal

Convert the Pendulum of Despair JRPG scaffold from plain JavaScript to a strict-TypeScript pnpm workspace monorepo with modern tooling.

## Requirements

- Strict TypeScript (no `any` allowed) — latest version (5.8)
- Vitest for all testing (replace Jest)
- Node 24+ with `.naverc` set to `lts`
- pnpm via corepack as package manager
- Vite for client bundling (Phaser via npm, not CDN)
- Agent-friendly, strongly typed codebase

## Architecture

```
pendulum-of-despair/
├── .naverc
├── package.json              (root workspace)
├── pnpm-workspace.yaml
├── tsconfig.base.json
├── vitest.workspace.ts
└── packages/
    ├── shared/               @pendulum/shared — types & constants
    ├── server/               @pendulum/server — Express API
    └── client/               @pendulum/client — Phaser 3 + Vite
```

## Key Decisions

| Area | Choice | Rationale |
|------|--------|-----------|
| TypeScript | 5.8, `strict: true`, `noUncheckedIndexedAccess` | Maximum type safety |
| Module system | ESM everywhere | Modern standard, tree-shakeable |
| Server dev | `tsx --watch` | Fast TS execution without build step |
| Client build | Vite 6 | Fast HMR, native TS support, Phaser plugin ecosystem |
| Testing | Vitest workspace | Single config, Jest-compatible API, native ESM |
| Phaser | npm dependency | Proper types, tree-shaking potential, no CDN dependency |
| Package manager | pnpm 10 via corepack | Fast, strict, workspace support |
| Shared types | `@pendulum/shared` workspace package | Single source of truth for API contracts |

## Type Safety Approach

- Shared types for all API request/response contracts
- `AuthenticatedRequest` interface extending Express `Request`
- `node:sqlite` typed via `@types/node` (Node 24)
- `unknown` + type narrowing instead of `any`
- `resolveJsonModule` for importing JSON data files with type inference
