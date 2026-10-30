FROM --platform=$BUILDPLATFORM golang:1.27-alpine@sha256:d200d2dd76b03a99b52651fd1325aff7dcd35422c35c01bac56571b0507f3deb AS build_deps

RUN apk add --no-cache git ca-certificates

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod go.sum ./
RUN go mod download

FROM build_deps AS build

COPY . .

ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
    -o webhook \
    -ldflags '-w -extldflags "-static"' \
    .

# ── Runtime image ────────────────────────────────────────────────────────────
FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

# Run as a non-root user for least-privilege operation
USER nobody:nobody

ENTRYPOINT ["webhook"]
