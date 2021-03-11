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

docker rm -f $container >/dev/null 2>/dev/null || true

# Setup vscode things
mkdir -p ~/.vscode-docker-runner/$REPO
mkdir -p ~/tmp

setup=$(mktemp ~/tmp/setup-XXXXXX.sh)


docker run --security-opt seccomp=unconfined \
 -it --init -v $SRC_ROOT:/opt/src -w /opt/src \
 -d --name $container -v $HOME:/host_home --cap-add SYS_PTRACE $TAG bash

 cat > $setup <<EOF
#!/bin/bash -e

# Create user and group
groupadd -g $groupid $group
useradd -m -c '' -g $groupid -N -u $user_id -s /bin/bash -d /h $user

# Set up user directory in /h, symlinking necessary files
cat <<EOF1 | sudo -u $user bash -e

cd /h

mkdir .ssh
ln -sf /host_home/.ssh/authorized_keys .ssh
ln -sf /host_home/.vscode-docker-runner/$REPO .vscode-server
ln -sf /host_home/.vscode-docker-runner/$REPO .vscode-server-insiders
ln -sf /host_home/.gitconfig .gitconfig

touch .bashrc  # ensure owned by proper user

# gdb sometimes segfaults without "print static off"
cat <<EOF2 > .gdbinit
set print static off
set print pretty on
EOF2

EOF1

copy_var() {
    for arg in \$*; do
        if [[ -v \$arg ]]; then
            declare -pg \$arg
        fi
    done
}

copy_var \
    PATH \
    RS_ROOT \
    GOPATH \
    LSAN_OPTIONS \
    >> /h/.bashrc

cd /opt/src

EOF
chmod 0755 $setup

# Run setup script
docker exec $container /host_home/tmp/$(basename $setup)
docker attach $container
