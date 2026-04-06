#!/usr/bin/env bash
# Prefer Docker Compose v2 (`docker compose`); fall back to legacy docker-compose v1 only if needed.
# v1 (e.g. 1.29.x) can fail on newer Docker Engine with KeyError: 'ContainerConfig' when recreating containers.
# Sourced by run_local_server.sh, run_ci_server.sh, etc.

docker_compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    echo "Error: Install the Docker Compose v2 plugin (docker compose) or docker-compose." >&2
    return 1
  fi
}
