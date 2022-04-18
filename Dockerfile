FROM alpine

RUN apk add --no-cache go protobuf-dev aws-cli nodejs git

RUN GOBIN=/bin go install github.com/google/gnostic/cmd/protoc-gen-openapi@549bfe03567bc91a7a3033be7bb245339e73b99e

COPY . /action

ENTRYPOINT [ "/action/entrypoint.sh" ]