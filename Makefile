.PHONY: help build push
phony: help

# Release tag for the action
VERSION := v0.1

# GitHub Actions bogus variables
GITHUB_REF ?= refs/heads/null
GITHUB_SHA ?= aabbccddeeff

# Other variables and constants
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
RELEASE_BRANCH := master
DOCKER_USER_ID := christophshyper
DOCKER_IMAGE := docker-okta-aws-sso
DOCKER_NAME := $(DOCKER_USER_ID)/$(DOCKER_IMAGE)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Dependent repo
DEP_OWNER := Nike-Inc
DEP_REPO := gimme-aws-creds

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

build: ## Buid Docker image
	$(info $(NL)$(TXT_GREEN) == STARTING BUILD ==$(TXT_RESET))
	$(info $(TXT_GREEN)Release tag:$(TXT_YELLOW)        $(VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Current branch:$(TXT_YELLOW)     $(CURRENT_BRANCH)$(TXT_RESET))
	$(info $(TXT_GREEN)Commit hash:$(TXT_YELLOW)        $(GITHUB_SHORT_SHA)$(TXT_RESET))
	$(info $(TXT_GREEN)Build date:$(TXT_YELLOW)         $(BUILD_DATE)$(TXT_RESET))
	$(info $(NL)$(TXT_GREEN)Checkout repository:$(TXT_YELLOW) $(DEP_OWNER)/$(DEP_REPO)$(TXT_RESET))
	@rm -rf $(DEP_REPO)
	@git clone http://github.com/$(DEP_OWNER)/$(DEP_REPO)
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION)$(TXT_RESET))
	@cd $(DEP_REPO); docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg VERSION=$(VERSION) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION)  \
		--label "org.label-schema.build-date=${BUILD_DATE}" \
        --label	"org.label-schema.description=Docker image for AWS Signle Sign-On with Okta." \
        --label	"org.label-schema.name=docker-okta-aws-sso" \
        --label "org.label-schema.schema-version=1.0"	\
        --label "org.label-schema.url=https://christophshyper.github.io/" \
        --label	"org.label-schema.vcs-ref=${VCS_REF}" \
        --label	"org.label-schema.vcs-url=https://github.com/ChristophShyper/docker-okta-aws-sso" \
        --label	"org.label-schema.vendor=Krzysztof Szyper <biotyk@mail.com>" \
        --label	"org.label-schema.version=${VERSION}" \
        --label	"maintainer=Krzysztof Szyper <biotyk@mail.com>" \
        --label	"repository=https://github.com/ChristophShyper/docker-okta-aws-sso" \
		.
		@rm -rf $(DEP_REPO)

push: ## Push to DockerHub
	$(info $(NL)$(TXT_GREEN) == STARTING DEPLOYMENT == $(TXT_RESET))
	$(info $(NL)$(TXT_GREEN)Logging to DockerHub$(TXT_RESET))
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USER_ID) --password-stdin
	$(info $(NL)$(TXT_GREEN)Pushing image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION)$(TXT_RESET))
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):latest
	@docker push $(DOCKER_NAME):$(VERSION)
	@docker push $(DOCKER_NAME):latest
