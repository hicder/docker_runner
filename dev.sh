#!/bin/bash

set -eu

_script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
. "$_script_dir/common.sh"

usage_str="Usage:
  $0 [options...]

Entry-point for the RocksDB-Cloud test script.

Options:
  -h, --help               Help
  -r, --repo               Path to the repository
  -p, --project            Name for the project
  -n, --container_name     Container name to start
      --ssh-port           Host port to bind to container port 22
      --platform           Target platform (default: linux/<host-arch>)
"

PLATFORM=""
SSH_PORT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
          ;;
      -r|--repo)
          REPO="$2"
          shift 2
          ;;
      --repo=*)
          REPO="${1#*=}"
          shift
          ;;
      -p|--project)
          PROJECT="$2"
          shift 2
          ;;
      --project=*)
          PROJECT="${1#*=}"
          shift
          ;;
      -n|--container_name)
          CONTAINER_NAME="$2"
          shift 2
          ;;
      --container_name=*)
          CONTAINER_NAME="${1#*=}"
          shift
          ;;
      --ssh-port)
          SSH_PORT="$2"
          shift 2
          ;;
      --ssh-port=*)
          SSH_PORT="${1#*=}"
          shift
          ;;
      --platform)
          PLATFORM="$2"
          shift 2
          ;;
      --platform=*)
          PLATFORM="${1#*=}"
          shift
          ;;
      --)
          shift
          break
          ;;
      -*)
          echo "Unknown option: $1" >&2
          echo "$usage_str" >&2
          exit 1
          ;;
      *)
          break
          ;;
  esac
done

resolve_platform

if [[ ! "$SSH_PORT" =~ ^[0-9]+$ ]] || (( SSH_PORT < 1 || SSH_PORT > 65535 )); then
    echo "--ssh-port must be an integer between 1 and 65535" >&2
    echo "$usage_str" >&2
    exit 1
fi

TAG=hicder/"$PROJECT"_runtime:latest
echo "Run with tag $TAG, project $PROJECT, container name $CONTAINER_NAME"

user=$(id -un)
user_id=$(id -u)
group=$(id -gn)
groupid=$(id -g)
container=$CONTAINER_NAME
SRC_ROOT=$REPO
REPO_NAME=$(basename -- "${SRC_ROOT%/}")
CONTAINER_SRC=/opt/src/$REPO_NAME
: "${EXTRA_DOCKER_RUN_ARGS:=}"

# Start sshd in the container unless it is already running, so VSCode Remote can connect.
ensure_sshd() {
    if docker exec "$container" pgrep -x sshd >/dev/null 2>&1; then
        echo "sshd is already running in $container"
        return 0
    fi

    echo "Starting sshd in $container"
    # ssh-keygen -A only creates host keys that are missing.
    docker exec "$container" bash -c 'mkdir -p /run/sshd && ssh-keygen -A >/dev/null'
    docker exec -d "$container" /usr/sbin/sshd -D

    for _ in 1 2 3 4 5 6 7 8 9 10; do
        if docker exec "$container" pgrep -x sshd >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.2
    done

    echo "Warning: sshd did not come up in $container" >&2
}

# Check if container is already running
echo "Checking for container: $container"
if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
    echo "Container $container is already running, attaching to it"
    ensure_sshd
    docker exec -it -e USER=$user -u $user_id $container /bin/zsh
    exit 0
elif docker ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
    echo "Container $container exists but is stopped. Starting and attaching..."
    docker start $container
    ensure_sshd
    docker exec -it -e USER=$user -u $user_id $container /bin/zsh
    exit 0
else
    echo "Container $container is not currently running and does not exist"
fi

# Remove any stopped container with the same name
docker rm -f $container >/dev/null 2>/dev/null || true

CACHE_DIR=.cache/$REPO
mkdir -p $HOME/$CACHE_DIR

# Setup vscode things
mkdir -p ~/.vscode-docker-runner/$REPO
mkdir -p ~/tmp
mkdir -p ~/.gotools/$REPO/go/bin

