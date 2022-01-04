#!/bin/sh
set -e

echo "cloning protobuf files"
/action/sparse-checkout.sh
/action/add-googleapis.sh

echo "generating swagger docs"
mkdir /gen
cd /proto
COUNTER=0
find . -name "*.proto" | while read file; do
  COUNTER=$(expr $COUNTER + 1)
  echo $COUNTER$file
  protoc --plugin=/bin/protoc-gen-openapi -I. --openapi_out=. "$file" || continue
  [ -f openapi.yaml ] && mv openapi.yaml /gen/$COUNTER.yaml
done

ls /gen

cd /action
echo "combining swagger docs into 1 file"
node combine.mjs /gen/*
ls

echo "create repo/branch dir structure"
mkdir -p /_docs/${GITHUB_REPOSITORY#*/} && mv combined.json /_docs/${GITHUB_REPOSITORY#*/}/${GITHUB_REF##*/}.json

echo "upload to s3"
/action/upload_to_s3.sh
