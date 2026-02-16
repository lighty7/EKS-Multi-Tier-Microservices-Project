# 03 - Java Spring Boot REST API Tutorial

## 📖 Table of Contents
1. [What is Spring Boot?](#what-is-spring-boot)
2. [Project Structure](#project-structure)
3. [Key Components](#key-components)
4. [Building the API](#building-the-api)
5. [Running Locally](#running-locally)
6. [Testing Endpoints](#testing-endpoints)

---

## What is Spring Boot?

Spring Boot is a **framework** that makes building Java applications easy. Think of it like a **pre-assembled toolkit**:

```
┌─────────────────────────────────────────────────────────────┐
│                    SPRING BOOT                              │
│                                                             │
│  Instead of building everything from scratch:              │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  You write:                                         │   │
│  │  @RestController                                   │   │
│  │  @GetMapping("/api/products")                     │   │
│  │  public List<Product> getProducts() {             │   │
│  │      return repository.findAll();                 │   │
│  │  }                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Spring Boot automatically handles:                         │
│  ✅ Server setup (Tomcat embedded)                         │
│  ✅ Database connections                                   │
│  ✅ JSON conversion                                        │
│  ✅ Security configuration                                │
│  ✅ Dependency management                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why Spring Boot?

| Traditional Java | Spring Boot |
|-----------------|-------------|
| Lots of configuration | Convention over configuration |
| Manual server setup | Embedded server |
| XML configuration | Annotations |
| Complex dependencies | Starter packs |

---

## Project Structure

```
java-api/
├── src/
│   └── main/
│       ├── java/com/example/api/
│       │   ├── ApiApplication.java      # Main entry point
│       │   ├── controller/
│       │   │   └── ProductController.java  # API endpoints
│       │   ├── model/
│       │   │   └── Product.java         # Data model
│       │   └── repository/
│       │       └── ProductRepository.java # Database ops
│       └── resources/
│           └── application.properties  # Configuration
├── pom.xml                            # Dependencies
└── Dockerfile                         # Container build
```

---

## Key Components

### 1. Main Application Class

```java
package com.example.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiApplication.class, args);
    }
}
```

**What it does:**
- `@SpringBootApplication` combines three annotations:
  - `@Configuration` - Marks as configuration class
  - `@EnableAutoConfiguration` - Auto-configures Spring
  - `@ComponentScan` - Finds components automatically

### 2. The Product Model (Entity)

```java
package com.example.api.model;

import jakarta.persistence.*;

@Entity
@Table(name = "products")
public class Product {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(length = 1000)
    private String description;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;
    
    @Column(nullable = false)
    private Integer quantity;
    
    // Getters and Setters...
}
```

**Annotations explained:**
- `@Entity` - This class maps to a database table
- `@Table` - Specifies the table name
- `@Id` - Primary key
- `@GeneratedValue` - Auto-increment ID
- `@Column` - Column configuration

### 3. The Repository

```java
package com.example.api.repository;

import com.example.api.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
}
```

**What is JpaRepository?**
It provides all basic CRUD operations:

| Method | SQL Equivalent |
|--------|---------------|
| `findAll()` | SELECT * FROM products |
| `findById(id)` | SELECT * FROM products WHERE id = ? |
| `save(product)` | INSERT/UPDATE |
| `deleteById(id)` | DELETE FROM products |

### 4. The Controller

```java
package com.example.api.controller;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    
    @Autowired
    private ProductRepository productRepository;
    
    @GetMapping
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public Product createProduct(@Valid @RequestBody Product product) {
        return productRepository.save(product);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody Product productDetails) {
        return productRepository.findById(id)
            .map(product -> {
                product.setName(productDetails.getName());
                product.setPrice(productDetails.getPrice());
                product.setQuantity(productDetails.getQuantity());
                return ResponseEntity.ok(productRepository.save(product));
            })
            .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        if (productRepository.existsById(id)) {
            productRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
```

**HTTP Methods:**
- `@GetMapping` - READ data
- `@PostMapping` - CREATE data
- `@PutMapping` - UPDATE data
- `@DeleteMapping` - DELETE data

---

## Building the API

### Step 1: Maven Dependencies (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>java-api</artifactId>
    <version>1.0.0</version>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>
    
    <dependencies>
        <!-- Web framework -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <!-- Database ORM -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <!-- MySQL Driver -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
        </dependency>
        
        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
    </dependencies>
</project>
```

### Step 2: Application Properties

```properties
server.port=8080

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/productsdb
spring.datasource.username=root
spring.datasource.password=rootpassword
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
```

### Step 3: Build the Application

```bash
cd java-api

# Build with Maven
mvn clean package

# Run the application
java -jar target/app.jar
```

---

## Running Locally

### Using Maven

```bash
# Run in development
mvn spring-boot:run
```

### Using Docker

```bash
# Build the image
docker build -t java-api:latest ./java-api

# Run the container
docker run -p 8080:8080 \
  -e DB_URL=jdbc:mysql://host.docker.internal:3306/productsdb \
  -e DB_PASSWORD=rootpassword \
  java-api:latest
```

### Using Docker Compose

```bash
# Start all services
docker compose up java-api
```

---

## Testing Endpoints

### Health Check

```bash
curl http://localhost:8080/api/products/health

# Response:
{"status":"UP","service":"java-api"}
```

### Get All Products

```bash
curl http://localhost:8080/api/products

# Response:
[]
```

### Create a Product

```bash
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Pro",
    "description": "16-inch laptop",
    "price": 2499.99,
    "quantity": 5
  }'

# Response:
{
  "id": 1,
  "name": "MacBook Pro",
  "description": "16-inch laptop",
  "price": 2499.99,
  "quantity": 5
}
```

### Get Single Product

```bash
curl http://localhost:8080/api/products/1

# Response:
{
  "id": 1,
  "name": "MacBook Pro",
  "description": "16-inch laptop",
  "price": 2499.99,
  "quantity": 5
}
```

### Update Product

```bash
curl -X PUT http://localhost:8080/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Pro M3",
    "description": "Updated model",
    "price": 2799.99,
    "quantity": 10
  }'
```

### Delete Product

```bash
curl -X DELETE http://localhost:8080/api/products/1

# Response: 200 OK (empty)
```

---

## REST API Best Practices

### URL Design

```
✅ Good API Design:
GET    /api/products          # List all products
GET    /api/products/123     # Get product 123
POST   /api/products         # Create new product
PUT    /api/products/123     # Update product 123
DELETE /api/products/123    # Delete product 123

❌ Bad API Design:
GET    /getAllProducts
GET    /getProductById?id=123
POST   /createProduct
```

### HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, DELETE |
| 201 | Created | Successful POST |
| 400 | Bad Request | Invalid input |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Something went wrong |

---

## Summary

### What We Built

```
┌─────────────────────────────────────────────────────────────┐
│                  JAVA SPRING BOOT API                       │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐ │
│   │  REST Controller                                    │ │
│   │  - Handles HTTP requests                           │ │
│   │  - Maps URLs to methods                            │ │
│   └─────────────────────────────────────────────────────┘ │
│                           │                                 │
│                           ▼                                 │
│   ┌─────────────────────────────────────────────────────┐ │
│   │  Service Layer                                     │ │
│   │  - Business logic                                 │ │
│   └─────────────────────────────────────────────────────┘ │
│                           │                                 │
│                           ▼                                 │
│   ┌─────────────────────────────────────────────────────┐ │
│   │  Repository (JPA)                                  │ │
│   │  - Database operations                             │ │
│   └─────────────────────────────────────────────────────┘ │
│                           │                                 │
│                           ▼                                 │
│   ┌─────────────────────────────────────────────────────┐ │
│   │  MySQL Database                                   │ │
│   │  - Stores products                               │ │
│   └─────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Takeaways

1. **Spring Boot** simplifies Java web development
2. **JPA/Hibernate** handles database operations
3. **REST** provides standard API design
4. **Docker** makes deployment easy

---

## Next Steps

- **[04-React-Frontend](./04-react-frontend.md)** - Build the UI to consume this API
- **[05-Database](./05-database.md)** - Learn more about databases
- **[06-Docker](./06-docker.md)** - Containerize this API
