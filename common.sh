#!/bin/bash
# Shared helpers for docker_runner scripts.
# Containers are always Linux; --platform selects linux/amd64 or linux/arm64.

# Maps host uname -m to a Docker Linux platform.
default_linux_platform() {
  case "$(uname -m)" in
    x86_64|amd64) echo "linux/amd64" ;;
    aarch64|arm64) echo "linux/arm64" ;;
    *)
      echo "Unsupported host architecture: $(uname -m) (expected x86_64 or arm64)" >&2
      exit 1
      ;;
  esac
}

# Sets PLATFORM to --platform override, or host-matching linux/*.
resolve_platform() {
  if [ -z "${PLATFORM:-}" ]; then
    PLATFORM="$(default_linux_platform)"
  fi
  echo "Platform: $PLATFORM"
}

# docker build|run with --platform. Usage: docker_with_platform build [args...]
docker_with_platform() {
  local cmd="$1"
  shift
  docker "$cmd" --platform "$PLATFORM" "$@"
}

# AMD GPU devices when present (Linux hosts). Empty on Mac / machines without them.
gpu_device_args() {
  local out=""
  if [ -e /dev/kfd ]; then
    out="$out --device=/dev/kfd"
  fi
  if [ -e /dev/dri ]; then
    out="$out --device=/dev/dri --group-add=video"
  fi
  echo "${out# }"
}

# Setup script in $HOME/tmp so the container can exec it via /host_home.
# BSD mktemp (macOS) requires the X's at the end of the template.
make_setup_script() {
  mkdir -p "$HOME/tmp"
  mktemp "$HOME/tmp/setup.XXXXXX"
}

# BuildKit exposes TARGETARCH for multi-arch Dockerfiles.
export DOCKER_BUILDKIT=1
