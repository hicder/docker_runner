# Docker Runner: Run your codes in Docker
These scripts help to create a Docker container to build, run your code, and start a long-running Docker container so that VSCode can utilize remote development.
## Requirements
* docker
* git
## Instructions
* Build the base image
```
./build_base_image.sh
```
* Tag with the right tag
```
docker tag docker_runner_base:latest hicder/docker_runner_base:latest
```
* Build the runtime image for your project
```
docker build -t clickhouse_runtime:latest docker/clickhouse
```
* Build the code. I will use Clickhouse as an example.
```
./build.sh -j 4 -r /home/hieu/code/Clickhouse -i clickhouse_runtime:latest "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .. && ninja -j13"
```
* Start the container for VSCode
In your remote server. I'll name this container `container_name1`
```
./dev.sh -r /home/hieu/code/rocksdb-cloud -i docker_runner_test:latest -n container_name1
```
Then, in your local SSH config, add the following. Replace `[user]` and `[ip_address]`
```
Host docker-runner
  HostName docker-runner
  User [user]
  ForwardAgent no
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ProxyCommand ssh [ip_address] docker exec -i container_name1 sshd -i
```

Now you can open an Remote Development session from VSCode, and clangd should work there.
