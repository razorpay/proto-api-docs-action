FROM golang:alpine

RUN apk add --no-cache nodejs aws-cli protobuf-dev

RUN GOBIN=/bin go install github.com/google/gnostic/apps/protoc-gen-openapi@latest

COPY combine.mjs /combine.mjs
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]