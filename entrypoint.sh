#!/bin/sh
set -e

echo "cloning protobuf files"
/sparse-checkout.sh
/add-googleapis.sh

echo "generating swagger docs"
mkdir /gen
cd /proto
ls
find . -name '*.proto' -exec protoc --plugin=/bin/protoc-gen-openapi -I. --openapi_out=/gen {} \;

echo "combining swagger docs into 1 file"
node /combine.mjs /gen/*

echo "create repo/branch dir structure"
mkdir -p /_docs/${GITHUB_REPOSITORY#*/} && mv combined.json /_docs/${GITHUB_REPOSITORY#*/}/${GITHUB_REF##*/}.json

echo "upload to s3"
/upload_to_s3.sh
