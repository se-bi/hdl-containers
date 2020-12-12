#!/usr/bin/env sh

set -e

cd $(dirname "$0")

echo "CC: $CC"
echo "CXX: $CXX"

./smoke-tests/prjtrellis.sh

for t in \
  ecpbram \
  ecpmulti \
  ecppack \
  ecppll \
  ecpunpack
do
  which $t
  $t -h | head -n 5
  echo -e "$?\n\n\n"
done

ecppack --version
