IMAGE_REGISTRY ?= ghcr.io/emulatorchen
IMAGE_NAME     := cert-manager-webhook-freemyip
IMAGE_TAG      ?= 0.1.0
FULL_IMAGE     := $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

OUT := $(shell pwd)/_out
$(shell mkdir -p "$(OUT)")

.PHONY: all tidy build test docker-build docker-save docker-push rendered-manifest.yaml

all: tidy build

tidy:
	go mod tidy

build:
	CGO_ENABLED=0 go build -o $(OUT)/webhook .

test:
	go test -v ./...

docker-build:
	docker build -t "$(FULL_IMAGE)" .

# docker-save: build image and export as a gzipped tarball for air-gapped / ctr-import use.
# The output path can be overridden: make docker-save SAVE_PATH=/tmp/my.tar.gz
SAVE_PATH ?= $(OUT)/$(IMAGE_NAME)-$(IMAGE_TAG).tar.gz
docker-save: docker-build
	docker save "$(FULL_IMAGE)" | gzip > "$(SAVE_PATH)"
	@echo "Image saved to $(SAVE_PATH)"

docker-push: docker-build
	docker push "$(FULL_IMAGE)"

rendered-manifest.yaml:
	helm template cert-manager-webhook-freemyip \
	    --set image.repository=$(IMAGE_REGISTRY)/$(IMAGE_NAME) \
	    --set image.tag=$(IMAGE_TAG) \
	    charts/cert-manager-webhook-freemyip > "$(OUT)/rendered-manifest.yaml"
