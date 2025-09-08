# Simple CI Demo Infra - Startup Guide

This guide explains how to start the infrastructure for the Simple CI Demo project.

+---------+           (webhook / poll SCM)           +---------+            (upload images)           +---------+
| GitHub  |  ------------------------------------->  | Jenkins |  --------------------------------->  | Nexus3  |
|  Repo   |                                          |  CI/CD  |                                      |  Repo   |
+---------+                                          +---------+                                      +---------+
      |                                                    |                                               |
      |  source code                                       |  build/test/package image                     |  stores:
      |                                                    |                                               |
      |                                                    |                                               |
      |                                                    |  publish (docker push)                        |  - Docker images
      v                                                    v                                               v
  branches/tags ----------------------------------> pipeline stages ---------------------------------> repositories


## 1. Start ngrok to Expose Jenkins

```sh
ngrok http 8080
```

## 2. Start the Infrastructure (fresh start)

```sh
export GITHUB_PAT=$(echo Z2l0aHViX3BhdF8xMUFMM0pZSFEwaEd5VDFaQ1psQmcyX3JESWo4YXhtS2VHTHM4MmowZWJsUVlpWlNvNGFkWTdXelRabFJzblNxeHZSR09PWkFPVmp1cmQyQ0VtCg== | base64 -d)
export PUBLIC_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')
docker compose down -v && docker compose up --build
```

## 4. Initialize Nexus Repository

```sh
NEXUS_URL=http://localhost:8081 DOCKER_PORT=5000 NEXUS_PASS=admin123 ./init-nexus.sh
```

## 5. Update GitHub Webhook

Go to your GitHub repository settings and update the webhook with the following URL:

```
https://github.com/daoquocquyen/simple-ci-demo/settings/hooks/567784228
```
Set the "Payload URL" to:

```sh
${PUBLIC_URL}/github-webhook/
```
