#!/usr/bin/env bash
set -euo pipefail

OPENAPI_URL="${1:?OpenAPI URL required}"
OUT="${2:-openapi.yaml}"

curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors \
  "${OPENAPI_URL}" -o "${OUT}"

if ! grep -q '^openapi:' "${OUT}"; then
  echo "Error: ${OUT} does not look like an OpenAPI spec (missing openapi: version line)" >&2
  exit 1
fi

echo "Fetched OpenAPI spec from ${OPENAPI_URL} ($(wc -c < "${OUT}" | tr -d ' ') bytes)"
