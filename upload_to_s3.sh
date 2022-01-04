#!/bin/sh

set -e

if [ -z "$INPUT_AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$INPUT_AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $INPUT_AWS_S3_ENDPOINT"
fi

SOURCE_DIR=/_docs
# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
sh -c "AWS_ACCESS_KEY_ID=${INPUT_AWS_ACCESS_KEY_ID} \
  AWS_SECRET_ACCESS_KEY=${INPUT_AWS_SECRET_ACCESS_KEY} \
  aws s3 sync --dryrun ${SOURCE_DIR} s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DEST_DIR} --no-progress \
  ${INPUT_ENDPOINT_APPEND} $*"