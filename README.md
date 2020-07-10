# DVC Viewer On-Premise

Bootstrap for running your own DVC Viewer

## Getting Started

1. Get access to docker images via aws credentials  
    There are 2 options
    * `eval $(aws ecr get-login --no-include-email)`
    * install and setup [amazon-ecr-credentials-helper](https://github.com/awslabs/amazon-ecr-credential-helper)
2. Create [Github OAuth](./docs/02-github-oauth.md)

## Documentation

* [Supported enviroment variables](./docs/01-env-variables.md)
