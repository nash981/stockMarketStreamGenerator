#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
for cmd in kubectl docker mvn; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# Set variables
DOCKER_REGISTRY="nash981"
PROJECT_ROOT=$(pwd)

# Step 1: Build Java Applications
echo "Building Java applications..."
cd "$PROJECT_ROOT/kafka-producer"
mvn clean package
cd "$PROJECT_ROOT/kafka-consumer"
mvn clean package


pwd
# Step 2: Build Docker Images
echo "Building Docker images..."
cd "$PROJECT_ROOT"
docker build -t $DOCKER_REGISTRY/kafka:latest -f docker/Dockerfile.kafka .
pwd
docker build -t $DOCKER_REGISTRY/stock-data-producer:latest -f docker/Dockerfile.producer .
docker build -t $DOCKER_REGISTRY/stock-data-consumer:latest -f docker/Dockerfile.consumer .
docker build -t $DOCKER_REGISTRY/cassandra:latest -f docker/Dockerfile.cassandra .

# Step 3: Push Docker Images
echo "Pushing Docker images..."
docker push $DOCKER_REGISTRY/kafka:latest
docker push $DOCKER_REGISTRY/stock-data-producer:latest
docker push $DOCKER_REGISTRY/stock-data-consumer:latest
docker push $DOCKER_REGISTRY/cassandra:latest

# Step 4: Deploy Kafka
echo "Deploying Kafka..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/kafka-deployment.yaml

# Step 5: Deploy Cassandra
echo "Deploying Cassandra..."
kubectl apply -f k8s/cassandra-service.yaml
kubectl apply -f k8s/cassandra-deployment.yaml

# Step 6: Deploy Producer and Consumer
echo "Deploying Producer and Consumer..."
kubectl apply -f k8s/producer-deployment.yaml
kubectl apply -f k8s/consumer-deployment.yaml

# Step 7: Validate Deployments
echo "Validating deployments..."
kubectl get deployments
kubectl get pods
kubectl get svc

# Step 8: Access Applications (example for Minikube)
if command_exists minikube; then
    echo "Accessing Kafka service URL:"
    minikube service kafka --url
else
    echo "Minikube not found. Please access your services according to your Kubernetes setup."
fi

# Step 9: TravisCI setup (informational)
echo "Ensure your .travis.yml and deploy_to_kubernetes.sh are correctly configured in your repository."

# Step 10: Git push (optional)
read -p "Do you want to push changes to GitHub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git add .
    git commit -m "Automated deployment"
    git push origin main
fi

echo "Deployment script completed successfully!"