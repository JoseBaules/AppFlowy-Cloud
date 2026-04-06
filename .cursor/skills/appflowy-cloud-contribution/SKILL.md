---
name: appflowy-cloud-contribution
description: >-
  Implements and reviews changes in the AppFlowy Cloud Rust monorepo: Actix API
  scopes, biz layer, libs workspace crates, SQLx migrations, and local Docker
  workflow. Use when adding or modifying endpoints, database schema, auth,
  collaboration, worker jobs, admin UI, running ./script/run_local_server.sh,
  or preparing PRs that must pass cargo fmt and clippy -D warnings.
---

# AppFlowy Cloud — contribution workflow

## Before coding

1. Read **`doc/GUIDE.md`** for directory roles and deployed URL paths (`/api`, `/ws`, `/gotrue`, `/console`).
2. Follow **`doc/CONTRIBUTING.md`**: `cargo fmt`, `cargo clippy -- -D warnings`, `cargo test`.
3. Env: use **`./script/generate_env.sh`**; secrets in `.env.*.secret` — never commit real secrets.

## Adding or changing an HTTP API

1. **Handler module** in `src/api/<feature>.rs`: implement `pub fn <feature>_scope() -> Scope` with `web::scope("/api/...")` and thin handlers calling `crate::biz::...`.
2. **Business logic** in `src/biz/<area>/` — orchestration, DB calls via pools/repos from `AppState`.
3. **Register** the scope in **`src/application.rs`** (`.service(<feature>_scope())`).
4. **Types**: reuse **`database_entity`**, **`shared_entity`**, and **`app_error::AppError`** / **`AppResponse`** patterns — avoid ad-hoc JSON shapes in handlers.

## Database

- Migrations: **`migrations/`** SQL files; follow existing naming and SQLx workflow used in the repo.
- If the change needs compile-time checked queries, respect **SQLx offline** (`.sqlx/`) and project scripts (`run_local_server.sh` flags like `--sqlx` when a full prepare is required).

## Workspace crates

- Put reusable types/clients in **`libs/<name>`** and declare the member in root **`Cargo.toml` `[workspace].members`** if adding a new crate.
- Wire dependencies through **`[workspace.dependencies]`** when that matches existing crates.

## Services

- **`services/appflowy-collaborate`**: realtime / WebSocket collaboration — integrated from main app; do not fork protocol handling in `src/api/` without a strong reason.
- **`services/appflowy-worker`**: background import/indexer/email-related work — use for long-running or queued tasks.

## Tests

- Integration-style tests under **`tests/<area>/`** — mirror patterns for `client-api`, DB fixtures, and assets already present in sibling test dirs.

## Quick verification commands

```bash
cargo fmt --all -- --check
cargo clippy -- -D warnings
cargo test
```

Use **`./script/run_local_server.sh`** (options `--reset`, `--sqlx` documented in `README.md`) for full local stack with Docker dependencies. Project scripts use **`docker-compose`** when available (see `script/docker_compose.sh`), falling back to **`docker compose`**.
