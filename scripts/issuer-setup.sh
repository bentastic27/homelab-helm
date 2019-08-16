#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
YAML_DIR=$SCRIPT_DIR/yaml

if [ -f $SCRIPT_DIR/../env.config ]; then
  source $SCRIPT_DIR/../env.config
else
  echo no env.config, bai
  exit
fi

echo $LE_EMAIL $KUBECONFIG

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

#kubectl apply -f $YAML_DIR/letsencrypt.yaml
#cat $YAML_DIR/letsencrypt.yaml | perl -p -e "s/LE_EMAIL/$LE_EMAIL/g" | kubectl apply -f -
cat <<EOF | kubectl apply -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${LE_EMAIL}
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource used to store the account's private key.
      name: letsencrypt-staging
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: ${LE_EMAIL}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable HTTP01 validations
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

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