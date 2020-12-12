FROM hdlc/yosys AS base

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    git \
    libgnat-8 \
 && apt-get autoclean && apt-get clean && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists

#---

FROM base AS plugin

COPY --from=hdlc/pkg:ghdl /ghdl /opt/ghdl

RUN git clone https://github.com/ghdl/ghdl-yosys-plugin.git /tmp/ghdl-yosys-plugin

RUN cp -vr /opt/ghdl/* / \
 && cd /tmp/ghdl-yosys-plugin \
 && make \
 && cp ghdl.so /opt/ghdl/usr/local/lib/ghdl_yosys.so

#---

FROM hdlc/pkg:ghdl AS pkg

COPY --from=plugin /opt/ghdl/usr/local/lib/ghdl_yosys.so /ghdl/usr/local/lib/ghdl_yosys.so

#---

FROM base

COPY --from=pkg /ghdl /

RUN yosys-config --exec mkdir -p --datdir/plugins \
 && yosys-config --exec ln -s /usr/local/lib/ghdl_yosys.so --datdir/plugins/ghdl.so
