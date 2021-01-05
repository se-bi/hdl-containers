FROM se0bi/hdlc-build:dev AS build-aptrequirements

ENV LDFLAGS "-Wl,--copy-dt-needed-entries"

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    libeigen3-dev \
    libomp-dev

#---

FROM build-aptrequirements AS build-gitfetch

RUN git clone https://github.com/YosysHQ/nextpnr.git /tmp/nextpnr \
 && mkdir /tmp/nextpnr/build/

#---

FROM build-gitfetch AS build-ice40
COPY --from=hdlc/pkg:icestorm /icestorm/usr/local/share/icebox /usr/local/share/icebox

RUN cd /tmp/nextpnr/build \
 && cmake .. \
   -DARCH=ice40 \
   -DBUILD_GUI=OFF \
   -DBUILD_PYTHON=ON \
   -DUSE_OPENMP=ON \
 && make -j $(nproc) \
 && make DESTDIR=/opt/nextpnr install

#---

FROM build-gitfetch AS build-ecp5
COPY --from=se0bi/hdlc-pkg:prjtrellis /prjtrellis /

RUN cd /tmp/nextpnr/build \
 && cmake .. \
   -DARCH=ecp5 \
   -DBUILD_GUI=OFF \
   -DBUILD_PYTHON=ON \
   -DUSE_OPENMP=ON \
 && make -j $(nproc) \
 && make DESTDIR=/opt/nextpnr install

#---

FROM build-ice40 AS build-all
COPY --from=se0bi/hdlc-pkg:prjtrellis /prjtrellis /

RUN cd /tmp/nextpnr/build \
 && cmake .. \
   -DARCH=all \
   -DBUILD_GUI=OFF \
   -DBUILD_PYTHON=ON \
   -DUSE_OPENMP=ON \
 && make -j $(nproc) \
 && make DESTDIR=/opt/nextpnr install

#---

FROM hdlc/build:base AS base

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    libboost-all-dev \
    libomp5-7 \
 && apt-get autoclean && apt-get clean && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/*

#---

FROM base AS ice40
COPY --from=build-ice40 /opt/nextpnr /

#---

FROM scratch AS pkg-ice40
COPY --from=build-ice40 /opt/nextpnr /nextpnr

#---

FROM base AS ecp5
COPY --from=build-ecp5 /opt/nextpnr /

#---

FROM scratch AS pkg-ecp5
COPY --from=build-ecp5 /opt/nextpnr /nextpnr

#---

FROM base AS all
COPY --from=build-all /opt/nextpnr /

#---

FROM base AS pkg-all
COPY --from=build-all /opt/nextpnr /nextpnr
