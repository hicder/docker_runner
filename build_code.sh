#!/bin/bash

set -eu

_script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
. "$_script_dir/common.sh"

usage_str="Usage:
  $0 [options...]

Entry-point for the RocksDB-Cloud test script.
Use env EXTRA_DOCKER_RUN_ARGS to add to docker command

Options:
  -h, --help               Help
  -r, --repo               Path to repositories
  -p, --project            Project name
      --platform           Target platform (default: linux/<host-arch>)
"

PLATFORM=""

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

: "${EXTRA_DOCKER_RUN_ARGS:=}"

SRC_ROOT=$REPO
TAG=hicder/"$PROJECT"_runtime:latest
echo "Run repo $SRC_ROOT, tag $TAG"
echo "Remaining is $@"

echo $EXTRA_DOCKER_RUN_ARGS
echo "home is /home/$USER"

user=$(id -un)
user_id=$(id -u)
group=$(id -gn)
groupid=$(id -g)
CONTAINER=$(echo $RANDOM)

# Setup cache directory
CACHE_DIR=.cache/$REPO
mkdir -p $HOME/$CACHE_DIR

# Run the build in `build` directory
docker_with_platform run --security-opt seccomp=unconfined \
 -it --init -v $SRC_ROOT:/opt/src -w /opt/src \
 -d --name $CONTAINER -v $HOME:/host_home --cap-add SYS_PTRACE $TAG bash

setup=$(make_setup_script)
 cat > $setup <<EOF
#!/bin/bash -e

# Create user and group
groupadd -g $groupid $group || true
useradd -m -c '' -g $groupid -N -u $user_id -s /bin/bash -d /home/$user $user || true

cat <<EOF1 | sudo -u $user bash -e
cd /home/$user
ln -s /host_home/$CACHE_DIR .cache
EOF1

EOF
chmod 0755 $setup

docker exec $CONTAINER /host_home/tmp/$(basename $setup)

echo "Setup is complete"

# docker run -v $SRC_ROOT:/opt/src -w /opt/src -u $UID $EXTRA_DOCKER_RUN_ARGS -e HOME=/home/$USER --rm $TAG /bin/bash -c "$@"

docker exec -u $user_id $CONTAINER /bin/bash -c "$@"
