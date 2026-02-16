# 09 - GitHub Actions CI/CD Tutorial

## Table of Contents
1. [What is CI/CD?](#what-is-cicd)
2. [GitHub Actions Basics](#github-actions-basics)
3. [Our Workflow File](#our-workflow-file)
4. [Pipeline Stages](#pipeline-stages)
5. [GitHub Secrets](#github-secrets)

---

## What is CI/CD?

CI/CD automates the process of building, testing, and deploying code.

```
┌─────────────────────────────────────────────────────────────────┐
│                       CI/CD PIPELINE                            │
│                                                                  │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐   │
│   │  Code    │───▶│  Build  │───▶│  Test   │───▶│ Deploy  │   │
│   │  Push    │    │         │    │         │    │         │   │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘   │
│                                                                  │
│   CI: Continuous Integration (Build + Test)                    │
│   CD: Continuous Deployment (Automatic Deploy)                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Benefits

| Benefit | Description |
|---------|-------------|
| Faster releases | Automated process |
| Fewer bugs | Automated testing |
| Consistency | Same process every time |
| Rollback | Easy to revert changes |

---

## GitHub Actions Basics

### Workflow Structure

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Build
        run: npm run build
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Workflow** | Automated process defined in YAML |
| **Job** | A set of steps to execute |
| **Step** | Individual action or command |
| **Action** | Reusable unit of work |
| **Runner** | Server that executes jobs |

---

## Our Workflow File

### Complete CI/CD Pipeline

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
    paths:
      - 'java-api/**'
      - 'node-frontend/**'

jobs:
  java-api-build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Build Java API
        run: mvn clean package -DskipTests

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Login to ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and Push
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        run: |
          docker build -t $ECR_REGISTRY/java-api:${{ github.sha }} ./java-api
          docker push $ECR_REGISTRY/java-api:${{ github.sha }}

  node-frontend-build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Build
        run: |
          npm ci
          npm run build

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Login to ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and Push
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        run: |
          docker build -t $ECR_REGISTRY/node-frontend:${{ github.sha }} ./node-frontend
          docker push $ECR_REGISTRY/node-frontend:${{ github.sha }}

  deploy-to-eks:
    needs: [java-api-build, node-frontend-build]
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Update kubeconfig
        run: aws eks update-kubeconfig --name eks-microservices

      - name: Deploy to K8s
        env:
          IMAGE_TAG: ${{ github.sha }}
        run: |
          sed "s|latest|$IMAGE_TAG|g" k8s/java-api/deployment.yaml | kubectl apply -f -
          sed "s|latest|$IMAGE_TAG|g" k8s/node-frontend/deployment.yaml | kubectl apply -f -
```

---

## Pipeline Stages

### Stage 1: Java API Build

```yaml
java-api-build:
  steps:
    - checkout          # Get code
    - setup-java       # JDK 17
    - maven-build      # Compile
    - aws-configure    # AWS credentials
    - ecr-login        # Login to ECR
    - docker-build     # Build image
    - docker-push      # Push to ECR
```

### Stage 2: Frontend Build

```yaml
node-frontend-build:
  steps:
    - checkout         # Get code
    - setup-node       # Node 20
    - npm-install      # Dependencies
    - npm-build        # Build React app
    - aws-configure    # AWS credentials
    - ecr-login        # Login to ECR
    - docker-build     # Build image
    - docker-push      # Push to ECR
```

### Stage 3: Deploy

```yaml
deploy-to-eks:
  needs: [java-api-build, node-frontend-build]
  steps:
    - checkout
    - aws-configure
    - update-kubeconfig  # Connect to EKS
    - kubectl-apply      # Deploy to K8s
    - verify-rollout     # Check deployment
```

---

## GitHub Secrets

### Setting Up Secrets

1. Go to your GitHub repository
2. Click **Settings**
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### Required Secrets

| Secret | Description |
|--------|-------------|
| AWS_ACCESS_KEY_ID | AWS access key |
| AWS_SECRET_ACCESS_KEY | AWS secret key |

### Creating AWS Credentials

```bash
# Create IAM user in AWS Console
# Attach policies:
# - AmazonEC2ContainerRegistryFullAccess
# - AmazonEKSClusterPolicy
# - AmazonEKSWorkerNodePolicy

# Create access key in IAM Console
# Copy Access Key ID and Secret Access Key
# Add to GitHub Secrets
```

---

## Summary

### Key Concepts

1. **Workflow** - YAML file in .github/workflows/
2. **Trigger** - When to run (push, PR, schedule)
3. **Job** - Collection of steps
4. **Step** - Individual action
5. **Action** - Reusable component
6. **Secret** - Encrypted environment variable

### Workflow Triggers

```yaml
on:
  push:           # On code push
  pull_request:   # On PR
  schedule:       # On schedule (cron)
  workflow_dispatch: # Manual trigger
```

---

## Next Steps

- [10-Deployment](./10-deployment.md) - Complete deployment guide
- [11-Resume-Guide](./11-resume-guide.md) - Resume tips
