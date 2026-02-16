# 🚀 EKS Multi-Tier Microservices Project

A production-ready DevOps project demonstrating microservices architecture on AWS EKS using Java, Node.js, Docker, Kubernetes, Terraform, and GitHub Actions CI/CD.

## 📋 Project Overview

This project showcases:
- **Java Spring Boot** REST API (backend)
- **React + Vite** Dashboard (frontend)
- **MySQL** Database
- **Docker** Containerization
- **Kubernetes (EKS)** Orchestration
- **Terraform** Infrastructure as Code
- **GitHub Actions** CI/CD Pipeline

## 🏃 Quick Start

### Prerequisites
- Docker & Docker Compose
- Java 17+
- Node.js 20+
- Maven 3.9+

### Run Locally

```bash
# Clone and navigate
cd project-1-eks

# Start all services
docker compose up --build

# Or run individually
docker compose up -d mysql
docker compose up -d java-api
docker compose up -d node-frontend
```

### Access Services

| Service | URL | Description |
|---------|-----|-------------|
| Frontend Dashboard | http://localhost:3000 | React UI |
| Java API | http://localhost:8080 | REST API |
| API Health | http://localhost:8080/api/products/health | Health Check |
| MySQL | localhost:3306 | Database |

## 📁 Project Structure

```
project-1-eks/
├── java-api/                    # Java Spring Boot REST API
│   ├── src/
│   ├── Dockerfile              # Multi-stage build
│   └── pom.xml                # Maven dependencies
├── node-frontend/              # React Frontend
│   ├── src/
│   ├── Dockerfile             # Nginx production build
│   └── package.json
├── terraform/                  # AWS Infrastructure
│   ├── main.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── rds.tf
│   └── ecr.tf
├── k8s/                       # Kubernetes Manifests
│   ├── java-api/
│   ├── node-frontend/
│   └── ingress.yaml
├── docs/                      # Detailed Documentation
└── docker-compose.yaml         # Local development
```

## 🔧 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | List all products |
| GET | `/api/products/{id}` | Get product by ID |
| POST | `/api/products` | Create new product |
| PUT | `/api/products/{id}` | Update product |
| DELETE | `/api/products/{id}` | Delete product |
| GET | `/api/products/health` | Health check |

## 📚 Documentation

- [01-Overview](./docs/01-overview.md) - Architecture & project overview
- [02-Concepts](./docs/02-concepts.md) - Core DevOps concepts explained
- [03-Java-API](./docs/03-java-api.md) - Spring Boot tutorial
- [04-React-Frontend](./docs/04-react-frontend.md) - React tutorial
- [05-Database](./docs/05-database.md) - MySQL & JPA guide
- [06-Docker](./docs/06-docker.md) - Docker deep dive
- [07-Kubernetes](./docs/07-kubernetes.md) - K8s & EKS tutorial
- [08-Terraform](./docs/08-terraform.md) - IaC tutorial
- [09-GitHub-Actions](./docs/09-github-actions.md) - CI/CD pipeline
- [10-Deployment](./docs/10-deployment.md) - AWS deployment guide
- [11-Resume-Guide](./docs/11-resume-guide.md) - Resume tips

## 🛠️ Common Commands

```bash
# Build Docker images
docker build -t java-api ./java-api
docker build -t node-frontend ./node-frontend

# View logs
docker logs java-api
docker logs node-frontend

# Stop services
docker compose down

# Remove volumes (fresh start)
docker compose down -v

# Test API
curl http://localhost:8080/api/products/health

# Create product
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Product","price":99.99,"quantity":5}'
```

## 🎯 Skills Demonstrated

- ✅ Docker containerization
- ✅ Kubernetes (EKS) deployment
- ✅ Terraform Infrastructure as Code
- ✅ GitHub Actions CI/CD
- ✅ AWS cloud services
- ✅ Microservices architecture
- ✅ REST API development
- ✅ React frontend development

## 📝 License

MIT License - Feel free to use for your portfolio!

## 🙏 Credits

Created as a resume-ready DevOps project for 2026 job market.
