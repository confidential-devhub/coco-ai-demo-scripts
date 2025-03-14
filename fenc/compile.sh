#! /bin/bash

go build -o fenc -ldflags "-w -extldflags '-static'"  encr_decr.go