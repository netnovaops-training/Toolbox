#!/usr/bin/env bash
# newfix.sh - shortcut for a quick troubleshooting ticket (same as: newentry.sh quick ...).
# Usage: bash code/local/newfix.sh <short-title> [tech ...]
exec bash "$(dirname "$0")/newentry.sh" quick "$@"
