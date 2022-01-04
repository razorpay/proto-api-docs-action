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

SOURCE_DIR=/_docs

AWS_ACCESS_KEY_ID=${INPUT_AWS_ACCESS_KEY_ID} \
  AWS_SECRET_ACCESS_KEY=${INPUT_AWS_SECRET_ACCESS_KEY} \
  aws s3 sync ${SOURCE_DIR} s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DEST_DIR} --no-progress