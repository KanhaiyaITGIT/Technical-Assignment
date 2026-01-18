#!/bin/bash
set -e

echo "Starting Test Pod validation..."

# 1. List all namespaces
echo "Listing all namespaces..."
kubectl get namespaces

# 2. Default namespace access (should fail)
echo "Trying to list pods in default namespace..."
kubectl get pods -n default || echo "Access denied as expected"

# 3. kube-system (should fail)
echo "Trying to list pods in kube-system..."
kubectl get pods -n kube-system || echo "Access denied as expected"

# 4. rbac-a read-only
echo "Listing pods in rbac-a..."
kubectl get pods -n rbac-a

echo "Trying to create deployment in rbac-a (should fail)..."
kubectl run test-deploy --image=nginx -n rbac-a || echo "Create denied as expected"

# 5. rbac-b full access
echo "Listing pods in rbac-b..."
kubectl get pods -n rbac-b

echo "Creating deployment in rbac-b..."
kubectl run test-deploy --image=nginx -n rbac-b

echo "Deleting deployment in rbac-b..."
kubectl delete deployment test-deploy -n rbac-b

# 6. S3 bucket access via IRSA
echo "Testing S3 read/write access..."
aws s3 ls s3://$S3_BUCKET_NAME
echo "Uploading test file..."
echo "test data" > /tmp/testfile.txt
aws s3 cp /tmp/testfile.txt s3://$S3_BUCKET_NAME/
echo "Downloading test file..."
aws s3 cp s3://$S3_BUCKET_NAME/testfile.txt /tmp/testfile_download.txt
cat /tmp/testfile_download.txt

echo "Test Pod validation complete!"
