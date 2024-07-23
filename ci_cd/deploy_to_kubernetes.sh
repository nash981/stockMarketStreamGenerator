#!/bin/bash
# Decrypt the kubeconfig file
echo "$KUBE_CONFIG" | base64 --decode > /tmp/kubeconfig
export KUBECONFIG=/tmp/kubeconfig

# Deploy the application to Kubernetes
kubectl apply -f k8s/kafka-deployment.yaml
kubectl apply -f k8s/producer-deployment.yaml
kubectl apply -f k8s/consumer-deployment.yaml
kubectl apply -f k8s/cassandra-deployment.yaml