#! /bin/bash

set -ex

KS=${KS:-"kserve-storage-initializer"}
TAG=${TAG:-"gpu-attest12"}

REPO=${REPO:-"quay.io/eesposit"}


docker_build_and_push() {
	NAME=$1
	FOLDER=$NAME
	Dockerfile=$NAME.Dockerfile
	IMAGE=$NAME

	docker build -t $REPO/$IMAGE:$TAG -f $Dockerfile . # --no-cache
	docker push $REPO/$IMAGE:$TAG
}

cp ../fenc .
docker_build_and_push $KS
rm fenc