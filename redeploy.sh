#/bin/bash
cd /root/oai-advance
git pull
cd charts/e2e_scenarios/case3
helm dependency update
helm uninstall oai-advance
sleep 2
helm install oai-advance .
