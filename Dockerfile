# Builds a Docker image that allows you to run Jsonnet, kubecfg, and/or ksonnet
# on a file in your local directory. Specifically, this image contains:
#
# 1. Jsonnet, added to /usr/local/bin
# 2. ksonnet-lib, added to the Jsonnet library paths, so you can
#    compile against the ksonnet libraries without specifying the -J
#    flag.
# 3. kubecfg binary, added to /usr/local/bin
# 4. kubecfg lib, included in Jsonnet library paths via KUBECFG_JPATH,
#    similarly to (2) ksonnet-lib.
#
# USAGE: Define a function like `ksonnet` below, and then run:
#
#   `ksonnet <jsonnet-file-and-options-here>`
#
# ksonnet() {
#   docker run -it --rm   \
#     --volume "$PWD":/wd \
#     --workdir /wd       \
#     ksonnet             \
#     jsonnet "$@"
# }
#
# You can also define a similar function for `kubecfg`. Note that any required
# Jsonnet libraries specified by -J (required for compilation) need to be
# described relative to your working directory.

##############################################
# STAGE 1: build kubecfg
##############################################
FROM golang:1.10-alpine as kubecfg-builder
ENV KUBECFG_VERSION v0.8.0
RUN apk update && apk add git make g++
RUN go get -u github.com/ksonnet/kubecfg
WORKDIR /go/src/github.com/ksonnet/kubecfg
RUN git checkout tags/${KUBECFG_VERSION} -b ${KUBECFG_VERSION}
RUN CGO_ENABLED=1 GOOS=linux go install -a --ldflags '-linkmode external -extldflags "-static"' .


FROM golang:1.10 as jsonnet-builder
# Keep this in sync with the corresponding ENV in stage 2
ENV JSONNET_VERSION v0.10.0

RUN go get -u github.com/google/go-jsonnet github.com/fatih/color
WORKDIR $GOPATH/src/github.com/google/go-jsonnet/jsonnet
RUN git checkout tags/${JSONNET_VERSION} -b ${JSONNET_VERSION}
RUN go install -i .

##############################################
# STAGE 2: build jsonnet and download ksonnet
##############################################
FROM alpine:3.6
ENV JSONNET_VERSION v0.8.0
ENV GOPATH /go

RUN mkdir -p /usr/share/kubecfg/${KUBECFG_VERSION}
COPY --from=kubecfg-builder /go/bin/kubecfg /usr/bin/
COPY --from=kubecfg-builder /go/src/github.com/ksonnet/kubecfg/lib/ /usr/share/kubecfg/${KUBECFG_VERSION}/
COPY --from=jsonnet-builder /go/bin/jsonnet /usr/bin/
ENV KUBECFG_JPATH /usr/share/kubecfg/${KUBECFG_VERSION}

# Get ksonnet-lib, add to the Jsonnet -J path.
RUN apk update && apk add git make bash
RUN git clone https://github.com/ksonnet/ksonnet-lib.git
RUN cp -r ksonnet-lib/ksonnet.beta.2 /usr/share/kubecfg/
