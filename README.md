# Docker Runner: Run your codes in Docker
These scripts help to create a Docker container to build, run your code, and start a long-running Docker container so that VSCode can utilize remote development.
## Requirements
* docker
* git
## Instructions
* Prepare the base image
```
# Either pull the prebuilt image
docker pull hicder/docker_runner_base:latest

# Or build it yourself
./build_base_image.sh
```
* Build the runtime image for your project. [project] needs to be under `docker/` directory
```
./build_runtime_image.sh -p [project]
```
* Build the code.
```
./build_code.sh -r [repo_path] -p [project] "mkdir build && cd build && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .. && ninja -j13"
```
Or, build a RocksDB-Cloud repo
```
EXTRA_DOCKER_RUN_ARGS="-e USE_AWS=1 -e PORTABLE=1 -e CFLAGS=-march=broadwell" ./build_code.sh -r /home/hieu/code/rocksdb-cloud -p rocksdb -- "make -j13 shared_lib"
```
* Start the container for VSCode
```
./dev.sh -r [repo_path] -p [project] -n [container_name]
```
Then, in your local SSH config, add the following. Replace `[user]` and `[ip_address]`
```
Host [container_name]
  HostName [container_name]
  User [user]
  ForwardAgent no
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ProxyCommand ssh [ip_address] docker exec -i [container_name] sshd -i
```

Now you can open an Remote Development session from VSCode, and clangd should work there.
