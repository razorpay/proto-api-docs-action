#!/bin/bash
set -euox pipefail
IFS=$'\n\t'


# Map inputs to INPUT_* env vars (for backward compatibility with scripts)
export INPUT_GIT_TOKEN="$GIT_TOKEN"
export INPUT_PROTO_REPOSITORY="$PROTO_REPOSITORY"
export INPUT_PROTO_BRANCH="$PROTO_BRANCH"
export INPUT_MODULE_LIST_FILE_PATH="$MODULE_LIST_FILE_PATH"
export INPUT_AWS_S3_BUCKET="$AWS_S3_BUCKET"
export INPUT_AWS_REGION="$AWS_REGION"
export INPUT_DEST_DIR="$DEST_DIR"
export INPUT_AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export INPUT_AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export INPUT_AWS_ROLE_ARN="$AWS_ROLE_ARN"
export INPUT_AWS_WEB_IDENTITY_TOKEN_FILE="$AWS_WEB_IDENTITY_TOKEN_FILE"


# remove ref/head from $INPUT_PROTO_BRANCH
BRANCH_NAME=$(echo ${INPUT_PROTO_BRANCH#refs/heads/})

mkdir proto
cd proto
git init
git config --local gc.auto 0
git config core.sparseCheckout true
GIT_TOKEN=$INPUT_GIT_TOKEN
cp $GITHUB_WORKSPACE/${INPUT_MODULE_LIST_FILE_PATH} .git/info/sparse-checkout
git remote add origin https://${INPUT_GIT_TOKEN}@github.com/${INPUT_PROTO_REPOSITORY}
git -c protocol.version=2 fetch --no-tags --prune --depth=1 origin ${BRANCH_NAME}
git checkout --force -B ${BRANCH_NAME} origin/${BRANCH_NAME}
cd ..
