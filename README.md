# AWS Infrastructure Project

Production-ready infrastructure on AWS using Terraform, EKS, and Kubernetes RBAC with S3 integration.

## 🎯 What This Project Does

This project creates a complete, secure, and scalable cloud infrastructure with:

- **Multi-tier Network** - Public/Private subnets with proper segmentation
- **Managed Kubernetes** - EKS cluster with public control plane and private worker nodes
- **Cloud Storage** - S3 bucket with workload identity integration (IRSA)
- **Access Control** - Kubernetes RBAC with namespace-level permissions
- **Security Best Practices** - Network segmentation, least privilege access, encryption

Everything is Infrastructure as Code using Terraform - reproducible, versioned, and production-ready.

---

## 🏗️ Architecture Overview

### Network Layer
```
VPC (10.0.0.0/16)
├── Public Subnets (2) → Internet Gateway → Internet
│   └── NAT Gateway
├── Private Subnets (2) → NAT Gateway → Internet
│   └── EKS Worker Nodes (here)
├── Database Subnet (1) → NAT Gateway
└── Cache Subnet (1) → NAT Gateway
```

### Kubernetes Layer
```
EKS Cluster
├── Control Plane (Public Endpoint)
├── Worker Nodes (Private Subnets)
├── Namespaces: rbac-a, rbac-b
├── Service Account: rbac-test-sa
└── RBAC Roles (Cluster-wide, Namespace-level)
```

### Storage Layer
```
S3 Bucket
├── Encryption: AES256
├── Versioning: Enabled
├── Access: Via IRSA (IAM Roles for Service Accounts)
└── Permissions: Read/Write via Pod Identity
```

---

## 📋 Key Features

### Network Infrastructure
| Component | Count | Purpose |
|-----------|-------|---------|
| Public Subnets | 2 | Internet-facing resources, NAT Gateway |
| Private Subnets | 2 | Application workloads, EKS nodes |
| Database Subnet | 1 | Database tier (isolated) |
| Cache Subnet | 1 | Caching layer (isolated) |
| NAT Gateway | 1 | Private subnet internet access |
| Security Groups | 1 | Internal communication rules |

**CIDR Sizing:**
- Public: `/22` = 1,024 IPs each
- Private: `/20` = 4,096 IPs each
- Database: `/24` = 256 IPs
- Cache: `/24` = 256 IPs

### Kubernetes Cluster
- **Type:** AWS EKS (Elastic Kubernetes Service)
- **Control Plane:** Publicly accessible
- **Worker Nodes:** Private subnets only
- **Pod Network:** Private subnets only
- **OIDC Provider:** Configured for IRSA

### Access Control (RBAC)
```
rbac-test-sa Service Account (default namespace)
├── Cluster-wide: List namespaces only
├── rbac-a namespace: Read-only (pods, services, deployments)
├── rbac-b namespace: Full access (create, update, delete)
└── S3 Storage: Read/Write via IRSA
```

### Storage
- **Bucket:** Encrypted (AES256), versioning enabled
- **Access Control:** IRSA (no hardcoded credentials)
- **Service Account:** Automatically authenticated via pod identity

---

## 🚀 Quick Start

### Prerequisites
```bash
# Required tools
- Terraform >= 1.0
- AWS CLI v2 configured
- kubectl
- Git

# AWS Requirements
- Valid AWS account
- Appropriate IAM permissions
- VPC quota available
```

### Deployment (3 Steps)

1. **Configure Variables**
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

2. **Deploy Infrastructure**
```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

3. **Verify Setup**
```bash
# Get cluster credentials
aws eks update-kubeconfig --name <cluster_name> --region <aws_region>

