import time
import hvac
import os

# Vault address and root token for authenticating with the Vault cluster
vault_url = os.environ.get("VAULT_ADDR")
vault_token = os.environ.get("VAULT_TOKEN")

# Initiate Vault client to interact with the Vault cluster
client = hvac.Client(url=vault_url, token=vault_token)

# Function to create a new secret in the Vault cluster using the path and data provided
# The path is where the secret will be stored in the Vault cluster
# The data is the actual secret to be stored in the Vault cluster
def create_secret(path, data):
    response = client.secrets.kv.v2.create_or_update_secret(path=path, secret=data)
    if "errors" in response:
        errors = response["errors"]
        print(f"Failed to create secret. Errors: {errors}")
    else:
        data = response["data"]

        created_time = data["created_time"]
        version = data["version"]

        print(f"Created secret in path: " + path)
        print(f"  Created Time: {created_time}")
        print(f"  Version: {version}")
    

# Retrieve the secret from Vault cluster using the path where the secret is stored
def retrieve_secret(path):
    response = client.secrets.kv.v2.read_secret_version(path=path, raise_on_deleted_version=True)
    if "errors" in response:
        errors = response["errors"]
        print(f"Failed to retrieve secret. Errors: {errors}")
    else:
        data = response["data"]
        metadata = data["metadata"]
        created_time = metadata.get("created_time", "N/A")
        version = metadata.get("version", "N/A")

        print(f"Retrieved secret:")
        print(f"  Created Time: {created_time}")
        print(f"  Version: {version}")

        secret_data = data.get("data", {})
        for key, value in secret_data.items():
            print(f"  {key}: {value}")
    

def main():
    # Path to store the secret
    secret_path = "secret/my-secret"
    # Create a new secret
    secret_data = {"username": "admin", "password": "admin123"}
    create_secret(path=secret_path, data=secret_data)
    while True:
        # Retrieve the secret
        retrieve_secret(path=secret_path)
        # Wait for 5 seconds before the next iteration
        time.sleep(5)

if __name__ == "__main__":
    main()
