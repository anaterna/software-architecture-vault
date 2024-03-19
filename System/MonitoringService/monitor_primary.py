import subprocess
import time
import json
import sys

def check_vault_primary_status(app_label):
    # Define the kubectl command to check the status of Vault pods
    kubectl_command = f"kubectl get pods -l app={app_label} -o json"

    try:
        # Execute the kubectl command
        output = subprocess.check_output(kubectl_command, shell=True)
        output = output.decode('utf-8')
        
        # Parse the JSON output
        pods = json.loads(output)["items"]

        # Check if any pod is in a failed state
        for pod in pods:
            pod_name = pod["metadata"]["name"]
            pod_status = pod["status"]["phase"]
            if pod_status != "Running":
                print(f"Primary Vault pod {pod_name} is not running (status: {pod_status}).")
                return False
        
        print("-- Primary Vault is running --")
        return True

    except Exception as e:
        print("Error occurred while checking Vault pod status:", e)
        return False

def main(app_label):
    # Continuous monitoring loop
    while True:
        # Check Vault primary status
        if not check_vault_primary_status(app_label):
            # If primary Vault is not running, delegate to the request metrics service
            print("---Delegating to the request metrics service...")
            subprocess.run(["../RequestMetrics/request_metrics.sh"])  
            break  # Exit the loop after executing the script

        # Wait for a specified interval before checking again
        time.sleep(60)  # Adjust the interval as needed

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 monitor_primary.py <app_label>")
        sys.exit(1)
    main(sys.argv[1])