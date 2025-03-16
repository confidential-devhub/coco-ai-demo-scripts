#! /bin/bash

set -ex

REPO=${REPO:-"quay.io/eesposit"}
IMAGE=${IMAGE:-"kserve-storage-initializer"}
TAG=${TAG:-"latest"}

cd ../fenc
./compile.sh
cd -

cp ../fenc/fenc .

docker build -t $REPO/$IMAGE:$TAG . --no-cache
docker push $REPO/$IMAGE:$TAG

rm -f fenc
