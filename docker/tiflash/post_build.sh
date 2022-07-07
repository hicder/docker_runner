#!/bin/bash -e

curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain nightly
source $HOME/.cargo/env
