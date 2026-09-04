#!/usr/bin/env bash
# Resets the lstk AWS demo environment between practice runs.
# Run from anywhere; it cd's into this script's own folder.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Resetting lstk demo (AWS, global config)"
lstk stop || true
lstk logout || true
lstk volume clear || true
rm -rf ~/.config/lstk

echo "==> Clearing local Terraform artifacts"
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
rm -f localstack_providers_override.tf

echo "==> Done. Demo folder and emulator are back to a first-run state."
