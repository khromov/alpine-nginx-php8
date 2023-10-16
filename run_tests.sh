#!/usr/bin/env sh
apk --no-cache add curl
echo "Waiting for process to start..."
sleep 10
curl --silent --fail http://app:8080 | grep 'PHP 8.0.30'
