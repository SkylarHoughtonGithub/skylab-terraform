#!/usr/bin/env bash
# Offline root CA for Skylab's trust layer. Replaces running step-ca just
# to produce a root cert + leaf certs for Roles Anywhere (and GCP WIF).
#
# Root key never leaves this machine. Back up $SKYLAB_CA_DIR somewhere
# durable (encrypted) before you rely on anything that trusts the root.
set -euo pipefail

CA_DIR="${SKYLAB_CA_DIR:-$HOME/.skylab-ca}"
ROOT_CRT="$CA_DIR/root.crt"
ROOT_KEY="$CA_DIR/root.key"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  init-root                  Generate the Skylab root CA. One-time.
  issue <name>               Issue a leaf cert signed by the root.
                             Writes <name>.crt and <name>.key under \$SKYLAB_CA_DIR.
                             Subject CN = <name>. 30d validity.
  install-k8s <name> <ns>    Create/replace a kubernetes.io/tls Secret named
                             <name>-client in <ns> from the issued files.
  show-root                  Print the root cert PEM (for terraform -var).
  list                       List issued leaf certs with expiry.

Env:
  SKYLAB_CA_DIR   CA working dir. Default: \$HOME/.skylab-ca
                  Chmod 700 on first use. Not under git.
EOF
}

require() { command -v "$1" >/dev/null || { echo "missing dep: $1" >&2; exit 1; }; }

init_root() {
  require step
  if [[ -e "$ROOT_KEY" ]]; then
    echo "root already exists at $ROOT_KEY — refusing to overwrite" >&2
    exit 1
  fi
  mkdir -p "$CA_DIR"
  chmod 700 "$CA_DIR"
  step certificate create "Skylab Root CA" "$ROOT_CRT" "$ROOT_KEY" \
    --profile root-ca \
    --kty EC --curve P-256 \
    --not-after 87600h \
    --no-password --insecure
  chmod 400 "$ROOT_KEY"
  echo "root ready: $ROOT_CRT"
  echo "back up $CA_DIR (encrypted) before issuing anything that matters."
}

issue() {
  require step
  local name="${1:-}"
  [[ -n "$name" ]] || { usage; exit 1; }
  [[ -e "$ROOT_KEY" ]] || { echo "no root — run init-root first" >&2; exit 1; }
  local crt="$CA_DIR/$name.crt"
  local key="$CA_DIR/$name.key"
  step certificate create "$name" "$crt" "$key" \
    --profile leaf \
    --ca "$ROOT_CRT" --ca-key "$ROOT_KEY" \
    --kty EC --curve P-256 \
    --not-after 720h \
    --no-password --insecure \
    --force
  chmod 400 "$key"
  echo "issued: $crt (CN=$name, 30d)"
}

install_k8s() {
  require kubectl
  local name="${1:-}" ns="${2:-}"
  [[ -n "$name" && -n "$ns" ]] || { usage; exit 1; }
  local secret="$name-client"
  local crt="$CA_DIR/$name.crt"
  local key="$CA_DIR/$name.key"
  [[ -e "$crt" && -e "$key" ]] || { echo "no cert for $name — run issue first" >&2; exit 1; }
  kubectl -n "$ns" create secret tls "$secret" \
    --cert="$crt" --key="$key" \
    --dry-run=client -o yaml | kubectl apply -f -
  echo "installed Secret $ns/$secret (tls.crt, tls.key)"
}

show_root() {
  [[ -e "$ROOT_CRT" ]] || { echo "no root — run init-root first" >&2; exit 1; }
  cat "$ROOT_CRT"
}

list_leaves() {
  require step
  shopt -s nullglob
  for crt in "$CA_DIR"/*.crt; do
    [[ "$crt" == "$ROOT_CRT" ]] && continue
    printf '%-30s  ' "$(basename "$crt" .crt)"
    step certificate inspect "$crt" --format json \
      | jq -r '"CN=" + .subject.common_name[0] + "  expires=" + .validity.end'
  done
}

cmd="${1:-}"
shift || true
case "$cmd" in
  init-root)   init_root ;;
  issue)       issue "$@" ;;
  install-k8s) install_k8s "$@" ;;
  show-root)   show_root ;;
  list)        list_leaves ;;
  ""|-h|--help) usage ;;
  *) usage; exit 1 ;;
esac
