#!/bin/bash
# Usage: ./test.sh http://<instance-ip>:<port> <api-key> [model]
URL="${1:?Base URL, e.g. http://1.2.3.4:40123}"
KEY="${2:?API key}"
MODEL="${3:-Qwen/Qwen3-8B}"

curl -s "$URL/v1/chat/completions" \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d "{\"model\": \"$MODEL\", \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one sentence.\"}]}"
echo
