# Proto API Docs Action

This action clones protobuf files from a (public/private) GitHub repository, generates Swagger v2.0 API docs using `buf` and `grpc-gateway`'s [protoc-gen-openapiv2](https://github.com/grpc-ecosystem/grpc-gateway/tree/master/protoc-gen-openapiv2) plugin, and finally uploads the generated documentation to AWS S3.

## Inputs

### GIT_TOKEN:

**Required**  
Git token to use for cloning the repository containing the protobuf files.

### PROTO_REPOSITORY:

**Required**  
Protobuf files GitHub repository, including the organization name.

### PROTO_BRANCH:

**Required**  
Branch to clone.

### MODULE_LIST_FILE_PATH:

**Required**  
Path to the file containing the list of subdirectories of protos to clone.

### AWS_S3_BUCKET:

**Required**  
S3 bucket name.

### AWS_REGION:

**Required**  
AWS region.

### DEST_DIR:

**Required**  
Destination S3 directory.  

Another directory will be created inside the destination directory with the name of the repository running this action. The generated documentation will be uploaded to this directory with the branch name as the file name.

### AWS_ACCESS_KEY_ID:

**Optional**  
AWS access key ID (required if using IAM user credentials).  

### AWS_SECRET_ACCESS_KEY:

**Optional**  
AWS secret access key (required if using IAM user credentials).  

### AWS_ROLE_ARN:

**Optional**  
AWS role ARN (required if using IAM role credentials).  

### AWS_WEB_IDENTITY_TOKEN_FILE:

**Optional**  
AWS web identity token file path (required if using IAM role credentials).  

## Outputs

N/A

## Example Usage

```yaml
- uses: actions/checkout@v2
- uses: razorpay/proto-api-docs-action@v0.2.2
  with:
    GIT_TOKEN: ${{ secrets.GIT_TOKEN }}
    PROTO_REPOSITORY: krantideep95/proto
    PROTO_BRANCH: ${{ github.ref }}
    MODULE_LIST_FILE_PATH: scripts/proto_modules
    AWS_S3_BUCKET: apidocs
    AWS_REGION: ap-south-1
    DEST_DIR: _docs
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }} # Optional if using IAM roles
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }} # Optional if using IAM roles
    AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }} # Optional if using IAM user credentials
    AWS_WEB_IDENTITY_TOKEN_FILE: ${{ secrets.AWS_WEB_IDENTITY_TOKEN_FILE }} # Optional if using IAM user credentials


## FAQs

### Will it work with twirp?

Short Answer: Yes, with a few quirks.

Long Answer: proto-gen-openapiv2 plugin is meant to be used with grpc-gateway protobuf files. It is not meant to be used with twirp. twirp officially doesn't support a plugin to generate swagger api docs. By enabling a few options in plugin, this action can be used to generate swagger api docs for twirp. You can use following proto definitions in one of the files to make this compatible with twirp:
```protobuf
import "protoc-gen-openapiv2/options/annotations.proto";

option (grpc.gateway.protoc_gen_openapiv2.options.openapiv2_swagger) = {
  schemes: HTTPS;
  host: "base url";
  base_path: "/twirp/";
  security: {
    security_requirement :{
      key: "BasicAuth";
      value: {};
    }
  }
  security_definitions: {
    security: {
      key: "BasicAuth";
      value: {
        type: TYPE_BASIC;
      }
    }
}
};
```

### Should this be used in a common protobuf repo or different backend service specific repos ?

Usually, 1 backend service exposes different sub-domains' APIs in 1 deployment. For such cases, it makes sense to use this action separately in that backend service's repo.
