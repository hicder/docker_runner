FROM hicder/docker_runner_base:latest

ARG group_id
ARG group
ARG user_id
ARG user

RUN echo "$user"
RUN echo "$user_id"
RUN echo "$group"
RUN echo "$group_id"

RUN groupadd -g $group_id $group
RUN useradd -m -c '' -g $group_id -N -u $user_id -s /bin/bash -d /home/$user $user

USER $user

ENV RUSTUP_HOME /home/hieu/.rustup
ENV CARGO_HOME /home/hieu/.cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain nightly
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

USER root
RUN apt install -y pkg-config

WORKDIR /
