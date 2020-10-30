APP_NAME ?= sabnzbd

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

.PHONY: all
all: build test ## Build and test the container.

.PHONY: build
build: ## Build the container.
	podman build -t "${APP_NAME}" .

.PHONY: build-nc
build-nc: ## Build the container without cache.
	podman build --no-cache -t "${APP_NAME}" .

.PHONY: test
test: ## Test the container.
	podman run -it --rm --name "${APP_NAME}" "${APP_NAME}" \
		bash -c "/opt/sabnzbd/SABnzbd.py --logging 1 --browser 0 & \
		test.sh -t 30 -u http://localhost:8080/ -e sabnzbd"

.PHONY: clean
clean: ## Clean the generated files/images.
	podman rmi "${APP_NAME}"
