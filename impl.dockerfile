FROM se0bi/hdlc-ghdl:yosys AS base

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    libboost-all-dev \
    libomp5-7 \
    make \
 && apt-get autoclean && apt-get clean && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists

#---

FROM base AS ice40

COPY --from=se0bi/hdlc-pkg:nextpnr-ice40 /nextpnr /

#---

FROM base AS ecp5

COPY --from=se0bi/hdlc-pkg:nextpnr-ecp5 /nextpnr /

#---

FROM base AS pnr

COPY --from=se0bi/hdlc-pkg:nextpnr-all /nextpnr /

#---

FROM ice40 AS icestorm

COPY --from=hdlc/pkg:icestorm /iceprog /
COPY --from=hdlc/pkg:icestorm /icestorm /

#---

FROM ecp5 AS prjtrellis

COPY --from=se0bi/hdlc-pkg:prjtrellis /prjtrellis /

#---

FROM pnr AS latest

COPY --from=hdlc/pkg:icestorm /iceprog /
COPY --from=hdlc/pkg:icestorm /icestorm /
COPY --from=se0bi/hdlc-pkg:prjtrellis /prjtrellis /
