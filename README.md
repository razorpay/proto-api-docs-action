# Proto api docs action

This action clones protobuf files from a (public/private) GitHub repository, generates Swagger v2.0 API docs using buf & grpc-gateway's [protoc-gen-openapiv2](https://github.com/grpc-ecosystem/grpc-gateway/tree/master/protoc-gen-openapiv2) plugin, and finally uploads the generated documentation to AWS S3.

## Inputs

### GIT_TOKEN

**Required** Git token to use for cloning the repository containing the protobuf files.

### PROTO_REPOSITORY

**Required** Protobuf files GitHub repository, including the org name.

### PROTO_BRANCH

**Required** Branch to clone.

### MODULE_LIST_FILE_PATH

**Required** Path to the file containing the list of subdirectories of protos to clone.

### AWS_S3_BUCKET

**Required** S3 bucket name.

### AWS_ROLE_ARN

**Required** IAM role ARN to assume for S3 access.

### AWS_ROLE_SESSION_NAME

**Optional** Session name for the assumed role. Defaults to `s3-sync-session`.

### AWS_REGION

**Required** AWS region.

### DEST_DIR

**Required** Destination S3 directory.

Another directory will be created in the destination directory with the name of the repository running this action. The generated documentation will be uploaded to this directory with the branch name as the name of the file.

## Outputs
None

## Example usage
```yaml
- uses: actions/checkout@v2
- uses: razorpay/proto-api-docs-action@v0.3.0-iam-role
  with:
    GIT_TOKEN: ${{ secrets.GIT_TOKEN }}
    PROTO_REPOSITORY: myorg/proto
    PROTO_BRANCH: ${{ github.ref }}
    MODULE_LIST_FILE_PATH: scripts/proto_modules
    AWS_S3_BUCKET: my-bucket
    AWS_ROLE_ARN: arn:aws:iam::123456789012:role/my-s3-access-role
    AWS_ROLE_SESSION_NAME: s3-sync-session
    AWS_REGION: ap-south-1
    DEST_DIR: _docs

