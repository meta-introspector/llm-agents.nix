#!/usr/bin/env bash

set -euo pipefail

pkg_name="${1:-}"
timeout_seconds="${TIMEOUT_SECONDS:-10}"
manifest="${MANIFEST:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/connection-tests.tsv}"

if [[ -z "$pkg_name" ]]; then
  echo "usage: connection-test.sh <package>" >&2
  exit 1
fi

command_spec="--help"
if [[ -f "$manifest" ]]; then
  match=$(awk -F '\t' -v pkg="$pkg_name" '$1 == pkg { print $2; exit }' "$manifest" || true)
  if [[ -n "$match" ]]; then
    command_spec="$match"
  fi
fi

output=$(mktemp)
if timeout "$timeout_seconds" nix run ".#${pkg_name}" -- "$command_spec" >"$output" 2>&1; then
  status="ok"
else
  status="fail"
fi

model=$(jq -r '.[0].model // empty' "$output" 2>/dev/null || true)
quota=$(jq -r '.[0].quota // empty' "$output" 2>/dev/null || true)

jq -nc \
  --arg pkg "$pkg_name" \
  --arg command "$command_spec" \
  --arg status "$status" \
  --arg model "$model" \
  --arg quota "$quota" \
  '{package:$pkg, command:$command, status:$status, model:($model|select(length>0)), quota:($quota|select(length>0))}'

rm -f "$output"
