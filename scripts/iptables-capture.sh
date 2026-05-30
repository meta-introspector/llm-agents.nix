#!/usr/bin/env bash

set -euo pipefail

CHAIN="LLM_AGENTS_CAPTURE"
PROXY_PORT="${PROXY_PORT:-3128}"
PROXY_IP="${PROXY_IP:-127.0.0.1}"

usage() {
  cat <<'EOF'
Usage:
  sudo PROXY_PORT=3128 PROXY_IP=127.0.0.1 ./scripts/iptables-capture.sh install
  sudo ./scripts/iptables-capture.sh remove
  sudo ./scripts/iptables-capture.sh status

Environment:
  PROXY_PORT  Local proxy listener port to capture to (default: 3128)
  PROXY_IP    Local proxy listener address (default: 127.0.0.1)

Notes:
  - Captures locally generated TCP traffic in the nat OUTPUT chain.
  - Skips loopback destinations and traffic already headed to the proxy port.
  - Intended for use with a local proxy such as cli-proxy-api or srt.
EOF
}

ensure_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
  fi
}

install_rules() {
  ensure_root

  iptables -t nat -N "$CHAIN" 2>/dev/null || true
  iptables -t nat -F "$CHAIN"
  iptables -t nat -C OUTPUT -p tcp -j "$CHAIN" 2>/dev/null ||
    iptables -t nat -A OUTPUT -p tcp -j "$CHAIN"

  iptables -t nat -A "$CHAIN" -d 127.0.0.0/8 -j RETURN
  iptables -t nat -A "$CHAIN" -d "$PROXY_IP" -p tcp --dport "$PROXY_PORT" -j RETURN
  iptables -t nat -A "$CHAIN" -p tcp -j REDIRECT --to-ports "$PROXY_PORT"

  echo "Installed capture rules redirecting TCP OUTPUT to ${PROXY_IP}:${PROXY_PORT}."
}

remove_rules() {
  ensure_root

  iptables -t nat -D OUTPUT -p tcp -j "$CHAIN" 2>/dev/null || true
  iptables -t nat -F "$CHAIN" 2>/dev/null || true
  iptables -t nat -X "$CHAIN" 2>/dev/null || true

  echo "Removed capture rules."
}

show_status() {
  ensure_root
  iptables -t nat -S OUTPUT | rg "$CHAIN|REDIRECT" || true
  iptables -t nat -S "$CHAIN" 2>/dev/null || true
}

main() {
  case "${1:-}" in
  install)
    install_rules
    ;;
  remove)
    remove_rules
    ;;
  status)
    show_status
    ;;
  -h | --help | help | "")
    usage
    ;;
  *)
    echo "Unknown command: $1" >&2
    usage
    exit 1
    ;;
  esac
}

main "$@"
