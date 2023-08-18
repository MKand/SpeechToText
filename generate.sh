#!/bin/sh

# Generates protobuf source files

protoc -I proto -I . --go_out=grpc --go_opt=paths=source_relative --go-grpc_out=grpc --go-grpc_opt=paths=source_relative stt.proto