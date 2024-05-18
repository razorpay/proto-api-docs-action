#!/bin/sh

set -ex

echo "Printing env"
env

echo "Starting the script..."

if [ -z "$INPUT_AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
else
  echo "AWS_S3_BUCKET is set to '$INPUT_AWS_S3_BUCKET'."
fi

if [ -z "$INPUT_AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
else
  echo "AWS_ACCESS_KEY_ID is set."
fi

if [ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
else
  echo "AWS_SECRET_ACCESS_KEY is set."
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$INPUT_AWS_REGION" ]; then
  AWS_REGION="us-east-1"
  echo "AWS_REGION is not set. Defaulting to 'us-east-1'."
else
  AWS_REGION="$INPUT_AWS_REGION"
  echo "AWS_REGION is set to '$AWS_REGION'."
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$INPUT_AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $INPUT_AWS_S3_ENDPOINT"
  echo "AWS_S3_ENDPOINT is set to '$INPUT_AWS_S3_ENDPOINT'."
else
  ENDPOINT_APPEND=""
  echo "AWS_S3_ENDPOINT is not set. Using default endpoint."
fi

echo "Configuring AWS CLI..."
# Create a dedicated profile for this action to avoid conflicts
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

SOURCE_DIR=/_docs
echo "SOURCE_DIR is set to '$SOURCE_DIR'."

echo "Starting AWS S3 sync..."
# Sync using our dedicated profile and suppress verbose messages.
sh -c "aws s3 sync ${SOURCE_DIR} s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DEST_DIR} \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} $*"

echo "Clearing AWS credentials..."
# Clear out credentials after we're done.
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

echo "Script completed."