#!/usr/bin/env bash

# Set the image
# export IMAGE=docker.io/library/nginx:1.21.6

export IMAGE=docker.io/library/nginx
export NGINX_VERSION="1.21.6"

# Manifest Digest
export SHA256="2bcabc23b45489fb0885d69a06ba1d648aeda973fae7bb981bafbb884165e514"

docker pull "${IMAGE}:${NGINX_VERSION}@sha256:${SHA256}"

# Prints a ton of output, something like: Total: 434 (UNKNOWN: 13, LOW: 70, MEDIUM: 188, HIGH: 141, CRITICAL: 22)
trivy image --vuln-type os --ignore-unfixed "${IMAGE}:${NGINX_VERSION}@sha256:${SHA256}"

# Now we can patch it
copa patch \
  -i "${IMAGE}:${NGINX_VERSION}@sha256:${SHA256}" \
  -t "${NGINX_VERSION}-patched"
# I am running on WSL, ARM CPU.
--platform linux/arm64

# Review the docker history. Make note of the recent changes.
docker history nginx:${NGINX_VERSION}-patched-arm64 --format "table {{.ID}}\t{{.CreatedSince}}\t{{.Size}}\t{{.Comment}}"

# Now, there should be 0 or a lot less OS CVEs.
trivy image --vuln-type os --ignore-unfixed "nginx:${NGINX_VERSION}-patched-arm64"

# Now, you can push the new patched image to your ACR, and then deploy the new image. Update your Kubernetes deployments/manifests.
