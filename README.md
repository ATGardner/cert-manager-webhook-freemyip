# cert-manager-webhook-freemyip

A [cert-manager](https://cert-manager.io) ACME DNS-01 webhook solver for
[freemyip.com](https://freemyip.com) dynamic DNS.

The webhook implements the cert-manager external DNS solver protocol so that
Let's Encrypt can verify domain ownership — including wildcard certificates —
using the freemyip TXT-record API.

## How it works

freemyip exposes a single HTTP endpoint that manages both A-records and TXT
records for your registered domain:

```
# Set TXT record (Present)
GET https://freemyip.com/update?token=TOKEN&domain=example.freemyip.com&txt=ACME_CHALLENGE

# Clear TXT record (CleanUp)
GET https://freemyip.com/update?token=TOKEN&domain=example.freemyip.com&txt=
```

The webhook calls this endpoint in response to cert-manager's `Present` and
`CleanUp` calls, allowing Let's Encrypt to verify `_acme-challenge.example.freemyip.com`.

## Prerequisites

- cert-manager ≥ v1.8.0 installed in the cluster
- A registered domain on freemyip.com (e.g. `example.freemyip.com`)
- Your freemyip API token

## Build

```bash
# Run go mod tidy first to populate go.sum
make tidy

# Build the binary locally
make build

# Build and push Docker image
IMAGE_REGISTRY=ghcr.io/emulatorchen IMAGE_TAG=0.1.0 make docker-push
```

## Install

```bash
# Clone the repo onto the machine where you run Helm
git clone https://github.com/emulatorchen/cert-manager-webhook-freemyip.git

# Install the Helm chart into the cert-manager namespace
helm upgrade --install cert-manager-webhook-freemyip \
  --namespace cert-manager \
  --set freemyip.token='YOUR_TOKEN' \
  --set clusterIssuer.production.create=true \
  --set clusterIssuer.staging.create=true \
  --set clusterIssuer.email='you@example.com' \
  --set image.repository=ghcr.io/emulatorchen/cert-manager-webhook-freemyip \
  --set image.tag=0.1.0 \
  ./charts/cert-manager-webhook-freemyip
```

## Usage

Reference the ClusterIssuer in a Certificate or Ingress annotation:

```yaml
# Ingress annotation
cert-manager.io/cluster-issuer: cert-manager-webhook-freemyip-production

# Certificate resource
spec:
  issuerRef:
    name: cert-manager-webhook-freemyip-production
    kind: ClusterIssuer
  dnsNames:
    - example.freemyip.com
    - "*.example.freemyip.com"
```

## Configuration reference

| Value | Default | Description |
|-------|---------|-------------|
| `freemyip.token` | `""` | freemyip API token (stored in a Secret) |
| `clusterIssuer.email` | `name@example.com` | Email for Let's Encrypt registration |
| `clusterIssuer.production.create` | `false` | Create the production ClusterIssuer |
| `clusterIssuer.staging.create` | `false` | Create the staging ClusterIssuer |
| `image.repository` | `ghcr.io/emulatorchen/cert-manager-webhook-freemyip` | Image registry path |
| `image.tag` | `0.1.0` | Image tag |
| `groupName` | `acme.freemyip.emulatorchen.github.com` | Webhook group name (must be unique) |

## License

Apache 2.0 — see [LICENSE](LICENSE).
