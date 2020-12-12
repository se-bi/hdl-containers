#!/usr/bin/env sh

set -e

cd $(dirname "$0")

echo "CC: $CC"
echo "CXX: $CXX"

./smoke-tests/icestorm.sh

for t in \
  icebox_asc2hlc \
  icebox_chipdb \
  icebox_colbuf \
  icebox_diff \
  icebox_explain \
  icebox_hlc2asc \
  icebox_html \
  icebox_maps \
  icebox_stat \
  icebox_vlog \
  icebram \
  icemulti \
  icepack \
  icepll \
  icetime \
  iceunpack
do
  which $t
  $t -h | head -n 5
  echo -e "$?\n\n\n"
done
