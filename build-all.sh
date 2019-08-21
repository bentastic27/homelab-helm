#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -f $SCRIPT_DIR/env.config ]; then
  source $SCRIPT_DIR/env.config
else
  echo no env.config, bai
  exit
fi
cd $SCRIPT_DIR

# init helm and cert-manager
bash scripts/init-helm.sh
bash scripts/init-cert-manager.sh

# setup cert manager
helm install charts/cert-manager/ -f answers/cluster-issuer.yml --name cluster-issuer --namespace=cert-manager

# setup sites
kubectl create namespace sites
helm install charts/beansnet-sites/ -f answers/pwgen.beansnet.net.yml --name=pwgen-beansnet-net --namespace=sites
helm install charts/beansnet-sites/ -f answers/beansnet.net.yml --name=beansnet-net --namespace=sites
helm install charts/beansnet-sites/ -f answers/risk.beansnet.net.yml --name=risk-beansnet-net --namespace=sites