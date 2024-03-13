# software-architecture-vault


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

