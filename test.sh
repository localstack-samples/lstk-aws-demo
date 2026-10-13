#!/bin/bash
# Check the static website deployed by main.tf: the bucket serves index.html
# at the root and error.html with a 404 for unknown keys.
set -euo pipefail

ENDPOINT=$(lstk tf output -raw website_endpoint)
echo "Website: $ENDPOINT"

index_document=$(lstk aws s3api get-bucket-website --bucket lstk-demo-website \
  --query IndexDocument.Suffix --output text)
if [ "$index_document" != "index.html" ]; then
  echo "Test failed: website index document is '$index_document'"
  exit 1
fi
echo "PASS: bucket website config uses index.html"

body=$(curl -s -m 10 -w '\n%{http_code}' "$ENDPOINT/")
status=${body##*$'\n'}
if [ "$status" != "200" ] || [[ "$body" != *"Static Website, Deployed Locally"* ]]; then
  echo "Test failed: GET / returned HTTP $status"
  exit 1
fi
echo "PASS: GET / served index.html"

body=$(curl -s -m 10 -w '\n%{http_code}' "$ENDPOINT/does-not-exist")
status=${body##*$'\n'}
if [ "$status" != "404" ] || [[ "$body" != *"<title>404</title>"* ]]; then
  echo "Test failed: GET /does-not-exist returned HTTP $status without error.html"
  exit 1
fi
echo "PASS: unknown key served error.html with a 404"

echo "Test passed: the static website is live"
