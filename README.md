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
* Build the code
```
./build.sh -j 4 -r /home/hieu/code/rocksdb-cloud -i docker_runner_base:latest "make -j 4"
```
* Start the container for VSCode
  * In your remote server
```
./dev.sh -r /home/hieu/code/rocksdb-cloud -i docker_runner_test:latest -n name1
```
  * Then, in your local SSH config, add the following. Replace [user] and [ip_address]
```
Host docker-runner
  HostName docker-runner
  User [user]
  ForwardAgent no
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ProxyCommand ssh [ip_address] docker exec -i name1 sshd -i
```