# Docker image for AWS Single Sign-On with Okta.

Dockerized ([devopsinfra/docker-okta-aws-sso](https://hub.docker.com/repository/docker/devopsinfra/docker-okta-aws-sso)) Single Sign-On solution for [Amazon Web Services](https://aws.amazon.com/) via [Okta](https://www.okta.com/).

Okta is one of the leaders of SSO solutions, but lacks native CLI tools.

The best, in my humble opinion, tool that fixes that problem is [gimme-aws-creds](https://github.com/Nike-Inc/gimme-aws-creds) made by [Nike Inc.](http://engineering.nike.com). More of their interesting work can be found on [Nike-Inc](https://github.com/Nike-Inc).

Currently, supporting v2.3.4 of gimme-aws-creds.

For details information about [gimme-aws-creds](https://github.com/Nike-Inc/gimme-aws-creds)'s configuration please refer to [README.md](https://github.com/Nike-Inc/gimme-aws-creds/blob/master/README.md).
<br>Docker's entrypoint is the binary of `gimme-aws-creds` and can accept any parameters, even when running as an alias, or a function (check usage below).
<br>It supports Multi Factor Authentication. Not only with authenticator app but even with Yubikey (without PIN).

This Docker image just packs the tool to quickly reuse it without the need of installing with Python.
<br>It should have access only to following configuration files: 
* [gimme-aws-creds](https://github.com/Nike-Inc/gimme-aws-creds), default is `~/.okta_aws_login_config`
* [aws-cli](https://github.com/aws/aws-cli), default is `~/.aws/credentials`


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-devops--infra%2Fdocker--okta--aws--sso-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/docker-okta-aws-sso?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/docker-okta-aws-sso?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/devops-infra/docker-okta-aws-sso "shields.io")
[![Push to master](https://img.shields.io/github/workflow/status/devops-infra/docker-okta-aws-sso/Push%20to%20master?color=brightgreen&label=Master%20branch&logo=github&style=flat-square)
](https://github.com/devops-infra/docker-okta-aws-sso/actions?query=workflow%3A%22Push+to+master%22)
[![Push to other](https://img.shields.io/github/workflow/status/devops-infra/docker-okta-aws-sso/Push%20to%20other?color=brightgreen&label=Pull%20requests&logo=github&style=flat-square)
](https://github.com/devops-infra/docker-okta-aws-sso/actions?query=workflow%3A%22Push+to+other%22)
<br>
[
![DockerHub](https://img.shields.io/badge/docker-devopsinfra%2Fdocker--okta--aws--sso-blue.svg?style=flat-square&logo=docker)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/docker-okta-aws-sso/latest?label=Image%20size&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/docker-okta-aws-sso?color=blue&label=Pulls&logo=docker&style=flat-square)
](https://hub.docker.com/r/devopsinfra/docker-okta-aws-sso "shields.io")


## Prerequisites
* Operating system: MacOS, Linux or Windows Subsystem for Linux.
* Software: Docker
* AWS: IAM roles prepared for users to assume. IAM user for Okta properly configured.
* Okta: Okta connected via SAML with AWS. Users having assigned AWS application and chosen proper roles.


## Configuration
For ease of reuse create alias or a function in your shell. For example in `~/.profile` enter following:
```shell script
function okta-aws() {
    docker run --rm \
        --user $(id -u):$(id -g) \
        --volume $(pwd)/.okta_aws_login_config:/.okta_aws_login_config \
        --volume $(pwd)/.aws/credentials:/.aws/credentials \
        -it devopsinfra/docker-okta-aws-sso:latest "$@";
}
```

Run the interactive installer by executing: `okta-aws --action-configure`.

For more information run `okta-aws --help`.

**Simplest** configuration file:
```
[DEFAULT]
okta_username = user.name@domain.com
aws_rolename =
cred_profile = default
aws_default_duration = 3600
okta_org_url = https://dev-123456.okta.com
app_url = https://dev-123456.okta.com/home/amazon_aws/1fD3c8s3mfhMHxF1o9id/272
preferred_mfa_type = token:software:totp
device_token =
gimme_creds_server = appurl
write_aws_creds = True
resolve_aws_alias = True
remember_device = True
output_format = json
```

Parameters, like password, can be also passed via environment variables for reuse. But keep in mind security concerns.


## Running
Depending on the configuration (above) new AWS credentials can be obtained by running:
* for a default action: `okta-aws`
* for a selected profile `okta-aws --profile Administrator`
