FROM hdlc/build:base AS build

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    clang \
    git \
    make

ENV CC clang
ENV CXX clang++

#---

FROM build

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    cmake \
    libboost-all-dev \
    python3-dev
