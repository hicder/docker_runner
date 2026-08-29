FROM hicder/docker_runner_base:latest
ARG TARGETARCH

RUN apt-get install -y autoconf

WORKDIR /tmp
RUN wget https://golang.org/dl/go1.16.8.linux-${TARGETARCH}.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.8.linux-${TARGETARCH}.tar.gz

WORKDIR /
