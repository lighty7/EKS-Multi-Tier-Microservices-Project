# 05 - Database & Docker Tutorial

## 📖 Table of Contents
1. [What is a Database?](#what-is-a-database)
2. [MySQL Basics](#mysql-basics)
3. [Database Connection](#database-connection)
4. [Docker for Databases](#docker-for-databases)
5. [Docker Compose](#docker-compose)

---

## What is a Database?

A database is an **organized collection of data**. Think of it like a **digital filing cabinet**:

```
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE ANALOGY                        │
│                                                             │
│  Physical Filing Cabinet:                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Drawer: Products                                    │   │
│  │   ├─ Folder: Electronics                           │   │
│  │   │   └─ Card: Laptop - $999 - 5 in stock          │   │
│  │   └─ Folder: Clothing                              │   │
│  │       └─ Card: Shirt - $29 - 100 in stock         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  MySQL Database:                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ products table                                      │   │
│  │ ┌────┬──────────┬─────────────┬───────┬───────┐  │   │
│  │ │ id │ name     │ description │ price │ qty   │  │   │
│  │ ├────┼──────────┼─────────────┼───────┼───────┤  │   │
│  │ │ 1  │ Laptop   │ 16-inch    │ 999   │ 5     │  │   │
│  │ │ 2  │ Shirt    │ Cotton     │ 29    │ 100   │  │   │
│  │ └────┴──────────┴─────────────┴───────┴───────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Types of Databases

| Type | Use Case | Examples |
|------|----------|----------|
| **Relational (SQL)** | Structured data with relationships | MySQL, PostgreSQL, Oracle |
| **Document** | Flexible, JSON-like data | MongoDB, CouchDB |
| **Key-Value** | Fast lookups, caching | Redis, DynamoDB |
| **Graph** | Relationship-heavy data | Neo4j |

---

## MySQL Basics

### What is MySQL?

MySQL is a **relational database** that uses **SQL** (Structured Query Language):

```sql
-- Create a table
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL
);

-- Insert data
INSERT INTO products (name, description, price, quantity)
VALUES ('Laptop', '16-inch MacBook', 999.99, 5);

-- Read data
SELECT * FROM products;
SELECT * FROM products WHERE price > 100;

-- Update data
UPDATE products SET price = 899.99 WHERE id = 1;

-- Delete data
DELETE FROM products WHERE id = 1;
```

### Key MySQL Concepts

| Concept | Description |
|---------|-------------|
| **Table** | Collection of rows (like a spreadsheet) |
| **Row** | Single record (like a spreadsheet row) |
| **Column** | Single field (like a spreadsheet column) |
| **Primary Key** | Unique identifier for each row |
| **Index** | Speeds up data retrieval |

---

## Database Connection

### Spring Boot + MySQL

```properties
# application.properties
spring.datasource.url=jdbc:mysql://localhost:3306/productsdb
spring.datasource.username=root
spring.datasource.password=rootpassword

# JDBC Driver
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate settings
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

### Connection URL Breakdown

```
jdbc:mysql://localhost:3306/productsdb?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
│    │    │         │      │                                    │
│    │    │         │      │                                    └── Additional options
│    │    │         │      └── Database name
│    │    │         └── Port
│    │    └── Hostname
│    └── Protocol
```

---

## Docker for Databases

### Why Use Docker for Databases?

```
┌─────────────────────────────────────────────────────────────┐
│                 DOCKER FOR DATABASES                        │
│                                                             │
│  Without Docker:                                           │
│  - Install MySQL on your machine                           │
│  - Configure system settings                               │
│  - Might conflict with other versions                      │
│  - Hard to clean up                                        │
│                                                             │
│  With Docker:                                              │
│  - One command to install                                  │
│  - Isolated from system                                    │
│  - Easy to run multiple versions                          │
│  - Easy to remove                                          │
│                                                             │
│  docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=secret    │
│  mysql:8.0                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Running MySQL with Docker

```bash
# Pull MySQL image
docker pull mysql:8.0

# Run MySQL container
docker run -d \
  --name mysql-db \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=productsdb \
  mysql:8.0

# Connect to MySQL
docker exec -it mysql-db mysql -uroot -prootpassword

# Check databases
SHOW DATABASES;
USE productsdb;
SHOW TABLES;
```

### MySQL Docker Options

| Option | Description |
|--------|-------------|
| `-d` | Run in detached mode (background) |
| `--name` | Container name |
| `-p` | Port mapping (host:container) |
| `-e` | Environment variable |
| `-v` | Volume mount |

---

## Docker Compose

### What is Docker Compose?

Docker Compose lets you define **multi-container applications** in a single file:

```yaml
# docker-compose.yaml
services:
  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: productsdb
    volumes:
      - mysql_data:/var/lib/mysql

  java-api:
    build: ./java-api
    ports:
      - "8080:8080"
    environment:
      DB_URL: jdbc:mysql://mysql:3306/productsdb
    depends_on:
      mysql:
        condition: service_healthy

volumes:
  mysql_data:
```

### Compose Commands

```bash
# Start all services
docker compose up

# Start in background
docker compose up -d

# Stop all services
docker compose down

# Remove volumes too
docker compose down -v

# View logs
docker compose logs

# View running services
docker compose ps
```

### Health Checks

```yaml
mysql:
  image: mysql:8.0
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    interval: 10s
    timeout: 5s
    retries: 5

java-api:
  depends_on:
    mysql:
      condition: service_healthy
```

---

## Complete Docker Compose Setup

### Our Project's docker-compose.yaml

```yaml
services:
  mysql:
    image: mysql:8.0
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: productsdb
    command: --default-authentication-plugin=mysql_native_password
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  java-api:
    build:
      context: ./java-api
      dockerfile: Dockerfile
    container_name: java-api
    ports:
      - "8080:8080"
    environment:
      DB_URL: jdbc:mysql://mysql-db:3306/productsdb?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
      DB_USERNAME: root
      DB_PASSWORD: rootpassword
    depends_on:
      mysql:
        condition: service_healthy

  node-frontend:
    build:
      context: ./node-frontend
      dockerfile: Dockerfile
    container_name: node-frontend
    ports:
      - "3000:80"
    environment:
      VITE_API_URL: http://java-api:8080/api
    depends_on:
      - java-api

volumes:
  mysql_data:
```

### How It All Connects

```
┌─────────────────────────────────────────────────────────────┐
│                  DOCKER COMPOSE NETWORK                    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Docker Network                          │   │
│  │                                                     │   │
│  │  ┌─────────────┐      ┌─────────────┐             │   │
│  │  │ mysql-db    │      │  java-api   │             │   │
│  │  │   :3306     │◄────►│    :8080    │             │   │
│  │  └─────────────┘      └──────┬──────┘             │   │
│  │                               │                     │   │
│  │                        ┌──────▼──────┐             │   │
│  │                        │node-frontend│             │   │
│  │                        │    :80      │             │   │
│  │                        └─────────────┘             │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  External Ports:                                            │
│  - mysql-db: localhost:3306                                │
│  - java-api: localhost:8080                               │
│  - node-frontend: localhost:3000                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary

### Key Concepts

1. **Database** - Organized data storage
2. **MySQL** - Popular relational database
3. **Docker** - Containerize databases easily
4. **Docker Compose** - Orchestrate multi-container apps

### Common Commands

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Connect to MySQL
docker exec -it mysql-db mysql -uroot -prootpassword

# Restart a service
docker compose restart java-api
```

---

## Next Steps

- **[06-Docker](./06-docker.md)** - Deep dive into Docker
- **[07-Kubernetes](./07-kubernetes.md)** - Deploy with K8s
- **[08-Terraform](./08-terraform.md)** - Provision AWS RDS
