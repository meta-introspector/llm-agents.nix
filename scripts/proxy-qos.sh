#!/usr/bin/env bash

set -euo pipefail

PROXY_URL="${PROXY_URL:-http://127.0.0.1:8080}"
TARGET_URL="${TARGET_URL:-${PROXY_URL}/v1/models}"
OUT_FILE="${OUT_FILE:-${HOME}/.local/state/llm-agents/proxy-qos.jsonl}"
COUNT="${COUNT:-1}"

mkdir -p "$(dirname "$OUT_FILE")"

for _ in $(seq 1 "$COUNT"); do
  start_ns=$(date +%s%N)
  body=$(mktemp)
  code=$(curl -sS -o "$body" -w '%{http_code}' "$TARGET_URL" || true)
  end_ns=$(date +%s%N)
  elapsed_ms=$(((end_ns - start_ns) / 1000000))
  status="ok"

  if [[ "$code" != 2* ]]; then
    status="error"
  fi

  jq -nc \
    --arg ts "$(date -Iseconds)" \
    --arg url "$TARGET_URL" \
    --arg code "$code" \
    --arg status "$status" \
    --argjson elapsed_ms "$elapsed_ms" \
    '{timestamp: $ts, url: $url, http_code: $code, status: $status, elapsed_ms: $elapsed_ms}' \
    >> "$OUT_FILE"
  rm -f "$body"
done

tail -n "$COUNT" "$OUT_FILE"
