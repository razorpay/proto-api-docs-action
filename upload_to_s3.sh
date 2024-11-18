#!/bin/sh

set -e

if [ -z "$INPUT_AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$INPUT_AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$INPUT_AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $INPUT_AWS_S3_ENDPOINT"
fi

SOURCE_DIR=/_docs

# Check if IAM role credentials are set
if [ -n "$INPUT_AWS_ROLE_ARN" ] && [ -n "$INPUT_AWS_WEB_IDENTITY_TOKEN_FILE" ]; then
  echo "Assuming IAM role: $INPUT_AWS_ROLE_ARN"

  # Assume role using web identity token
  export AWS_DEFAULT_REGION="$AWS_REGION"
  export AWS_ROLE_ARN="$INPUT_AWS_ROLE_ARN"
  export AWS_WEB_IDENTITY_TOKEN_FILE="$INPUT_AWS_WEB_IDENTITY_TOKEN_FILE"
  export AWS_ROLE_SESSION_NAME="s3-sync-session"

  # Use AWS CLI directly with assumed role credentials
  aws s3 sync "${SOURCE_DIR}" "s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DEST_DIR}" \
    --no-progress \
    ${ENDPOINT_APPEND} $*

elif [ -n "$INPUT_AWS_ACCESS_KEY_ID" ] && [ -n "$INPUT_AWS_SECRET_ACCESS_KEY" ]; then
  echo "Using IAM user credentials"

  # Create a dedicated profile for this action to avoid conflicts
  aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${INPUT_AWS_REGION}
text
EOF

  # Sync using our dedicated profile
  sh -c "aws s3 sync ${SOURCE_DIR} s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DEST_DIR} \
              --profile s3-sync-action \
              --no-progress \
              ${INPUT_ENDPOINT_APPEND} $*"

  # Clear out credentials after we're done
  aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

else
  echo "Neither IAM user credentials nor IAM role credentials are set. Quitting."
  exit 1
fi

