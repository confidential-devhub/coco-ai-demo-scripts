#! /bin/bash

set -ex

KS=${KS:-"text-generation-launcher"}
TAG=${TAG:-"model-encrypted"}

REPO=${REPO:-"quay.io/eesposit"}


docker_build_and_push() {
	NAME=$1
	FOLDER=$NAME
	IMAGE=$NAME

	docker build -t $REPO/$IMAGE:$TAG . --no-cache
	docker push $REPO/$IMAGE:$TAG
}

docker_build_and_push $KS