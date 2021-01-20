# DVC Viewer On-Premise

This repository contains recipes for you to run Iterative Viewer on your own
infrastructure, using `docker-compose` or `k8s` or one of it's flavors.

The guide will walk you through the preparation, customization, and basic
deployment scenarios.

## Prerquisites

### Getting the OAuth apps

In order to run Viewer on premise, you'll need to setup your own Github or
Gitlab OAuth apps and provide their credentials to the Viewer to use.

#### Github OAuth app

Please follow [this guide](./docs/02-github-oauth.md) to setup your own Github
OAuth app.

#### GitLab OAuth app

Please follow [the official guide](https://docs.gitlab.com/ee/integration/oauth_provider.html) to set it up.  
Redirect URI shoulde be **${API_URL}/complete/gitlab/**, see [Settings and Customization](https://github.com/iterative/viewer-onpremise/blob/master/docs/01-env-variables.md) for details.

## Deployment

Viewer is distributed via Iterative's private Docker registry as a set of
pre-build images.

We assume that Docker Compose and K8s will be the most common environments
Viewer will be deployed to on premise.

### Deploying using Docker Compose

1. Your infra needs to have
   [docker-compose v1.25 or newer](https://docs.docker.com/compose/install/) to
   run Viewer.
2. [Login to the private registry](https://docs.docker.com/engine/reference/commandline/login/)
   ```
   $ docker login -u trial -p letmetakealook docker.iterative.ai
   ```
3. Configure `GITHUB_CLIENT_ID=.. GITHUB_SECRET_KEY=.. ./install.sh` with variables
   from previous steps.
   More info `./install --help`
4. Launch the stack `docker-compose up`

Please see [`docker-compose`](/docker-compose/) and generated `docker-compose.yaml` for more details.


### Deploying to K8s

This guide is based on using manifests built wuth Kustomize. This section should
work on any K8s compatible flavor, while the next section focuses on running on
minikube.

1. Install requirements:
   - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
   - [kustomize v3.6.1+](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv3.6.1)
2. Create k8s secret with the Docker Private Registry credentials:
   [for docker regisry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
   ```
   $ kubectl create secret docker-registry dvc-viewer-aws \
     --docker-server=docker.iterative.ai \
     --docker-username=trial \
     --docker-password=letmetakealook
   $ kubectl patch serviceaccount default -p '{"imagePullSecrets":[{"name":"dvc-viewer-aws"}]}'
   ```
3. Bootstrap your own customization files:
   `cp k8s/kustomization.yaml.example k8s/kustomization.yaml`
4. Edit file for providing all needful data (needs to fill literals with
   REQUIRED comment)
5. Launch it `kustomize build k8s | kubectl apply -f -`

_Note: if you'd like to see what manifests are created by kustomize, just dump
them in a file with `kustomize build k8s > k8s/resources.yaml` and review them
before creating them in your cluster._

#### with k8s (minikube)

6. Expose services
   ```
   $ kubectl port-forward service/dvc-viewer-backend 8000:8000
   $ kubectl port-forward service/dvc-viewer-ui 3000:3000
   ```

After that, you should be able to navigate to `http://localhost:3000` and see
the Viewer main page!

_Note: this guide doesn't cover ingress setup, if you want Viewer to be
accessible on specific hostname, you'll need to setup the ingress yourself._
