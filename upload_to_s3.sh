#!/bin/sh

set -e

if [ -z "$INPUT_AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_AWS_ROLE_ARN" ]; then
  echo "AWS_ROLE_ARN is not set. Quitting."
  exit 1
fi

if [ -z "$INPUT_AWS_ROLE_SESSION_NAME" ]; then
  INPUT_AWS_ROLE_SESSION_NAME="s3-sync-session"
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$INPUT_AWS_REGION" ]; then
  AWS_REGION="us-east-1"
else
  AWS_REGION="$INPUT_AWS_REGION"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$INPUT_AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $INPUT_AWS_S3_ENDPOINT"
fi

# Assume the specified IAM role to get temporary credentials
CREDENTIALS=$(aws sts assume-role --role-arn "$INPUT_AWS_ROLE_ARN" \
                                  --role-session-name "$INPUT_AWS_ROLE_SESSION_NAME" \
                                  --region "$AWS_REGION" \
                                  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                                  --output text)

if [ -z "$CREDENTIALS" ]; then
  echo "Failed to assume role. Quitting."
  exit 1
fi

# Parse the credentials
ACCESS_KEY_ID=$(echo "$CREDENTIALS" | awk '{print $1}')
SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | awk '{print $2}')
SESSION_TOKEN=$(echo "$CREDENTIALS" | awk '{print $3}')

# Configure AWS CLI with temporary credentials
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
$ACCESS_KEY_ID
$SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

# Set session token in the environment
export AWS_SESSION_TOKEN="$SESSION_TOKEN"

SOURCE_DIR=/_docs
# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
sh -c "aws s3 sync ${SOURCE_DIR} s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DEST_DIR} \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} $*"

# Clear out credentials after we're done.
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

# Unset session token
unset AWS_SESSION_TOKEN
