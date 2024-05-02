#!/bin/bash
set -euo pipefail

cd /action

mkdir proto
cd proto
git clone https://{INPUT_GIT_TOKEN}@github.com/${INPUT_PROTO_REPOSITORY}

echo "generating swagger docs"
buf mod update && buf generate proto

cd ..

mv proto/docs .

echo "combining swagger docs into 1 file"
bash combine_swagger_docs.sh docs

echo "create repo/branch dir structure"
mkdir -p /_docs/${GITHUB_REPOSITORY#*/} && mv combined.json /_docs/${GITHUB_REPOSITORY#*/}/${GITHUB_REF##*/}.json


echo "upload to s3"
bash upload_to_s3.sh
