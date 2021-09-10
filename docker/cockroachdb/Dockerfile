FROM hicder/docker_runner_base:latest

RUN apt-get install -y autoconf

WORKDIR /tmp
RUN wget https://golang.org/dl/go1.16.8.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.8.linux-amd64.tar.gz

WORKDIR /
