#!/bin/bash

# Function used to deploy a Vault cluster with the provided port and Vault token
deploy_vault() {
  local port=$1
  local token=$2
  local namespace=$3
  # Replace ARG_PORT and ARG_TOKEN with the provided arguments in the Kubernetes configuration file
  sed -e "s/ARG_PORT/$port/g" -e "s/ARG_TOKEN/$token/g" -e "s/NAMESPACE/$namespace/g" -e "s/ND_PORT/$(($port + 1))/g" vault-deployment.yaml > vault-config-$port.yaml

  # Apply Kubernetes configuration
  kubectl apply -f vault-config-$port.yaml

  # Display the applied configuration   
  cat vault-config-$port.yaml
    
  # Clean up temporary YAML file
  rm vault-config-$port.yaml
}


confg_cluster_ip() {
    local namespace=$1
    local port=$2

    # Define the HCL file
    HCL_FILE="vault-config.hcl"

    # Replace placeholder values in the HCL file
    sed -i "s/ARG_PORT/$port/g" $HCL_FILE
    sed -i "s/ND_PORT/$(($port + 1))/g" $HCL_FILE

    # Output the modified HCL file (optional)
    cat $HCL_FILE
    # Get the pod name
    pod_name=$(kubectl get pods -l app=vault-secondary1 -o custom-columns=:metadata.name --no-headers | grep '$namespace')
    echo "Pod Name: $pod_name"
    # Get the root token from the primary Vault
    root_token=$(kubectl logs $pod_name | grep 'Root Token' | cut -d' ' -f3)

    echo "Root Token: $root_token"

    export VAULT_ADDR=http://0.0.0.0:8200
    export VAULT_TOKEN=$root_token
    kubectl port-forward service/vault 8200:8200

    vault server -config=vault-config.hcl
}

# Deploy primary Vault cluster
# deploy_vault 8200 primary-token primary

deploy_vault 8202 secondary1-token secondary1

# Wait for the primary Vault to be ready before deploying secondaries
echo "Waiting for primary Vault to be ready..."
kubectl wait --for=condition=Ready pod -l app=vault-secondary1 --timeout=300s

confg_cluster_ip vault-secondary1 8202


# # Deploy secondary Vault clusters
# deploy_vault 8202 secondary1-token secondary1
# deploy_vault 8204 secondary2-token secondary2
# deploy_vault 8206 secondary3-token secondary3