#!/bin/bash
set -euo pipefail

cd /action

mkdir -p proto

echo "cloning protobuf files"
bash sparse-checkout.sh

cd proto
echo "generating swagger docs"
mkdir -p docs
buf mod update
buf generate proto
cd ..

echo "combining swagger docs into 1 file"
bash combine_swagger_docs.sh docs

echo "create repo/branch dir structure"
mkdir -p /_docs/${GITHUB_REPOSITORY#*/} && \
    mv proto/combined.json /_docs/${GITHUB_REPOSITORY#*/}/${GITHUB_REF##*/}.json

echo "upload to s3"
bash upload_to_s3.sh

echo "upload completed to s3"
echo "docs available at: https://idocs.razorpay.com/openapi/upi-switch/${BRANCH}"
