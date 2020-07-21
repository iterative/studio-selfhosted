# DVC Viewer On-Premise

Bootstrap for running your own DVC Viewer

## Getting Started

1. Create [Github OAuth](./docs/02-github-oauth.md)

### with docker-compose

3. Install requirements
    * [docker-compose v1.25+](https://docs.docker.com/compose/install/)
4. Login [into docker](https://docs.docker.com/engine/reference/commandline/login/)  
    ```
    $ docker login -u trial -p letmetakealook docker.iterative.ai
    ```
5. Launch `GITHUB_CLIENT_ID=.. GITHUB_SECRET_KEY=.. ./start.sh` with variables from previous steps

### with k8s (kustomize)

3. Install requirements:
    * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    * [kustomize v3.6.1+](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv3.6.1)
4. Provide credentials [for docker regisry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
    ```
    $ kubectl create secret docker-registry dvc-viewer-aws \
      --docker-server=docker.iterative.ai \
      --docker-username=trial \
      --docker-password=letmetakealook
    $ kubectl patch serviceaccount default -p '{"imagePullSecrets":[{"name":"dvc-viewer-aws"}]}'
    ```
5. Copy `k8s/kustomization.yaml.example` to `k8s/kustomization.yaml`
6. Edit file for providing all needful data (needs to fill literals with REQUIRED comment)
7. Launch it `kustomize build . | kubectl apply -f -`

### with k8s (minikube)

8. Expose services
    ```
    $ kubectl port-forward service/dvc-viewer-backend 8000:8000
    $ kubectl port-forward service/dvc-viewer-ui 3000:3000
    ```
