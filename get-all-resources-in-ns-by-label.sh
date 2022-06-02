#!/bin/bash
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 \
  kubectl get \
  --show-kind \
  --ignore-not-found \
  -l "${1}" -n "${2}"