# Conan caches are Linux-specific; skip on Mac so we don't share them with the container.
CONAN_LINKS=""
if [[ "$(uname -s)" != "Darwin" ]]; then
    mkdir -p ~/.conan-docker-runner/$REPO
    mkdir -p ~/.conan2-docker-runner/$REPO
    CONAN_LINKS="ln -sf /host_home/.conan-docker-runner/$REPO .conan
ln -sf /host_home/.conan2-docker-runner/$REPO .conan2"
fi

setup=$(make_setup_script)

SSH_AGENT_ARGS=()
if [[ -n "${SSH_AUTH_SOCK:-}" && -S "$SSH_AUTH_SOCK" ]]; then
    SSH_AGENT_ARGS=(-v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent)
fi

docker_with_platform run --security-opt seccomp=unconfined \
 $(gpu_device_args) \
 "${SSH_AGENT_ARGS[@]}" \
 -it --init -v "$SRC_ROOT:$CONTAINER_SRC" -w "$CONTAINER_SRC" \
 -d --name $container -p "$SSH_PORT:22" -v $HOME:/host_home --cap-add SYS_PTRACE $TAG bash

 cat > $setup <<EOF
#!/bin/bash -e

# Create user and group
groupadd -g $groupid $group || true
useradd -m -c '' -g $groupid -N -u $user_id -s /bin/zsh -d /home/$user -G sudo $user || true

# Set up user directory, symlinking necessary files
cat <<EOF1 | sudo -u $user bash -e

cd /home/$user

mkdir .ssh || true
mkdir -p go || true
mkdir -p .local/share || true
ln -sf /host_home/.ssh/authorized_keys .ssh/authorized_keys
ln -sf /host_home/.vscode-docker-runner/$REPO .vscode-server
ln -sf /host_home/.vscode-docker-runner/$REPO .vscode-server-insiders
ln -sf /host_home/.vscode-docker-runner/$REPO .cursor-server
ln -sf /host_home/.vscode-docker-runner/$REPO .windsurf-server
ln -sf /host_home/.vscode-docker-runner/$REPO .antigravity-server
ln -sf /host_home/.gitconfig .gitconfig
ln -sf /host_home/$CACHE_DIR .cache
ln -sf /host_home/.local/share/opencode .local/share/opencode
ln -sf /host_home/.local/share/kilo .local/share/kilo
ln -sf /host_home/.claude/settings.json .claude/settings.json || true
$CONAN_LINKS

# Symlink a few configs
mkdir -p .config
ln -sf /host_home/.config/opencode .config/opencode
ln -sf /host_home/.config/kilo .config/kilo
ln -sf /host_home/.config/nvim .config/nvim

# Symlink cargo registry
ln -sf /host_home/.cargo/registry .cargo/registry

# Set hasCompletedOnboarding to true in .claude.json
(jq '. + {"hasCompletedOnboarding": true}' .claude.json > .claude.json.tmp && mv .claude.json.tmp .claude.json) || true

touch .bashrc  # ensure owned by proper user

# gdb sometimes segfaults without "print static off"
cat <<EOF2 > .gdbinit
set print static off
set print pretty on
EOF2

# Create .gitignore file
cat <<EOF2 > .gitignore
.aider*
.augmentignore
scratch/
.clangd
.vscode
.opencode
OpenCode.md
t[0-9].json
uv.lock
.devcontainer
build
.cache
EOF2

# Configure git to use the global gitignore
git config --global core.excludesfile ~/.gitignore

EOF1

copy_var() {
    for arg in \$*; do
        if [[ -v \$arg ]]; then
            declare -pg \$arg
        fi
    done
}

copy_var \
    RS_ROOT \
    GOPATH \
    LSAN_OPTIONS \
    >> /home/$user/.bashrc

cd "$CONTAINER_SRC"

EOF
chmod 0755 $setup

# Run setup script
docker exec $container /host_home/tmp/$(basename $setup)

ensure_sshd

# docker attach $container
docker exec -it -e USER=$user -u $user_id $container /bin/zsh
