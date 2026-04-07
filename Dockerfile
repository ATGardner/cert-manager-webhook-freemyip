FROM golang:1.22-alpine AS build_deps

RUN apk add --no-cache git ca-certificates

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod go.sum ./
RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build \
    -o webhook \
    -ldflags '-w -extldflags "-static"' \
    .

# ── Runtime image ────────────────────────────────────────────────────────────
FROM alpine:3.19

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

# Run as a non-root user for least-privilege operation
USER nobody:nobody

ENTRYPOINT ["webhook"]
