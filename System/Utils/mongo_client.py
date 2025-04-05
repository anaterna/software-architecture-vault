from pymongo import MongoClient
from datetime import datetime
import sys
import json

# MongoDB connection details
mongo_service_port = 36099
mongo_host = "mongodb://mongouser:mongopassword@127.0.0.1:" + str(mongo_service_port)
mongo_db = "metrics"  # Change this to your MongoDB database name
mongo_collection = "pod_metrics"  # Change this to your MongoDB collection name

# Function to insert metrics data into MongoDB
def insert_into_mongodb(resource_name, cpu_usage, memory_usage, pod_port, container_restart_count):
    try:
        client = MongoClient(host=mongo_host, directConnection=True)
        db = client[mongo_db]
        collection = db[mongo_collection]

        # Create document to insert
        document = {
            "resource_name": resource_name,
            "cpu_usage": cpu_usage,
            "memory_usage": memory_usage,
            "container_restart_count": container_restart_count,
            "port": pod_port,
        }

        # Insert document into MongoDB collection
        collection.insert_one(document)
        print("Metrics data inserted into MongoDB successfully.")
        #collection.delete_many({})
    except Exception as e:
        print("Error occurred while inserting data into MongoDB:", e)

    finally:
        # Close MongoDB connection
        client.close()


# Function to retrieve metrics data from MongoDB based on pod name
def retrieve_from_mongodb(pod_name):
    try:
        client = MongoClient(host=mongo_host, directConnection=True)
        db = client[mongo_db]
        collection = db[mongo_collection]

        # Query MongoDB collection based on pod name
        query = {"resource_name": pod_name}
        result = collection.find(query)

        # Convert cursor to list of dictionaries
        data = list(result)

        # Print retrieved data
        for doc in data:
            print("Resource Name:", doc["resource_name"])
            print("CPU Usage:", doc["cpu_usage"])
            print("Memory Usage:", doc["memory_usage"])
            print("Port:", doc["port"])
            print("Container Restart Count:", doc["container_restart_count"])

        if data:
            # Return the retrieved data as JSON string
            return data
        else:
            return json.dumps({"error": f"No data found for pod {pod_name}"})
        
    except Exception as e:
        print("Error occurred while retrieving data from MongoDB:", e)

    finally:
        # Close MongoDB connection
        client.close()


if __name__ == "__main__":
    # Check if the correct number of arguments is provided
    if len(sys.argv) < 2:
        print("Usage: python script.py <function_name> [arguments]")
        sys.exit(1)

    function_name = sys.argv[1]

    # Call the specified function based on the command-line argument
    if function_name == "insert":
        # Check if the correct number of arguments is provided
        if len(sys.argv) < 5:
            print("Usage: python script.py insert <resource_name> <cpu_usage> <memory_usage> <container_restart_count> <pod_port>")
            sys.exit(1)

        resource_name = sys.argv[2]
        cpu_usage = sys.argv[3]
        memory_usage = sys.argv[4]
        container_restart_count = sys.argv[5]
        pod_port = sys.argv[6]

        insert_into_mongodb(resource_name, cpu_usage, memory_usage, pod_port, container_restart_count)

    elif function_name == "retrieve":
        # Check if the correct number of arguments is provided
        if len(sys.argv) != 3:
            print("Usage: python script.py retrieve <pod_name>")
            sys.exit(1)

        pod_name = sys.argv[2]
        retrieve_from_mongodb(pod_name)

    else:
        print("Invalid function name. Available functions: insert, retrieve")
        sys.exit(1)