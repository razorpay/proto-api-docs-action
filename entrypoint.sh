#!/bin/bash
set -euo pipefail

echo "cloning protobuf files"
bash /sparse-checkout.sh

echo "generating swagger docs"
mkdir /gen
cd /proto
for i in find . -name '*.proto'; do
  protoc --plugin=/bin/protoc-gen-openapi -I. --openapi_out=/gen "$i";
done

echo "combining swagger docs into 1 file"
bash node /combine.mjs /gen/*

echo "create repo/branch dir structure"
mkdir -p /_docs/${GITHUB_REPOSITORY#*/} && mv combined.json /_docs/${GITHUB_REPOSITORY#*/}/${GITHUB_REF##*/}.json


echo "upload to s3"
bash /upload_to_s3.sh
