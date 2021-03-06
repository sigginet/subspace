FROM golang:1.11.5 as build

RUN apt-get update \
    && apt-get install -y git make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY Makefile ./
# go.mod and go.sum if exists
COPY go.* ./
COPY *.go ./
COPY static ./static
COPY templates ./templates
COPY email ./email

ARG BUILD_VERSION=unknown

ENV GODEBUG="netdns=go http2server=0"

RUN make BUILD_VERSION=${BUILD_VERSION}

FROM phusion/baseimage:0.11
LABEL maintainer="github.com/subspacecommunity/subspace"

COPY --from=build  /src/subspace-linux-amd64 /usr/bin/subspace
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DEBIAN_FRONTEND noninteractive

RUN chmod +x /usr/bin/subspace /usr/local/bin/entrypoint.sh

RUN apt-get update \
    && apt-get install -y iproute2 iptables dnsmasq socat

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD [ "/sbin/my_init" ]
