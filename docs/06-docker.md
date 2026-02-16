# 06 - Docker Deep Dive

## Table of Contents
1. [What is Docker?](#what-is-docker)
2. [Docker Images](#docker-images)
3. [Dockerfiles](#dockerfiles)
4. [Multi-stage Builds](#multi-stage-builds)
5. [Docker Volumes](#docker-volumes)
6. [Docker Networks](#docker-networks)
7. [Best Practices](#best-practices)

---

## What is Docker?

Docker is a **platform for containerization**. A container is a lightweight, standalone package that includes everything needed to run software.

```
┌─────────────────────────────────────────────────────────────────┐
│                     DOCKER ARCHITECTURE                          │
│                                                                  │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                      Your App                            │  │
│   │   ┌────────────┐  ┌────────────┐  ┌────────────┐      │  │
│   │   │   Code     │  │  Libraries │  │   Config   │      │  │
│   │   └────────────┘  └────────────┘  └────────────┘      │  │
│   └──────────────────────────────────────────────────────────┘  │
│                              │                                   │
│                              ▼                                   │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                    Docker Container                      │  │
│   │   Everything needed to run your app                     │  │
│   └──────────────────────────────────────────────────────────┘  │
│                              │                                   │
│                              ▼                                   │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                    Docker Engine                         │  │
│   │   - Container Runtime                                    │  │
│   │   - Image Management                                    │  │
│   │   - Networking                                          │  │
│   └──────────────────────────────────────────────────────────┘  │
│                              │                                   │
│                              ▼                                   │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                  Operating System                         │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Docker vs Virtual Machines

| Aspect | Docker Containers | Virtual Machines |
|--------|------------------|------------------|
| Size | MB in size | GB in size |
| Start Time | Seconds | Minutes |
| Isolation | Process level | Hardware level |
| OS | Shared host OS | Full guest OS |
| Performance | Near native | Some overhead |

---

## Docker Images

### What is an Image?

An image is a **read-only template** used to create containers. Think of it like a **class** in programming:

```
┌─────────────────────────────────────────────────────────────────┐
│                     IMAGE VS CONTAINER                           │
│                                                                  │
│   IMAGE (Template/Class)                                        │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ FROM ubuntu:20.04                                      │   │
│   │ RUN apt-get update                                     │   │
│   │ RUN apt-get install -y nginx                          │   │
│   │ COPY nginx.conf /etc/nginx/nginx.conf                 │   │
│   │ EXPOSE 80                                              │   │
│   │ CMD ["nginx", "-g", "daemon off;"]                    │   │
│   └─────────────────────────────────────────────────────────┘   │
│                              │                                    │
│                              ▼ (docker run)                      │
│                                                                  │
│   CONTAINER (Instance/Object)                                   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ Running nginx server                                   │   │
│   │ - Based on ubuntu:20.04                                │   │
│   │ - Has own filesystem                                   │   │
│   │ - Has own network namespace                            │   │
│   │ - Exposes port 80                                     │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Common Image Commands

```bash
# Pull an image from Docker Hub
docker pull nginx:latest

# List local images
docker images

# Build an image from Dockerfile
docker build -t myapp:latest .

# Tag an image
docker tag myapp:latest myregistry.com/myapp:v1.0

# Push to registry
docker push myregistry.com/myapp:v1.0

# Remove an image
docker rmi myapp:latest
```

---

## Dockerfiles

### Basic Dockerfile Structure

```dockerfile
# Comment - describes what this image does
FROM ubuntu:20.04

# Set environment variable
ENV APP_HOME=/app

# Set working directory
WORKDIR /app

# Copy files from host to container
COPY . .

# Run commands during build
RUN apt-get update && apt-get install -y nginx

# Expose port
EXPOSE 80

# Command to run when container starts
CMD ["nginx", "-g", "daemon off;"]
```

### Dockerfile Instructions

| Instruction | Description | Example |
|------------|-------------|---------|
| FROM | Base image | FROM ubuntu:20.04 |
| RUN | Execute command | RUN apt-get update |
| COPY | Copy files | COPY . /app |
| WORKDIR | Set working dir | WORKDIR /app |
| ENV | Environment var | ENV PORT=8080 |
| EXPOSE | Document port | EXPOSE 8080 |
| CMD | Default command | CMD ["nginx"] |
| ENTRYPOINT | Process runner | ENTRYPOINT ["java"] |

### Our Java API Dockerfile

```dockerfile
# Stage 1: Build the application
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create lightweight runtime image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/app.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Why Multi-stage?**
- Builder stage: Has Maven (large)
- Runtime stage: Just JRE (small)
- Final image: ~150MB instead of ~1GB

### Our Node.js Dockerfile

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## Multi-stage Builds

### Why Multi-stage?

```
┌─────────────────────────────────────────────────────────────────┐
│                   MULTI-STAGE BUILD                              │
│                                                                  │
│   Stage 1: Build                                                │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ FROM node:20                                            │   │
│   │ ┌─────────────────────────────────────────────────────┐ │   │
│   │ │ npm install (downloads all dependencies)           │ │   │
│   │ └─────────────────────────────────────────────────────┘ │   │
│   │ ┌─────────────────────────────────────────────────────┐ │   │
│   │ │ npm run build (compiles, optimizes)                │ │   │
│   │ └─────────────────────────────────────────────────────┘ │   │
│   │ Size: ~1GB                                              │   │
│   └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼ COPY artifacts                    │
│   Stage 2: Production                                          │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ FROM nginx:alpine                                      │   │
│   │ COPY --from=builder /app/dist /usr/share/nginx/html   │   │
│   │ Size: ~30MB                                             │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Benefits

1. **Smaller images** - No build tools in final image
2. **Security** - Fewer vulnerabilities
3. **Faster deployments** - Less data to transfer
4. **Clean separation** - Build vs runtime

---

## Docker Volumes

### What are Volumes?

Volumes persist data outside containers. They're like **external hard drives** for containers:

```
┌─────────────────────────────────────────────────────────────────┐
│                      DOCKER VOLUMES                             │
│                                                                  │
│   Without Volume:                                                │
│   ┌─────────────────────┐                                       │
│   │   Container         │                                       │
│   │   ┌─────────────┐  │                                       │
│   │   │ /data       │──┼──❌ Lost when container deleted      │
│   │   └─────────────┘  │                                       │
│   └─────────────────────┘                                       │
│                                                                  │
│   With Volume:                                                  │
│   ┌─────────────────────┐      ┌─────────────────────┐        │
│   │   Container         │      │   Volume            │        │
│   │   ┌─────────────┐  │      │   /var/lib/mysql   │        │
│   │   │ /data       │──┼──────│ (persistent)       │        │
│   │   └─────────────┘  │      └─────────────────────┘        │
│   └─────────────────────┘                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Volume Types

```bash
# Named volume (managed by Docker)
docker volume create mydata
docker run -v mydata:/app/data myapp

# Bind mount (host directory)
docker run -v /host/path:/container/path myapp

# tmpfs (in-memory)
docker run --tmpfs /app/data myapp
```

### In Our docker-compose.yaml

```yaml
services:
  mysql:
    image: mysql:8.0
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

---

## Docker Networks

### Network Types

| Driver | Description | Use Case |
|--------|-------------|----------|
| bridge | Default network | Single host |
| host | Host networking | Performance |
| overlay | Multi-host | Swarm |
| none | No networking | Isolated |

### Our Network Setup

```yaml
services:
  mysql:
    image: mysql:8.0
    networks:
      - app-network

  java-api:
    image: java-api
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### How Containers Communicate

```
┌─────────────────────────────────────────────────────────────────┐
│                    DOCKER NETWORK                               │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              app-network (bridge)                        │   │
│   │                                                           │   │
│   │   ┌─────────────┐       ┌─────────────┐                │   │
│   │   │ mysql-db    │       │  java-api   │                │   │
│   │   │  :3306      │◄─────►│   :8080     │                │   │
│   │   │ hostname:   │       │ hostname:   │                │   │
│   │   │ mysql-db    │       │ java-api    │                │   │
│   │   └─────────────┘       └─────────────┘                │   │
│   │                                                           │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   External access:                                               │
│   - mysql-db: localhost:3306 (mapped port)                     │
│   - java-api: localhost:8080 (mapped port)                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Best Practices

### 1. Use Specific Image Tags

```dockerfile
# Bad
FROM node:latest

# Good
FROM node:20-alpine
```

### 2. Use .dockerignore

```text
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
dist
```

### 3. Order Dockerfile Instructions

```dockerfile
# Change less frequently first
FROM node:20-alpine
WORKDIR /app

# Copy package files first (for caching)
COPY package*.json ./
RUN npm ci

# Copy source code later
COPY . .
RUN npm run build
```

### 4. Use Non-root User

```dockerfile
FROM node:20-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
WORKDIR /app
COPY --chown=appuser:appgroup . .
```

### 5. Multi-stage for Security

```dockerfile
# Build stage (with all tools)
FROM maven:3.9 AS builder
COPY . .
RUN mvn package

# Production stage (minimal)
FROM eclipse-temurin:17-jre-alpine
COPY --from=builder /app/target/app.jar app.jar
USER 1000
CMD ["java", "-jar", "app.jar"]
```

---

## Summary

### Key Commands

```bash
# Build image
docker build -t myapp:latest .

# Run container
docker run -p 8080:8080 myapp:latest

# View logs
docker logs -f container_id

# Interactive shell
docker exec -it container_id sh

# List containers
docker ps -a

# Remove stopped containers
docker container prune

# Remove unused images
docker image prune -a
```

### Key Concepts

1. **Images** - Templates for containers
2. **Containers** - Running instances of images
3. **Volumes** - Persistent data storage
4. **Networks** - Container communication
5. **Multi-stage builds** - Smaller, secure images

---

## Next Steps

- [07-Kubernetes](./07-kubernetes.md) - Orchestrate containers
- [08-Terraform](./08-terraform.md) - Infrastructure as Code
