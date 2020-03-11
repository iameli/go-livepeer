#!/bin/bash

set -x
set -e

# docker build -t iameli/retry-test -f eli.Dockerfile .
# docker push iameli/retry-test
# kubectl delete pod -l livepeer.live/app=retry-test
kubectl rollout status deployment/retry-test
kubectl logs -f --all-containers deployment/retry-test &
kubectl port-forward deployment/retry-test 8936 &

wait