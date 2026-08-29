FROM hicder/docker_runner_base:latest
ARG TARGETARCH

RUN apt-get -y install openjdk-11-jdk maven \
		unzip byacc flex automake libtool binutils-dev \
		libiberty-dev bison
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-${TARGETARCH}

WORKDIR /
