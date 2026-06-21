#!/usr/bin/env bash
# Download the pinned OpenAPI spec from openapi-compat.properties (or OPENAPI_SPEC_URL override).
set -euo pipefail

OUT="${1:-openapi.yaml}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

read_prop() {
  bash "${SCRIPT_DIR}/read-compat-prop.sh" "$1" "${ROOT_DIR}/openapi-compat.properties"
}

if [[ -n "${OPENAPI_SPEC_URL:-}" ]]; then
  echo "OpenAPI spec: ${OPENAPI_SPEC_URL} (OPENAPI_SPEC_URL override)"
  bash "${SCRIPT_DIR}/fetch-openapi.sh" "${OPENAPI_SPEC_URL}" "${OUT}"
else
  REPO="$(read_prop openapi.spec.repo)"
  REF="$(read_prop openapi.spec.ref)"
  URL="https://raw.githubusercontent.com/${REPO}/${REF}/api/openapi.yaml"
  echo "OpenAPI spec: ${URL} (pinned ref ${REF} on ${REPO})"
  bash "${SCRIPT_DIR}/fetch-openapi.sh" "${URL}" "${OUT}"
fi

EXPECTED="$(read_prop openapi.api.version)"
ACTUAL="$(awk '/^info:/{found=1} found && /^  version:/{print $2; exit}' "${OUT}")"
if [[ -n "${ACTUAL}" && "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "::warning title=OpenAPI version mismatch::Spec has info.version=${ACTUAL}, openapi-compat.properties expects ${EXPECTED}. Update the pin or bump openapi.api.version." >&2
fi
