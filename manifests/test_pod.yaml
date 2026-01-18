apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: ${namespace}
  labels:
    app: test-pod
    environment: ${environment}
    cluster: ${cluster_name}
spec:
  serviceAccountName: ${service_account_name}
  containers:
    - name: test-container
      image: ${image_uri}
      command: ["/bin/bash", "-c"]
      args:
        - |
          echo "Test Pod Running"
          echo "Bucket: ${bucket_name}"
          echo "Environment: ${environment}"
          echo "Cluster: ${cluster_name}"
          sleep 3600
      env:
        - name: S3_BUCKET_NAME
          value: ${bucket_name}
        - name: ENVIRONMENT
          value: ${environment}
        - name: CLUSTER_NAME
          value: ${cluster_name}
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "200m"
  restartPolicy: Never
