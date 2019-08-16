#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source env.config

kubectl create namespace sites
helm install charts/beansnet-sites/ -f answers/beansnet.net.yml --name=beansnet-net --namespace=sites
helm install charts/beansnet-sites/ -f answers/pwgen.beansnet.net.yml --name=pwgen-beansnet-net --namespace=sites
helm install charts/beansnet-sites/ -f answers/risk.beansnet.net.yml --name=risk-beansnet-net --namespace=sites