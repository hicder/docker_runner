FROM hicder/docker_runner_base:latest

WORKDIR /ax-install
RUN git clone -q --single-branch --recursive --branch 1.11.105 https://github.com/aws/aws-sdk-cpp.git
WORKDIR /ax-install/aws-install
RUN cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTING=OFF '-DBUILD_ONLY=kinesis;core;s3;transfer' ../aws-sdk-cpp/
RUN make -j 8 && make install

WORKDIR /ax-install
ENV LIBRDKAFKA_VERSION=0.11.3
RUN wget https://github.com/edenhill/librdkafka/archive/v${LIBRDKAFKA_VERSION}.tar.gz
RUN tar -zxvf v${LIBRDKAFKA_VERSION}.tar.gz
WORKDIR /ax-install/librdkafka-${LIBRDKAFKA_VERSION}
RUN ./configure && make && make install

RUN ldconfig

WORKDIR /
