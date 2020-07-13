# DVC Viewer On-Premise

Bootstrap for running your own DVC Viewer

## Getting Started

1. Create [Github OAuth](./docs/02-github-oauth.md)

### with docker-compose

3. Install requirements
    * [docker-compose v1.25+](https://docs.docker.com/compose/install/)
4. Get access to docker images via aws credentials  
    There are 2 options
    * `eval $(aws ecr get-login --no-include-email)`
    * install and setup [amazon-ecr-credentials-helper](https://github.com/awslabs/amazon-ecr-credential-helper)
5. Launch `GITHUB_CLIENT_ID=.. GITHUB_SECRET_KEY=.. ./start.sh` with variables from previous steps

### with kustomize (minikube)

[Provide AWS credentials to minikube](https://minikube.sigs.k8s.io/docs/handbook/registry/#using-a-private-registry)

3. Install requirements:
    * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    * [kustomize v3.6.1+](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv3.6.1)
4. Copy `k8s/kustomization.yaml.example` to `k8s/kustomization.yaml`
5. Edit file for providing all needful data (needs to fill literals with REQUIRED comment)
6. Launch it `kustomize build . | kubectl apply -f -`

## Documentation

* [Supported enviroment variables](./docs/01-env-variables.md)
