# Docker Runner: Run your codes in Docker
These scripts help to create a Docker container to build, run your code, and start a long-running Docker container so that VSCode can utilize remote development.

Containers are always **Linux**. The host can be Linux x86_64 or macOS Apple Silicon; `--platform` selects the Linux architecture (`linux/amd64` or `linux/arm64`), same as Docker.

## Requirements
* docker
* git
## Instructions
* Prepare the base image
```
# Either pull the prebuilt image
docker pull hicder/docker_runner_base:latest

# Or build it yourself (defaults to linux/<host-arch>)
./build_base_image.sh

# Cross-build / emulate the other Linux arch
./build_base_image.sh --platform linux/amd64
./build_base_image.sh --platform linux/arm64
```
* Build the runtime image for your project. [project] needs to be under `docker/` directory
```
./build_runtime_image.sh -p [project] -r [repo_path]
./build_runtime_image.sh -p [project] -r [repo_path] --platform linux/arm64
```
* Build the code.
```
./build_code.sh -r [repo_path] -p [project] -- "mkdir build && cd build && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .. && ninja -j13"
```
Or, build a RocksDB-Cloud repo
```
EXTRA_DOCKER_RUN_ARGS="-e USE_AWS=1 -e PORTABLE=1 -e CFLAGS=-march=broadwell" ./build_code.sh -r /home/hieu/code/rocksdb-cloud -p rocksdb -- "make -j13 shared_lib"
```
* Start the container for VSCode
```
./dev.sh -r [repo_path] -p [project] -n [container_name] --ssh-port [port]
./dev.sh -r [repo_path] -p [project] -n [container_name] --ssh-port 2222 --platform linux/amd64
```
`--ssh-port` publishes the container's SSH server on the specified host port. Then,
in your local SSH config, add the following. Replace `[user]`, `[ip_address]`, and
`[port]` with the container user, Docker host address, and the port passed to
`--ssh-port`, respectively. Use `localhost` for `[ip_address]` when Docker runs on
your local machine.
```
Host [container_name]
  HostName [ip_address]
  Port [port]
  User [user]
  ForwardAgent no
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

Now you can open an Remote Development session from VSCode, and clangd should work there.

## Platform

`--platform` is the same flag as Docker (`linux/amd64`, `linux/arm64`). If omitted, scripts default to `linux/amd64` on x86_64 hosts and `linux/arm64` on ARM hosts (including Apple Silicon). Use the same `--platform` for build and run so the image architecture matches the container.

On a Mac, `linux/arm64` is native; `linux/amd64` runs through Docker's emulator.
