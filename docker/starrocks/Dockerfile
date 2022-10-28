FROM hicder/docker_runner_base:latest

RUN apt-get -y install openjdk-11-jdk
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
RUN apt-get -y install maven
RUN apt-get -y install unzip
RUN apt-get -y install byacc
RUN apt-get -y install flex
RUN apt-get -y install automake
RUN apt-get -y install libtool binutils-dev libiberty-dev bison
RUN apt-get -y install clang-14

ENV CXX clang++14
ENV CC clang-14

WORKDIR /