# Check cluster
kubectl cluster-info
kubectl get namespaces
kubectl get pods -n rbac-a
```

**Deployment Time:** ~45 minutes

---

## 📁 Project Structure

```
.
├── main.tf                          # Module orchestration
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
├── providers.tf                     # AWS, Kubernetes, TLS providers
├── versions.tf                      # Provider version constraints
├── terraform.tfvars.example         # Example configuration
│
├── modules/
│   ├── vpc/                         # Network infrastructure
│   │   ├── main.tf                  # VPC, subnets, gateways
│   │   ├── security_group.tf        # Security group rules
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks/                         # Kubernetes cluster
│   │   ├── main.tf                  # EKS cluster, node groups
│   │   ├── iam.tf                   # IAM roles and policies
│   │   ├── service_account.tf       # Service account setup
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── s3/                          # Cloud storage
│   │   ├── main.tf                  # S3 bucket configuration
│   │   ├── iam.tf                   # IRSA role and policies
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rbac/                        # Access control
│   │   ├── main.tf                  # Namespaces, roles, bindings
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── docker/                      # Container configuration
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── manifests/                       # Kubernetes YAML files
│   ├── namespaces.yaml              # rbac-a, rbac-b
│   ├── service_account.yaml         # rbac-test-sa with IRSA
│   ├── roles_rbac_a.yaml            # Read-only role
│   ├── roles_rbac_b.yaml            # Full access role
│   ├── rolebindings.yaml            # RBAC bindings
│   └── test_pod.yaml                # Test pod deployment
│
├── docker/
│   └── Dockerfile                   # Ubuntu + kubectl + aws-cli
│
├── scripts/
│   └── test-pod.sh                  # Validation test script
│
├── .gitignore                       # Git ignore patterns
├── README.md                        # This file
└── terraform.tfvars.example         # Configuration template
```

---

## 🔒 Security Features

### Network Security
- ✅ Public/Private subnet segmentation
- ✅ Private worker nodes (no direct internet access)
- ✅ NAT Gateway for controlled outbound access
- ✅ Security groups with minimal permissions

### Kubernetes Security
- ✅ Least privilege RBAC roles
- ✅ Namespace isolation
- ✅ Service account restrictions
- ✅ Cluster-wide permission limits

### Data Security
- ✅ S3 encryption (AES256)
- ✅ S3 versioning
- ✅ Public access blocked
- ✅ IRSA for workload identity (no hardcoded credentials)

---

## ✅ Validation & Testing

The project includes comprehensive tests to verify all configurations:

### RBAC Permission Tests
```bash
1. List all namespaces           → Should succeed (cluster-wide permission)
2. List pods in default          → Should fail (no access)
3. List pods in kube-system      → Should fail (no access)
4. List pods in rbac-a           → Should succeed (read-only)
5. Create deployment in rbac-a   → Should fail (read-only)
6. List pods in rbac-b           → Should succeed (full access)
7. Create deployment in rbac-b   → Should succeed (full access)
8. Delete deployment in rbac-b   → Should succeed (full access)
```

### Storage Access Tests
```bash
- Upload file to S3 bucket       → Should succeed
- Download file from S3 bucket   → Should succeed
- List bucket contents           → Should succeed
```

### Run Tests
```bash
# Deploy test pod
kubectl apply -f manifests/

# Run validation script
./scripts/test-pod.sh
```

---


## 🛠️ Configuration

### Example terraform.tfvars
```hcl
project_name  = "myproject"
environment   = "dev"
vpc_cidr      = "10.0.0.0/16"
azs           = ["ap-south-1a", "ap-south-1b"]
cluster_name  = "myproject-eks"
eks_version   = "1.28"
aws_region    = "ap-south-1"
```

---

## 📊 Cost Estimation

Approximate monthly costs (ap-south-1 region):

| Component | Estimated Cost |
|-----------|---|
| NAT Gateway | ~$32 |
| EKS Cluster | ~$73 |
| EC2 Worker Nodes (t3.medium x 2) | ~$50-100 |
| S3 Storage (100GB) | ~$2-5 |
| **Total** | **~$160-210** |

*Costs vary by region and usage. Use AWS Pricing Calculator for accurate estimates.*

---

## 🗑️ Cleanup

### Destroy Everything
```bash
terraform destroy -auto-approve
```

### Manual Cleanup (if needed)
```bash
# Remove load balancers
aws ec2 describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text

# Remove security groups
aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --output text

# Remove EBS volumes
aws ec2 describe-volumes --query 'Volumes[?State==`available`].VolumeId' --output text
```

---

## 🐛 Troubleshooting

### kubectl Connection Issues
```bash
# Re-authenticate with EKS cluster
aws eks update-kubeconfig --name <cluster_name> --region <aws_region>

# Verify connection
kubectl cluster-info
```

### RBAC Permission Denied
```bash
# Check role bindings
kubectl get rolebindings -A

# Check service account
kubectl get serviceaccount rbac-test-sa -n default
```

### S3 Access Issues
```bash
# Verify IRSA annotation
kubectl get sa rbac-test-sa -n default -o yaml | grep role-arn

# Check IAM role policy
aws iam get-role-policy --role-name <irsa_role_name> --policy-name <policy_name>
```

---

## 📞 Support & Questions

### Common Questions

**Q: Can I use this in production?**
A: Yes! This is production-ready with security best practices, but review all security settings for your use case.

**Q: How do I add more worker nodes?**
A: Modify `desired_size`, `min_size`, `max_size` in `modules/eks/variables.tf`.

**Q: How do I change the region?**
A: Update `aws_region` in `terraform.tfvars`.

**Q: How do I add more namespaces?**
A: Add new `kubernetes_namespace` resource in `modules/rbac/main.tf`.

### Need Help?
- Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for deployment issues

---

## 📄 License

This project is provided as-is for educational and commercial use.

---

## 👨‍💻 Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Infrastructure | Terraform | >= 1.0 |
| Container Orchestration | Kubernetes (EKS) | 1.28+ |
| Container Runtime | Docker | Latest |
| Cloud Provider | AWS | Current |
| Scripting | Bash | 4.0+ |

---

## ✨ Key Highlights

✅ **Production Ready** - Security, scalability, and reliability built-in  
✅ **Infrastructure as Code** - Version controlled, reproducible  
✅ **Modular Design** - Reusable components, easy to customize  
✅ **Comprehensive Documentation** - Setup guides, architecture explanations  
✅ **Security Best Practices** - Network segmentation, RBAC, IRSA, encryption  
✅ **Automated Testing** - Validation scripts for all configurations  
✅ **Cost Optimized** - Efficient resource usage  

---

**Happy Deploying! 🚀**

