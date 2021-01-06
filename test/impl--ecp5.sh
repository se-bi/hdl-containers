#!/usr/bin/env sh

set -e

cd $(dirname "$0")

./ghdl.sh
./yosys.sh
./nextpnr--ecp5.sh
