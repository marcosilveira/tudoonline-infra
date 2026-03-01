#!/bin/sh
set -eo pipefail

echo "### Starting DNS check records ###"

HOSTS=$(jq -r '.hosts[]' hosts-raw.json)

if [ -z "$HOSTS" ]; then
  echo "ERROR: No hosts found to check DNS!" >&2
  exit 1
fi

ERRORS=0
for HOST in $HOSTS; do
  STATUS=$(curl -L -s -o /dev/null -w '%{http_code}' "http://${HOST}/healthz" || true)
  if [ "$STATUS" -ne 200 ] && [ "$STATUS" -ne 308 ]; then
    echo "### WARNING: ${HOST} returned HTTP ${STATUS} — DNS may not be propagated yet or CNAME not set ###"
    ERRORS=$((ERRORS + 1))
  else
    echo "- ${HOST} - OK (HTTP 200)"
  fi
done

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "### DNS check completed with ${ERRORS} host(s) not yet ready. ###"
  echo "### Make sure customers have set CNAME: app → customers.sistemagrupoonline.com.br ###"
  echo "### Deploy will proceed anyway — cert-manager will retry until DNS propagates. ###"
fi

echo "### DNS check complete ###"