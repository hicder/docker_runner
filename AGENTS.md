# AGENTS.md

## Overview

Docker-based build/run/dev environment for C++/Rust/Go projects. Containers run with host user UID/GID and source mounted at `/opt/src`.

## Scripts (run from repo root)

Containers are always Linux. `--platform` (same as Docker: `linux/amd64`, `linux/arm64`) selects the Linux architecture; default is `linux/<host-arch>`.

| Command | Purpose |
|---------|---------|
| `./build_base_image.sh` | Build base image (`docker/base/Dockerfile`, Ubuntu 26.04, clang-20, go1.24.5, rust nightly, nvim 0.11.3, ccache) |
| `./build_runtime_image.sh -p <project> -r <repo>` | Build `hicder/<project>_runtime:latest` from `docker/<project>/Dockerfile` |
| `./build_code.sh -p <project> -r <repo> -- "<cmd>"` | Run a build command in a throwaway container |
| `./dev.sh -p <project> -r <repo> -n <name>` | Start persistent dev container (VSCode Remote via SSH proxy) |

All of the above accept `--platform linux/amd64` or `--platform linux/arm64`.

## Build flow

`build_code.sh` creates a container, creates host-matching user inside it, symlinks `~/.cache/<repo>` into container home, then `exec`s the given command as the user.

## Dev container (dev.sh)

`dev.sh` starts a long-running container with `--network host` and `--cap-add SYS_PTRACE`. It symlinks host dirs for VS Code/Cursor/Windsurf/Antigravity server state, SSH authorized keys, gitconfig, cargo registry, and opencode/kilo config. SSH into the container via `docker exec` proxy for VSCode Remote Development.

## Extra docker args

Set `EXTRA_DOCKER_RUN_ARGS` env var before any script to pass additional `docker run` flags (e.g. `-e USE_AWS=1`).

## Container conventions

- Source: `/opt/src` (bind mount from host repo path)
- Host home: `/host_home`
- Cache: container `~/.cache` → `~/.cache/<repo>` on host
- User/group match host UID/GID
- `seccomp=unconfined` always set
- Projects: `docker/<project>/Dockerfile` — 23 projects (rocksdb, clickhouse, duckdb, tiflash, velox, etc.)
