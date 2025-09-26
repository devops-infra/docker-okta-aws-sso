.PHONY: phony
phony: help

# Release tag for the action
VERSION := $(or $(VERSION),$(shell git describe --tags --abbrev=0 2>/dev/null))

# GitHub Actions bogus variables
GITHUB_REF ?= refs/heads/null
GITHUB_SHA ?= aabbccddeeff
VERSION_PREFIX ?=

# Other variables and constants
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
DOCKER_USERNAME := $(or $(DOCKER_USERNAME),christophshyper)
DOCKER_ORG_NAME := $(or $(DOCKER_ORG_NAME),devopsinfra)
DOCKER_IMAGE := docker-okta-aws-sso
DOCKER_NAME := $(DOCKER_ORG_NAME)/$(DOCKER_IMAGE)
GITHUB_USERNAME := $(or $(GITHUB_USERNAME),ChristophShyper)
GITHUB_ORG_NAME := $(or $(GITHUB_ORG_NAME),devops-infra)
GITHUB_NAME := ghcr.io/$(GITHUB_ORG_NAME)/$(DOCKER_IMAGE)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
NAME := Single Sign-On solution for AWS via Okta
DESCRIPTION := Docker image for AWS Single Sign-On with Okta
REPO_URL := https://github.com/devops-infra/docker-okta-aws-sso
AUTHOR := Krzysztof Szyper / ChristophShyper <biotyk@mail.com>
HOMEPAGE := https://christophshyper.github.io/

# Dependent repo
DEP_OWNER := Nike-Inc
DEP_REPO := gimme-aws-creds

# Recognize whether docker buildx is installed or not
DOCKER_CHECK := $(shell docker buildx version 1>&2 2>/dev/null; echo $$?)
ifeq ($(DOCKER_CHECK),0)
DOCKER_COMMAND := docker buildx build --platform linux/amd64,linux/arm64
else
DOCKER_COMMAND := docker build
endif

# Some cosmetics
SHELL := bash
TXT_RED := $(shell tput setaf 1)
TXT_GREEN := $(shell tput setaf 2)
TXT_YELLOW := $(shell tput setaf 3)
TXT_RESET := $(shell tput sgr0)
define NL


endef

# Main actions
help: ## Display help prompt
	$(info Available options:)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(TXT_YELLOW)%-25s $(TXT_RESET) %s\n", $$1, $$2}'


.PHONY: login
login: ## Log into all registries
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)Docker Hub$(TXT_RESET)"
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USERNAME) --password-stdin
	@echo -e "\n$(TXT_GREEN)Logging to: $(TXT_YELLOW)GitHub Packages$(TXT_RESET)"
	@echo $(GITHUB_TOKEN) | docker login ghcr.io -u $(GITHUB_USERNAME) --password-stdin


.PHONY: build
build: ## Build Docker image
	$(info $(NL)$(TXT_GREEN) == STARTING BUILD ==$(TXT_RESET))
	$(info $(TXT_GREEN)Release tag:$(TXT_YELLOW)        $(VERSION_PREFIX)$(VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Current branch:$(TXT_YELLOW)     $(CURRENT_BRANCH)$(TXT_RESET))
	$(info $(TXT_GREEN)Commit hash:$(TXT_YELLOW)        $(GITHUB_SHORT_SHA)$(TXT_RESET))
	$(info $(TXT_GREEN)Build date:$(TXT_YELLOW)         $(BUILD_DATE)$(TXT_RESET))
	$(info $(NL)$(TXT_GREEN)Checkout repository:$(TXT_YELLOW) $(DEP_OWNER)/$(DEP_REPO)$(TXT_RESET))
	@rm -rf $(DEP_REPO)
	@git clone http://github.com/$(DEP_OWNER)/$(DEP_REPO)
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET))
	cd $(DEP_REPO); \
		$(DOCKER_COMMAND) \
		--label "org.label-schema.build-date=${BUILD_DATE}" \
		--label "org.label-schema.name=${NAME}" \
		--label "org.label-schema.description=${DESCRIPTION}" \
		--label "org.label-schema.usage=README.md" \
		--label "org.label-schema.url=${HOMEPAGE}" \
		--label "org.label-schema.vcs-url=${REPO_URL}" \
		--label "org.label-schema.vcs-ref=${GITHUB_SHORT_SHA}" \
		--label "org.label-schema.vendor=${AUTHOR}" \
		--label "org.label-schema.version=${VERSION}" \
		--label "org.label-schema.schema-version=1.0"	\
		--label "org.opencontainers.image.created=${BUILD_DATE}" \
		--label "org.opencontainers.image.authors=${AUTHOR}" \
		--label "org.opencontainers.image.url=${HOMEPAGE}" \
		--label "org.opencontainers.image.documentation=${REPO_URL}/blob/master/README.md" \
		--label "org.opencontainers.image.source=${REPO_URL}" \
		--label "org.opencontainers.image.version=${VERSION}" \
		--label "org.opencontainers.image.revision=${GITHUB_SHORT_SHA}" \
		--label "org.opencontainers.image.vendor=${AUTHOR}" \
		--label "org.opencontainers.image.licenses=MIT" \
		--label "org.opencontainers.image.title=${NAME}" \
		--label "org.opencontainers.image.description=${DESCRIPTION}" \
		--label "maintainer=${AUTHOR}" \
		--label "repository=${REPO_URL}" \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)latest \
		.
	@rm -rf $(DEP_REPO)/


