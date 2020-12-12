#!/usr/bin/env sh

set -e

cd $(dirname "$0")

echo "CC: $CC"
echo "CXX: $CXX"

./smoke-tests/nextpnr-ecp5.sh

nextpnr-ecp5 --version
