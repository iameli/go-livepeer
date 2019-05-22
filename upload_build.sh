#!/bin/bash

# CI script for uploading builds.

set -e
set -o nounset

ARCH=$(uname | tr '[:upper:]' '[:lower:]')
BASE="livepeer-$ARCH-amd64"
BRANCH="${TRAVIS_BRANCH:-${CIRCLE_BRANCH:-unknown}}"
VERSION="$(cat VERSION)-$(git describe --always --long --dirty)"

# do a basic upload so we know if stuff's working prior to doing everything else
mkdir $BASE
mv ./livepeer $BASE
mv ./livepeer_cli $BASE
tar -czvf ./$BASE.tar.gz ./$BASE

# https://stackoverflow.com/a/44751929/990590
file=$BASE.tar.gz
bucket=build.livepeer.live
resource="/${bucket}/${VERSION}/${file}"
contentType="application/x-compressed-tar"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${GCLOUD_SECRET} -binary | base64`
curl -X PUT -T "${file}" \
  -H "Host: storage.googleapis.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${GCLOUD_KEY}:${signature}" \
  https://storage.googleapis.com${resource}

curl --fail -H "Content-Type: application/json" -X POST -d "{\"content\": \"Build succeeded ✅\nBranch: $BRANCH\nPlatform: $ARCH-amd64\nhttps://build.livepeer.live/$VERSION/$BASE.tar.gz\"}" $DISCORD_URL
echo "done"
