#!/bin/bash


# Function to fetch pod metrics and insert into MongoDB
fetch_and_insert_metrics() {
    local pod_name=$1
    local namespace=$2
    local port=$3

    container_restart_count=$(kubectl get pod -n $namespace $pod_name -o jsonpath='{.status.containerStatuses[0].restartCount}')

    echo "Container restart count for pod $pod_name: $container_restart_count"

    # Fetch CPU and memory usage for the pod
    cpu_memory_usage=$(kubectl top pod $pod_name -n $namespace | tail -1)

    # Extract CPU and memory usage values
    cpu_usage=$(echo $cpu_memory_usage | awk '{print $2}')
    memory_usage=$(echo $cpu_memory_usage | awk '{print $3}')

    echo "CPU usage for pod $pod_name: $cpu_usage"
    echo "Memory usage for pod $pod_name: $memory_usage"
    echo "Port for pod $pod_name: $port"
    
    # Insert metrics into MongoDB
    python3 ../Utils/mongo_client.py insert $pod_name $cpu_usage $memory_usage $container_restart_count $port
}

# Function to get pod IDs
get_pod_ids() {
    local pod_name=$1
    local namespace=$2
    
    # Get pod ID using kubectl
    pod_id=$(kubectl get pods -n $namespace --selector=app=$pod_name -o jsonpath='{.items[*].metadata.name}')

    # Print pod ID
    echo $pod_id
}

# Main script
main() {
    print("---Fetching and inserting metrics for Vault secondary clusters...")
    initial_port=8204
    pod_names=("vault-secondary1" "vault-secondary2" "vault-secondary3")
    
    # Namespace where pods are located
    namespace="default"

    # Array to store pod IDs
    pod_IDS=()

    # Iterate over the array of pod names
    for pod_name in "${pod_names[@]}"; do
        # Get pod ID for each pod name
        pod_id=$(get_pod_ids "$pod_name" "$namespace")
        
        # Add pod ID to the array
        pod_IDS+=($pod_id)
    done

    # Print the list of pod IDs
    echo "Pod IDs:"
    printf '%s\n' "${pod_IDS[@]}"


    for pod_id in "${pod_IDS[@]}"; do
        # Get pod ID for each pod name
        fetch_and_insert_metrics "$pod_id" "$namespace" "$initial_port"
        initial_port=$(($initial_port + 2))
    done

    #Execute the next script that will determine the best cluster to use
    python3 ../Utils/determine.py
}

# Execute the main script
main
