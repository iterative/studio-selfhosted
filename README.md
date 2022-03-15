# Studio On-Premise

This repository contains recipes for you to run Studio by Iterative on your own
infrastructure, using `docker-compose` or `k8s` or one of its flavors.

The guide will walk you through the preparation, customization, and basic
deployment scenarios.

## Prerequisites

### Getting the OAuth apps

In order to run Studio on premise, you'll need to setup your own GitHub or
GitLab OAuth apps and provide their credentials to Studio.

#### GitHub App

You need to create your own [GitHub App](https://docs.github.com/en/developers/apps/getting-started-with-apps/about-apps#about-github-apps) for being able to authorize on the provider side.
Redirect URI should be **${API_URL}/complete/gitlab/**

#### GitLab OAuth app

Please follow [the official guide](https://docs.gitlab.com/ee/integration/oauth_provider.html) to set it up.  
Redirect URI should be **${API_URL}/complete/gitlab/**

## Deployment

Studio is distributed via Iterative's private Docker registry as a set of
pre-built images.

We assume that Docker Compose and K8s will be the most common environments
Studio will be deployed to on premise.

### Deploying using Docker Compose

1. Your infrastructure needs to have
   [docker-compose v1.25 or newer](https://docs.docker.com/compose/install/) to
   run Studio.
2. [Login to the private registry](https://docs.docker.com/engine/reference/commandline/login/)
   ```
   $ docker login -u <login> -p <password> docker.iterative.ai
   ```
3. Configure `GITHUB_APP_CLIENT_ID=.. GITHUB_SECRET_KEY=.. ./install.sh` with variables
   from previous steps (or any other provider). You may also put this variables in `.env` file.  
   More info `./install --help`
4. Run `./install.sh`
5. Launch the stack `docker-compose up`

Please see [`docker-compose`](/docker-compose/) and generated `docker-compose.yaml` for more details.

### How to use custom root CA

For being able to use custom root CA you need to provide it to the containers.  
The best option is to build your custom images on top of Studio ones

**Backend**
```
FROM viewer_backend:latest

COPY ca.crt /usr/share/local/certificates/ca.crt
RUN cat /usr/share/local/certificates/ca.crt >> /usr/local/lib/python3.8/site-packages/certifi/cacert.pem
```

**Frontend**
```
FROM viewer_ui:latest

COPY ca.crt /usr/share/local/certificates/ca.crt
export NODE_EXTRA_CA_CERTS=/usr/share/local/certificates/ca.crt
```

**Install**  
For pointing custom https certificate use such command
```
./install.sh --url https://example.com \
    --tls-cert-file server.crt \
    --tls-key-file server.pem
```