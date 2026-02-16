# 10 - AWS Deployment Guide

## Table of Contents
1. [AWS Account Setup](#aws-account-setup)
2. [IAM User Creation](#iam-user-creation)
3. [Terraform Deployment](#terraform-deployment)
4. [GitHub Configuration](#github-configuration)
5. [Deploy Application](#deploy-application)
6. [Verification](#verification)

---

## AWS Account Setup

### Step 1: Create AWS Account

1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Enter email, password, account name
4. Add payment method (required even for free tier)
5. Verify identity with phone
6. Select Basic Support (Free)

### Step 2: Enable Free Tier

```
AWS Free Tier includes:
- EC2: 750 hours/month
- S3: 5GB
- RDS: 750 hours/month
- EKS: Limited free tier
```

---

## IAM User Creation

### Why IAM?

IAM (Identity and Access Management) lets you create users with specific permissions instead of using root account.

### Create IAM User

1. Go to **IAM** → **Users** → **Add users**
2. Enter username: `devops-deploy`
3. Select access type: **Programmatic access**
4. Click **Next: Permissions**

### Attach Policies

Attach these policies:

| Policy | Purpose |
|--------|---------|
| AmazonEC2ContainerRegistryFullAccess | Push to ECR |
| AmazonEKSClusterPolicy | Deploy to EKS |
| AmazonEKSWorkerNodePolicy | Worker nodes |
| AmazonEKS_CNI_Policy | Container networking |
| AmazonEKSServicePolicy | EKS service |
| IAMFullAccess | Create roles |

### Save Credentials

```
Important: Save these immediately!
- Access Key ID: AKIA...
- Secret Access Key: ...
```

---

## Terraform Deployment

### Step 1: Install Tools

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Terraform
curl -fsSL https://get.terraform.io/install.sh | bash
```

### Step 2: Configure AWS

```bash
aws configure
# Enter Access Key ID
# Enter Secret Access Key
# Region: us-east-1
# Output format: json
```

### Step 3: Deploy Infrastructure

```bash
cd terraform

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply -auto-approve
```

### Step 4: Note Outputs

```
cluster_name = eks-microservices
cluster_endpoint = https://...eks.amazonaws.com
vpc_id = vpc-...
db_endpoint = ...rds.amazonaws.com
```

---

## GitHub Configuration

### Step 1: Add Secrets

Go to GitHub → Repository → Settings → Secrets → New secret:

| Secret | Value |
|--------|-------|
| AWS_ACCESS_KEY_ID | AKIA... |
| AWS_SECRET_ACCESS_KEY | ... |

### Step 2: Update Workflow (Optional)

The workflow already uses these secrets. Just push code to trigger deployment.

---

## Deploy Application

### Automatic Deployment (Recommended)

```bash
# Push code to trigger GitHub Actions
git add .
git commit -m "Deploy to EKS"
git push origin main
```

### Manual Deployment

```bash
# Configure kubectl
aws eks update-kubeconfig --name eks-microservices

# Deploy manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/java-api/deployment.yaml
kubectl apply -f k8s/node-frontend/deployment.yaml
kubectl apply -f k8s/ingress.yaml

# Check status
kubectl get pods -n microservices
kubectl get svc -n microservices
```

---

## Verification

### Check Pods

```bash
kubectl get pods -n microservices

# Should show:
# NAME                             READY   STATUS
# java-api-xxxxx                   1/1     Running
# java-api-yyyyy                   1/1     Running
# node-frontend-xxxxx              1/1     Running
# node-frontend-yyyyy              1/1     Running
```

### Check Services

```bash
kubectl get svc -n microservices

# Should show:
# NAME            TYPE        CLUSTER-IP     PORT(S)
# java-api        ClusterIP   10.x.x.x       8080/TCP
# node-frontend   ClusterIP   10.x.x.x       80/TCP
```

### Get External URL

```bash
kubectl get ingress -n microservices

# External URL will be shown under ADDRESS
```

### Test Application

```bash
# Test API health
curl http://<external-ip>/api/products/health

# Test frontend
curl http://<external-ip>
```

---

## Troubleshooting

### Pod Not Starting

```bash
# Check events
kubectl describe pod <pod-name> -n microservices

# Check logs
kubectl logs <pod-name> -n microservices
```

### ImagePullBackOff

```bash
# Check image URL in deployment
kubectl get deployment java-api -n microservices -o yaml | grep image

# Verify image exists in ECR
aws ecr list-images --repository-name java-api
```

### Connection Issues

```bash
# Check security groups
# Ensure EKS node security group allows traffic

# Check VPC settings
# Ensure subnets have internet access
```

---

## Cleanup

### Destroy Infrastructure

```bash
cd terraform
terraform destroy -auto-approve
```

### Important

```
Warning: This will delete ALL AWS resources:
- EKS Cluster
- RDS Database (all data!)
- ECR Images
- VPC and networking
```

---

## Summary

### Steps Recap

1. ✓ Create AWS Account
2. ✓ Create IAM User with permissions
3. ✓ Run Terraform to create infrastructure
4. ✓ Configure GitHub Secrets
5. ✓ Push code to trigger deployment
6. ✓ Verify application is running

### Cost Management

| Resource | Free Tier | Cost After |
|----------|-----------|------------|
| EKS Control Plane | 1st cluster free/hr | ~$0.10/hr |
| EC2 (3 t3.medium) | - | ~$0.05/hr each |
| RDS (db.t3.micro) | 750 hr/month | ~$0.02/hr |
| ECR Storage | 500MB | ~$0.10/GB/mo |

---

## Next Steps

- [11-Resume-Guide](./11-resume-guide.md) - How to showcase this project
