#!/bin/bash

# This script is used to run stress tests on Vault clusters. 
# It applies a YAML template file to create chaos scenarios for each pod in the cluster.

# The YAML template file to be used for creating chaos scenarios
yaml_template="chaos-stress.yaml"

# Array of pod names and namespaces
pods=("vault-primary" "vault-secondary1" "vault-secondary2" "vault-secondary3")
namespaces=("stress-test-primary" "stress-test-secondary1" "stress-test-secondary2" "stress-test-secondary3")

# Loop through each pod and namespace
for i in "${!pods[@]}"; do
    pod_name="${pods[$i]}"
    namespace="${namespaces[$i]}"

    # Generate a unique YAML file for each pod
    yaml_file="stress-chaos-$i.yaml"

    # Replace placeholders in the template YAML file with actual values
    sed -e "s/SCENARIO_NAME/$namespace/g" -e "s/POD_NAME/$pod_name/g" "$yaml_template" > "$yaml_file"

    cat "$yaml_file"
    # Apply the generated YAML to create chaos scenario
    kubectl apply -f "$yaml_file"

    # Remove the generated YAML file
done
