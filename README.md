# Vault Automatic Diasater Recovery System

This repository contains the POC of 

## Prerequisites:
- Install [Kubernetes minikube](https://minikube.sigs.k8s.io/docs/start/)
- `minikube start`
- cd in the directory of configurations you want to deploy
- `kubectl apply -f <your-yaml>.yaml`
- check if everything is running: kubectl get
- install valut cli
- `export VAULT_ADDR=http://127.0.0.1:8200`
- `kubectl port-forward service/vault 8200:8200`
- `vault status`
- ` export VAULT_TOKEN=<token configured in the secret>` 
- `vault token lookup `
- `vault kv put secret/data username=admin password=admin123`
- `vault kv get secret/data`



 Enable metrics service
`helm repo add chaos-mesh https://charts.chaos-mesh.org`
 `helm install chaos-mesh chaos-mesh/chaos-mesh --namespace chaos-testing --create-namespace`
 
`kubectl get pods --namespace chaos-testing -l app.kubernetes.io/instance=chaos-mesh`
 `kubectl apply -f https://raw.githubusercontent.com/pythianarora/total-practice/master/sample-kubernetes-code/metrics-server.yaml`



To run Mongo server

`minikube service list`
`minikube service mongo-service`
Use the port with IP address `127.0.0.1` and keep the terminal running. Config this port in the mongo_client.py