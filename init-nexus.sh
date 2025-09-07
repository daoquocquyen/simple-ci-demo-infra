#!/usr/bin/env bash
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://localhost:8081}"
DOCKER_PORT="${DOCKER_PORT:-5000}"
ADMIN_PASS_FILE="/nexus-data/admin.password"
NEXUS_PASS="${NEXUS_PASS:-admin123}"
REPO_PREFIX="${REPO_PREFIX:-}"  # optional prefix for repo names

echo "==> Waiting for Nexus at ${NEXUS_URL} to be ready..."
# Wait for the service endpoint to report ready
for i in {1..120}; do
  if curl -fsS "${NEXUS_URL}/service/rest/v1/status" >/dev/null 2>&1; then
    break
  fi
  sleep 3
done

if ! curl -fsS "${NEXUS_URL}/service/rest/v1/status" >/dev/null 2>&1; then
  echo "Nexus did not become ready in time" >&2
  exit 1
fi
echo "==> Nexus is up."

INITIAL_PASS="$(docker exec nexus cat "${ADMIN_PASS_FILE}")"

# Change the admin password (only once). If already changed, this will likely return 4xx; ignore errors.
echo "==> Attempting to set admin password via REST API..."
set +e
curl -sS -u "admin:${INITIAL_PASS}" -X PUT \
  -H "Content-Type: text/plain" \
  --data "${NEXUS_PASS}" \
  "${NEXUS_URL}/service/rest/v1/security/users/admin/change-password" >/dev/null
CHANGE_RC=$?
set -e
if [ $CHANGE_RC -eq 0 ]; then
  echo "==> Admin password set."
else
  echo "==> Admin password change may have already been applied; continuing."
fi

AUTH="-u admin:${NEXUS_PASS}"

# Create Maven hosted: releases
echo "==> Creating Maven hosted (releases) repository..."
curl -sS ${AUTH} -H "Content-Type: application/json" \
  -X POST "${NEXUS_URL}/service/rest/v1/repositories/maven/hosted" \
  --data @- <<EOF
{
  "name": "maven-releases",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true,
    "writePolicy": "ALLOW_ONCE"
  },
  "cleanup": {
    "policyNames": []
  },
  "component": {},
  "maven": {
    "versionPolicy": "RELEASE",
    "layoutPolicy": "STRICT",
    "contentDisposition": "INLINE"
  }
}
EOF

echo
# Create Docker hosted
echo "==> Creating Docker hosted repository (HTTP connector on port ${DOCKER_PORT})..."
# Patch the httpPort in the payload on the fly to match DOCKER_PORT
curl -sS ${AUTH} -H "Content-Type: application/json" \
  -X POST "${NEXUS_URL}/service/rest/v1/repositories/docker/hosted" \
  --data @- <<EOF
{
  "name": "docker-hosted",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true,
    "writePolicy": "ALLOW"
  },
  "cleanup": {
    "policyNames": []
  },
  "component": {},
  "docker": {
    "v1Enabled": false,
    "forceBasicAuth": true,
    "httpPort": ${DOCKER_PORT}
  }
}
EOF
echo
echo "==> Accepting EULA"
curl ${AUTH} -X POST "${NEXUS_URL}/service/rest/v1/system/eula" -H "Content-Type: application/json" -d '{"accepted" : true,"disclaimer" : "Use of Sonatype Nexus Repository - Community Edition is governed by the End User License Agreement at https://links.sonatype.com/products/nxrm/ce-eula. By returning the value from ‘accepted:false’ to ‘accepted:true’, you acknowledge that you have read and agree to the End User License Agreement at https://links.sonatype.com/products/nxrm/ce-eula."}'

echo
echo "==> Enabling Docker Bearer Token Realm"
curl ${AUTH} -X PUT -H "Content-Type: application/json" -d '["DockerToken", "NexusAuthenticatingRealm"]' ${NEXUS_URL}/service/rest/v1/security/realms/active

echo "==> Done. Repositories:"
curl -sS ${AUTH} "${NEXUS_URL}/service/rest/v1/repositories" | jq -r '.[] | "\(.format)  \(.type)  \(.name)"'
echo "==> You can now:"
echo "    - Access UI: ${NEXUS_URL}"
echo "    - Docker login/push to: <host>:${DOCKER_PORT}"
