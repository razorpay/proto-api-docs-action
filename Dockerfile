FROM c.rzp.io/razorpay/bufbuild:1.6.0_darwin_arm64

# install pre-requisite
RUN apt update && \
    apt install -y curl && \
    apt install -y git && \
    apt install -y wget && \
	apt install -y jq

COPY . /action

WORKDIR /action

ENTRYPOINT [ "/action/entrypoint.sh" ]
