FROM --platform=$BUILDPLATFORM golang:1.27-alpine@sha256:eb61c3873c97416fff0116553fff65d67a3549f72e11d9758849a689cdd8b523 AS build_deps

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
FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

# Run as a non-root user for least-privilege operation
USER nobody:nobody

ENTRYPOINT ["webhook"]
