FROM golang:1.21.1-alpine3.18

RUN apk update; apk add make git curl bash jq aws-cli

#COPY ./go.env /custom_go.env
#
#RUN touch $(go env GOROOT)/go.env &&  \
#    cat /custom_go.env >> $(go env GOROOT)/go.env &&  \
#    rm /custom_go.env

RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.10.0
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.0

RUN curl -sSL \
	"https://github.com/bufbuild/buf/releases/download/v1.3.1/buf-Linux-x86_64" \
	-o "$(go env GOPATH)/bin/buf" && \
	chmod +x "$(go env GOPATH)/bin/buf"

COPY . /action

WORKDIR /action

ENTRYPOINT [ "/action/entrypoint.sh" ]
