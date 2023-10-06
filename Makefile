
# System Architecture:
# - linux/amd64
# - linux/arm64
# - linux/amd64,linux/arm64
BUILD_PLATFORM_ARCH := linux/amd64

# Release:
# - debug
# - release
BUILD_RELEASE_MODE := debug

# Docker tag
BUILD_DOCKER_TAG := dmvsocial-lemmy:dev

.PHONY: build

build:
	docker build --platform=$(BUILD_PLATFORM_ARCH) --build-arg RUST_RELEASE_MODE=$(BUILD_RELEASE_MODE) -f ./docker/Dockerfile -t $(BUILD_DOCKER_TAG) .
