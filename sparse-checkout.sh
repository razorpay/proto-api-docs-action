#!/bin/bash
set -euox pipefail
IFS=$'\n\t'

# remove ref/head from $INPUT_PROTO_BRANCH
BRANCH_NAME=$(echo ${INPUT_PROTO_BRANCH#refs/heads/})

mkdir proto
cd proto
git init
git config --local gc.auto 0
git config core.sparseCheckout true
GIT_TOKEN=$INPUT_GIT_TOKEN
cp $GITHUB_WORKSPACE/${INPUT_MODULE_LIST_FILE_PATH} .git/info/sparse-checkout

git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global url."https://x-access-token:${INPUT_GIT_TOKEN}@github.com/".insteadOf https://github.com/ 
git remote add origin https://${INPUT_GIT_TOKEN}@github.com/${INPUT_PROTO_REPOSITORY}
git -c protocol.version=2 fetch --no-tags --prune --depth=1 origin ${BRANCH_NAME}
git checkout --force -B ${BRANCH_NAME} origin/${BRANCH_NAME}
cd ..