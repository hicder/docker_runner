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
./build_runtime_image.sh -n [project]
```
* Build the code. I will use Clickhouse as an example.
```
./build_code.sh -j 4 -r [repo_path] -i clickhouse_runtime:latest "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .. && ninja -j13"
```
* Start the container for VSCode
```
./dev.sh -r [repo_path] -n [project]
```
Then, in your local SSH config, add the following. Replace `[user]` and `[ip_address]`
```
Host docker-runner-[project]
  HostName docker-runner-[project]
  User [user]
  ForwardAgent no
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ProxyCommand ssh [ip_address] docker exec -i docker-runner-[project] sshd -i
```

Now you can open an Remote Development session from VSCode, and clangd should work there.