.PHONY: push
push: login ## Push to DockerHub
	$(info $(NL)$(TXT_GREEN) == STARTING BUILD ==$(TXT_RESET))
	$(info $(TXT_GREEN)Release tag:$(TXT_YELLOW)        $(VERSION_PREFIX)$(VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Current branch:$(TXT_YELLOW)     $(CURRENT_BRANCH)$(TXT_RESET))
	$(info $(TXT_GREEN)Commit hash:$(TXT_YELLOW)        $(GITHUB_SHORT_SHA)$(TXT_RESET))
	$(info $(TXT_GREEN)Build date:$(TXT_YELLOW)         $(BUILD_DATE)$(TXT_RESET))
	$(info $(NL)$(TXT_GREEN)Checkout repository:$(TXT_YELLOW) $(DEP_OWNER)/$(DEP_REPO)$(TXT_RESET))
	@rm -rf $(DEP_REPO)
	@git clone http://github.com/$(DEP_OWNER)/$(DEP_REPO)
	$(info $(NL)$(TXT_GREEN)Pushing image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION)$(TXT_RESET))
	@cd $(DEP_REPO); \
		$(DOCKER_COMMAND) --push \
		--label "org.label-schema.build-date=${BUILD_DATE}" \
		--label "org.label-schema.name=${NAME}" \
		--label "org.label-schema.description=${DESCRIPTION}" \
		--label "org.label-schema.usage=README.md" \
		--label "org.label-schema.url=${HOMEPAGE}" \
		--label "org.label-schema.vcs-url=${REPO_URL}" \
		--label "org.label-schema.vcs-ref=${GITHUB_SHORT_SHA}" \
		--label "org.label-schema.vendor=${AUTHOR}" \
		--label "org.label-schema.version=${VERSION}" \
		--label "org.label-schema.schema-version=1.0"	\
		--label "org.opencontainers.image.created=${BUILD_DATE}" \
		--label "org.opencontainers.image.authors=${AUTHOR}" \
		--label "org.opencontainers.image.url=${HOMEPAGE}" \
		--label "org.opencontainers.image.documentation=${REPO_URL}/blob/master/README.md" \
		--label "org.opencontainers.image.source=${REPO_URL}" \
		--label "org.opencontainers.image.version=${VERSION}" \
		--label "org.opencontainers.image.revision=${GITHUB_SHORT_SHA}" \
		--label "org.opencontainers.image.vendor=${AUTHOR}" \
		--label "org.opencontainers.image.licenses=MIT" \
		--label "org.opencontainers.image.title=${NAME}" \
		--label "org.opencontainers.image.description=${DESCRIPTION}" \
		--label "maintainer=${AUTHOR}" \
		--label "repository=${REPO_URL}" \
		--file=Dockerfile \
 		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)$(VERSION) \
		--tag=$(DOCKER_NAME):$(VERSION_PREFIX)latest \
		.
	@rm -rf $(DEP_REPO)/
