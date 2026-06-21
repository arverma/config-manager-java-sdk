#!/usr/bin/env bash
# Read a key from openapi-compat.properties (repo root by default).
set -euo pipefail

KEY="${1:?property key required}"
FILE="${2:-openapi-compat.properties}"

if [[ ! -f "${FILE}" ]]; then
  echo "Missing ${FILE}" >&2
  exit 1
fi

VALUE="$(grep -E "^${KEY}=" "${FILE}" | head -1 | cut -d= -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
if [[ -z "${VALUE}" ]]; then
  echo "Property ${KEY} not set in ${FILE}" >&2
  exit 1
fi

printf '%s' "${VALUE}"
