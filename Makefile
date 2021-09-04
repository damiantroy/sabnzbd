REPO_NAME ?= damiantroy
IMAGE_NAME ?= sabnzbd
APP_NAME := ${REPO_NAME}/${IMAGE_NAME}
CONTAINER_RUNTIME := $(shell command -v podman 2> /dev/null || echo docker)

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

.PHONY: all
all: build test ## Build and test the container.

.PHONY: build
build: ## Build the container.
	$(CONTAINER_RUNTIME) build -t "${APP_NAME}" .

.PHONY: build-nc
build-nc: ## Build the container without cache.
	$(CONTAINER_RUNTIME) build --no-cache -t "${APP_NAME}" .

.PHONY: test
test: ## Test the container.
	$(CONTAINER_RUNTIME) run -it --rm "${APP_NAME}" \
		bash -c "/opt/sabnzbd/SABnzbd.py --logging 1 --browser 0 & \
			test.sh -t 30 -u http://localhost:8080/ -e sabnzbd"

.PHONY: snyk-monitor
snyk-monitor:
	mkdir .snyk
	$(CONTAINER_RUNTIME) save "${APP_NAME}" -o ".snyk/${IMAGE_NAME}"
	snyk container monitor "docker-archive:.snyk/${IMAGE_NAME}" --file=Dockerfile
	rm -rf .sny

.PHONY: push
push: ## Publish the container on Docker Hub
	$(CONTAINER_RUNTIME) push "${APP_NAME}"

.PHONY: shell
shell: ## Launce a shell in the container.
	$(CONTAINER_RUNTIME) run -it --rm \
		"${APP_NAME}" bash

.PHONY: clean
clean: ## Clean the generated files/images.
	$(CONTAINER_RUNTIME) rmi "${APP_NAME}"
