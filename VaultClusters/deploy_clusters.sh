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

# Deploy primary Vault cluster
deploy_vault 8202 primary-token primary


# Wait for the primary Vault to be ready before deploying secondaries
echo "Waiting for primary Vault to be ready..."
kubectl wait --for=condition=Ready pod -l app=vault-primary --timeout=300s


# Deploy secondary Vault clusters
deploy_vault 8204 secondary1-token secondary1
deploy_vault 8206 secondary2-token secondary2
deploy_vault 8208 secondary3-token secondary3