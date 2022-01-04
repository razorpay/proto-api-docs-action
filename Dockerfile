FROM alpine

RUN apk add --no-cache go protobuf-dev aws-cli nodejs git

RUN GOBIN=/bin go install github.com/google/gnostic/apps/protoc-gen-openapi@latest

COPY . /action

ENTRYPOINT [ "/action/entrypoint.sh" ]