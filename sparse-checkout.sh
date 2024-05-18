#!/bin/bash
set -euox pipefail
IFS=$'\n\t'

# Remove ref/head from $INPUT_PROTO_BRANCH
BRANCH_NAME=$(echo ${INPUT_PROTO_BRANCH#refs/heads/})

cd proto
git init
git config --local gc.auto 0
git remote add origin https://${INPUT_TOKEN_GIT}@github.com/${INPUT_PROTO_REPOSITORY}
git -c protocol.version=2 fetch --no-tags --prune origin ${BRANCH_NAME}
git checkout --force -B ${BRANCH_NAME} origin/${BRANCH_NAME}
cd ..