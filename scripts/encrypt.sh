#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/encrypt.sh --input plaintext.yaml --output bundles/dev.sops.yaml [--age-recipient AGE]

Encrypts a bootstrap secrets file with sops. You can set AGE_RECIPIENT env var instead of --age-recipient.
USAGE
  exit 1
}

INPUT=""
OUTPUT=""
RECIPIENT="${AGE_RECIPIENT:-}" # fallback to env var

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      INPUT="$2"; shift 2 ;;
    --output)
      OUTPUT="$2"; shift 2 ;;
    --age-recipient)
      RECIPIENT="$2"; shift 2 ;;
    -h|--help)
      usage ;;
    *)
      echo "Unknown flag: $1" >&2
      usage ;;
  esac
 done

[[ -n "$INPUT" && -n "$OUTPUT" ]] || usage

if [[ ! -f "$INPUT" ]]; then
  echo "Input file not found: $INPUT" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

if [[ -n "$RECIPIENT" ]]; then
  SOPS_AGE_RECIPIENTS="$RECIPIENT" \
    sops --encrypt "$INPUT" > "$OUTPUT"
else
  sops --encrypt "$INPUT" > "$OUTPUT"
fi

echo "Wrote $OUTPUT"
