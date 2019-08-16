#!/bin/bash
YAML_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/yaml

kubectl apply -f $YAML_DIR/selfsigning-issuer.yaml
kubectl apply -f $YAML_DIR/selfsign-test.yaml

if kubectl get secrets my-selfsigned-cert -o yaml | grep -q tls.crt; then
  echo
  echo self signing issuer works! cert-manager should be ready to roll.
  echo
else
  echo
  echo self signing issuer seems to be broken.
  echo
fi

kubectl delete -f $YAML_DIR/selfsign-test.yaml
kubectl apply -f $YAML_DIR/letsencrypt.yaml
kubectl apply -f $YAML_DIR/letsencrypt-staging-test.yaml

if kubectl get secrets my-letsencrypt-staging-cert -o yaml | grep -q tls.crt; then
  echo
  echo LE staging issuer works! cert-manager should be ready to roll.
  echo
else
  echo
  echo LE staging issuer seems to be broken.
  echo
fi

kubectl delete -f $YAML_DIR/letsencrypt-staging-test.yaml