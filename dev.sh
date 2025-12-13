#!/bin/bash

set -eu

args=$(getopt -o '+hr:p:n:' -l 'help,repo:,project:,container_name:' -- "$@")
eval set -- "$args"

set +e
read -r -d '' usage_str <<END
Usage:
  $0 [options...]

Entry-point for the RocksDB-Cloud test script.

Options:
  -h, --help               Help
  -r, --repo               Path to the repository
  -p, --project            Name for the project
  -n, --container_name     Container name to start
END
set -e

while :; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
          ;;
      -r|--repo)
          REPO="$2"
          shift
          ;;
      -p|--project)
          PROJECT="$2"
          shift
          ;;
      -n|--container_name)
          CONTAINER_NAME="$2"
          shift
          ;;
      --)
          shift
          break
          ;;
  esac
  shift
done

TAG=hicder/"$PROJECT"_runtime:latest
echo "Run with tag $TAG, project $PROJECT, container name $CONTAINER_NAME"

user=$(id -un)
user_id=$(id -u)
group=$(id -gn)
groupid=$(id -g)
container=$CONTAINER_NAME
SRC_ROOT=$REPO
: "${EXTRA_DOCKER_RUN_ARGS:=}"

# Check if container is already running
echo "Checking for container: $container"
if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
    echo "Container $container is already running, attaching to it"
    docker exec -it -u $user_id $container /bin/zsh
    exit 0
else
    echo "Container $container is not currently running"
fi

# Remove any stopped container with the same name
docker rm -f $container >/dev/null 2>/dev/null || true

CACHE_DIR=.cache/$REPO
mkdir -p $HOME/$CACHE_DIR

# Setup vscode things
mkdir -p ~/.vscode-docker-runner/$REPO
mkdir -p ~/tmp
mkdir -p ~/.gotools/$REPO/go/bin

setup=$(mktemp ~/tmp/setup-XXXXXX.sh)

docker run --security-opt seccomp=unconfined \
 -it --init -v $SRC_ROOT:/opt/src -w /opt/src \
 -d --name $container -v $HOME:/host_home --cap-add SYS_PTRACE $TAG bash

 cat > $setup <<EOF
#!/bin/bash -e

# Create user and group
groupadd -g $groupid $group || true
useradd -m -c '' -g $groupid -N -u $user_id -s /bin/zsh -d /home/$user $user || true

# Set up user directory, symlinking necessary files
cat <<EOF1 | sudo -u $user bash -e

cd /home/$user

mkdir .ssh
mkdir -p go
mkdir -p .local/share
ln -sf /host_home/.ssh/authorized_keys .ssh
ln -sf /host_home/.vscode-docker-runner/$REPO .vscode-server
ln -sf /host_home/.vscode-docker-runner/$REPO .vscode-server-insiders
ln -sf /host_home/.vscode-docker-runner/$REPO .cursor-server
ln -sf /host_home/.vscode-docker-runner/$REPO .windsurf-server
ln -sf /host_home/.vscode-docker-runner/$REPO .antigravity-server
ln -sf /host_home/.gitconfig .gitconfig
ln -sf /host_home/.config .config
ln -sf /host_home/$CACHE_DIR .cache
ln -sf /host_home/.local/share/opencode .local/share/opencode
ln -sf /host_home/.claude .claude

# Symlink cargo registry
ln -sf /host_home/.cargo/registry .cargo/registry

# Save all go binaries to host.
# We don't want to share go binaries between repos since some repos require older Go versions.
ln -sf /host_home/.gotools/$REPO/go/bin go

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

cd /opt/src

EOF
chmod 0755 $setup

# Run setup script
docker exec $container /host_home/tmp/$(basename $setup)

# docker attach $container
docker exec -it -e USER=$user -u $user_id $container /bin/zsh
