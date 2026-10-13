FROM --platform=$BUILDPLATFORM golang:1.27-alpine@sha256:f92b6ef800e499660581efdabdf25d9d817a9d124eaf900924f0504e7e27e12d AS build_deps

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
FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

# Run as a non-root user for least-privilege operation
USER nobody:nobody

ENTRYPOINT ["webhook"]
