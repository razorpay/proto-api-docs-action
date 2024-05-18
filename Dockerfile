FROM golang:1.21.0-buster

# install pre-requisite
RUN apt update && \
    apt install -y curl && \
    apt install -y git && \
    apt install -y wget && \
	apt install -y jq && \
	apt install -y aws-cli 

# install protoc plugins for code generation
# doc: https://docs.buf.build/tour/generate-code
RUN apt install -y protobuf-compiler=3.6.1.3-2
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28 && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2 && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.11.1 && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.11.1

RUN cp /go/bin/* /usr/bin/

# install buf
# Substitute PREFIX for your install prefix.
# Substitute VERSION for the current released version.
# doc: https://docs.buf.build/installation
RUN PREFIX="/usr/local" && \
    VERSION="1.6.0" && \
    curl -sSL \
    "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-$(uname -s)-$(uname -m).tar.gz" | \
    tar -xvzf - -C "${PREFIX}" --strip-components 1

COPY . /action

WORKDIR /action

ENTRYPOINT [ "/action/entrypoint.sh" ]