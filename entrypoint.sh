#!/bin/bash
set -euo pipefail

# Map Docker action args to environment variables
INPUT_GIT_TOKEN="$1"
INPUT_PROTO_REPOSITORY="$2"
INPUT_PROTO_BRANCH="$3"
INPUT_MODULE_LIST_FILE_PATH="$4"
INPUT_AWS_S3_BUCKET="$5"
INPUT_AWS_REGION="$6"
INPUT_DEST_DIR="$7"
INPUT_AWS_ACCESS_KEY_ID="$8"
INPUT_AWS_SECRET_ACCESS_KEY="$9"
INPUT_AWS_ROLE_ARN="${10}"
INPUT_AWS_WEB_IDENTITY_TOKEN_FILE="${11}"

# Export them so downstream scripts can access
export INPUT_GIT_TOKEN INPUT_PROTO_REPOSITORY INPUT_PROTO_BRANCH INPUT_MODULE_LIST_FILE_PATH
export INPUT_AWS_S3_BUCKET INPUT_AWS_REGION INPUT_DEST_DIR
export INPUT_AWS_ACCESS_KEY_ID INPUT_AWS_SECRET_ACCESS_KEY
export INPUT_AWS_ROLE_ARN INPUT_AWS_WEB_IDENTITY_TOKEN_FILE

cd /action

echo "cloning protobuf files"
bash sparse-checkout.sh

echo "generating swagger docs"
buf mod update && buf generate

echo "combining swagger docs into 1 file"
bash combine_swagger_docs.sh docs

echo "create repo/branch dir structure"
mkdir -p /_docs/${GITHUB_REPOSITORY#*/} && mv combined.json /_docs/${GITHUB_REPOSITORY#*/}/${GITHUB_REF##*/}.json


echo "upload to s3"
bash upload_to_s3.sh
