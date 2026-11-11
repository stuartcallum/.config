#!/bin/sh
# git clean filter for zed/settings.json: strips machine/work-specific
# settings (proxy, ssh_connections) from what gets committed. The live
# file on disk is never modified.
awk '
  skip { if ($0 ~ "^" indent "\\],?[[:space:]]*$") skip = 0; next }
  /^[[:space:]]*"proxy":/ { next }
  /^[[:space:]]*"ssh_connections":[[:space:]]*\[/ {
    match($0, /^[[:space:]]*/); indent = substr($0, 1, RLENGTH); skip = 1; next
  }
  { print }
'
