from pymongo import MongoClient
from datetime import datetime

# MongoDB connection details
mongo_service_port = 41597
mongo_host = "mongodb://mongouser:mongopassword@127.0.0.1:" + str(mongo_service_port)
mongo_db = "metrics"  # Change this to your MongoDB database name
mongo_collection = "pod_metrics"  # Change this to your MongoDB collection name

# Function to insert metrics data into MongoDB
def insert_into_mongodb(resource_name, cpu_usage, memory_usage):
    try:
        client = MongoClient(host=mongo_host, directConnection=True)
        db = client[mongo_db]
        collection = db[mongo_collection]

        # Create document to insert
        document = {
            "resource_name": resource_name,
            "cpu_usage": cpu_usage,
            "memory_usage": memory_usage,
            "timestamp": datetime.now()
        }

        # Insert document into MongoDB collection
        collection.insert_one(document)
        print("Metrics data inserted into MongoDB successfully.")

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

        # Print retrieved data
        for doc in result:
            print("Resource Name:", doc["resource_name"])
            print("CPU Usage:", doc["cpu_usage"])
            print("Memory Usage:", doc["memory_usage"])
            print("Timestamp:", doc["timestamp"])

    except Exception as e:
        print("Error occurred while retrieving data from MongoDB:", e)

    finally:
        # Close MongoDB connection
        client.close()


# Example usage
if __name__ == "__main__":
    # Example data
    resource_name = "example_pod"
    cpu_usage = "100m"
    memory_usage = "256Mi"

    # Insert data into MongoDB
    #insert_into_mongodb(resource_name, cpu_usage, memory_usage)
    retrieve_from_mongodb(resource_name)