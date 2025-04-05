#!/bin/bash

# Function to initialize and configure a Vault server
# Parameters:
#   - port: The port number to use for the Vault server
init_server() {
    local port=$1

    # Set the VAULT_ADDR environment variable to the Vault server address
    export VAULT_ADDR="http://127.0.0.1:$port"    
    
    # Run vault operator init and store the output
    output=$(vault operator init)

    # Extract the first three unseal keys and root token
    mapfile -t unseal_keys < <(echo "$output" | awk '/Unseal Key [1-3]:/{print $NF}')
    root_token=$(echo "$output" | awk '/Initial Root Token:/{print $NF}')

    # Print the extracted information
    echo "First Unseal Key: ${unseal_keys[0]}"
    echo "Second Unseal Key: ${unseal_keys[1]}"
    echo "Third Unseal Key: ${unseal_keys[2]}"
    echo "Root Token: $root_token"
    
    # Set the VAULT_TOKEN environment variable to the root token
    export VAULT_TOKEN=$root_token

    # Unseals the Vault server using the provided unseal keys. Note, only three keys are needed to unseal the Vault server.
    # Unsealing Vault is important to access the encrypted data stored in the Vault server and to perform administrative tasks.
    for key in "${unseal_keys[@]}"; do
        vault operator unseal $key
    done

    # Check the status of the Vault server. This should show the status of the Vault server and the number of unseal keys provided.
    vault status

    # Look up the details of the current Vault token
    vault token lookup

    # Enable the Key/Value version 2 secrets engine at the path "secrets"
    vault secrets enable -path=secret -version=2 kv
}


# Initialize and configure the primary Vault server
init_server $1
