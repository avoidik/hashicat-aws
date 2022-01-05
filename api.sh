#!/bin/bash

TOKEN="$(jq -r '.credentials | .[] | .token' ~/.terraform.d/credentials.tfrc.json)"
ORG="graceful-hippo"
WORKSPACE="$(curl -s -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/vnd.api+json" https://app.terraform.io/api/v2/organizations/${ORG}/workspaces/hashicat-aws 2> /dev/null | jq -r .data.id)"

echo
echo "ORG = $ORG"
echo "WORKSPACE = $WORKSPACE"
echo 

curl -s -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -X POST \
  --data @json/var-placeholder.json \
  https://app.terraform.io/api/v2/workspaces/${WORKSPACE}/vars

curl -s -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -X POST \
  --data @json/var-height.json \
  https://app.terraform.io/api/v2/workspaces/${WORKSPACE}/vars

curl -s -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -X POST \
  --data @json/var-width.json \
  https://app.terraform.io/api/v2/workspaces/${WORKSPACE}/vars

curl -s \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/workspaces/${WORKSPACE}/vars | jq -r '.data[] | .attributes | "k = \(.key), v = \(.value)"'

curl -s -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -X POST \
  --data "$(cat json/apply.json | jq -r --arg w $WORKSPACE '.data.relationships.workspace.data.id = $w')" \
  https://app.terraform.io/api/v2/runs
