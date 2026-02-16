# 04 - React Frontend Tutorial

## 📖 Table of Contents
1. [What is React?](#what-is-react)
2. [Project Setup](#project-setup)
3. [Component Structure](#component-structure)
4. [API Integration](#api-integration)
5. [Building the UI](#building-the-ui)
6. [Nginx Configuration](#nginx-configuration)

---

## What is React?

React is a **JavaScript library** for building user interfaces. Think of it like **building blocks**:

```
┌─────────────────────────────────────────────────────────────┐
│                    REACT COMPONENTS                         │
│                                                             │
│  Traditional HTML:                                         │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ <div>                                                │  │
│  │   <header>Site Title</header>                       │  │
│  │   <nav>...</nav>                                    │  │
│  │   <main>...</main>                                  │  │
│  │   <footer>...</footer>                              │  │
│  │ </div>                                               │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  React Components:                                         │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ <App>                                               │  │
│  │   <Header />                                        │  │
│  │   <Navigation />                                    │  │
│  │   <ProductList products={data} />                   │  │
│  │   <Footer />                                        │  │
│  │ </App>                                              │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  Benefits:                                                  │
│  ✅ Reusable components                                   │
│  ✅ Declarative syntax                                    │
│  ✅ Virtual DOM for performance                           │
│  ✅ Large ecosystem                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why React?

| jQuery | React |
|--------|-------|
| Imperative (how to do) | Declarative (what to show) |
| Direct DOM manipulation | Virtual DOM |
| Mixed HTML/JS | JSX (HTML in JS) |
| Hard to maintain | Component-based |

---

## Project Setup

### Prerequisites

```bash
# Install Node.js (version 20)
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

### Create New Project

```bash
# Using Vite (faster than Create React App)
npm create vite@latest my-app -- --template react
cd my-app
npm install
npm run dev
```

### Our Project Structure

```
node-frontend/
├── src/
│   ├── App.jsx          # Main component
│   ├── App.css          # Styles
│   ├── main.jsx         # Entry point
│   └── index.css        # Global styles
├── index.html           # HTML template
├── vite.config.js      # Vite configuration
├── package.json        # Dependencies
├── nginx.conf          # Nginx config
└── Dockerfile          # Container build
```

---

## Component Structure

### Main App Component

```jsx
import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api'

function App() {
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [showForm, setShowForm] = useState(false)
  const [newProduct, setNewProduct] = useState({
    name: '',
    description: '',
    price: '',
    quantity: ''
  })

  // Fetch products on component mount
  useEffect(() => {
    fetchProducts()
  }, [])

  // Fetch all products from API
  const fetchProducts = async () => {
    try {
      const response = await axios.get(`${API_URL}/products`)
      setProducts(response.data)
      setLoading(false)
    } catch (err) {
      setError('Failed to fetch products')
      setLoading(false)
    }
  }

  // Create new product
  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      await axios.post(`${API_URL}/products`, {
        ...newProduct,
        price: parseFloat(newProduct.price),
        quantity: parseInt(newProduct.quantity)
      })
      setShowForm(false)
      setNewProduct({ name: '', description: '', price: '', quantity: '' })
      fetchProducts()
    } catch (err) {
      setError('Failed to create product')
    }
  }

  // Delete product
  const handleDelete = async (id) => {
    try {
      await axios.delete(`${API_URL}/products/${id}`)
      fetchProducts()
    } catch (err) {
      setError('Failed to delete product')
    }
  }

  return (
    <div className="app">
      <header className="header">
        <h1>EKS Microservices Dashboard</h1>
      </header>

      <main>
        {/* Stats */}
        <div className="stats">
          <div className="stat-card">
            <h3>Total Products</h3>
            <p>{products.length}</p>
          </div>
        </div>

        {/* Add Product Button */}
        <button onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancel' : '+ Add Product'}
        </button>

        {/* Product Form */}
        {showForm && (
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="Product Name"
              value={newProduct.name}
              onChange={(e) => setNewProduct({...newProduct, name: e.target.value})}
              required
            />
            <input
              type="number"
              placeholder="Price"
              value={newProduct.price}
              onChange={(e) => setNewProduct({...newProduct, price: e.target.value})}
              required
            />
            <button type="submit">Save</button>
          </form>
        )}

        {/* Product List */}
        <div className="product-grid">
          {products.map(product => (
            <div key={product.id} className="product-card">
              <h3>{product.name}</h3>
              <p>{product.description}</p>
              <span className="price">${product.price}</span>
              <button onClick={() => handleDelete(product.id)}>
                Delete
              </button>
            </div>
          ))}
        </div>
      </main>
    </div>
  )
}

export default App
```

---

## API Integration

### Using Axios

Axios is an HTTP client for making API requests:

```bash
# Install axios
npm install axios
```

### Common Axios Methods

```javascript
import axios from 'axios'

// GET request
const getProducts = async () => {
  const response = await axios.get('/api/products')
  return response.data
}

// POST request
const createProduct = async (product) => {
  const response = await axios.post('/api/products', product)
  return response.data
}

// PUT request
const updateProduct = async (id, product) => {
  const response = await axios.put(`/api/products/${id}`, product)
  return response.data
}

// DELETE request
const deleteProduct = async (id) => {
  await axios.delete(`/api/products/${id}`)
}
```

### Environment Variables

```bash
# .env file
VITE_API_URL=http://localhost:8080/api

# In production (Kubernetes)
VITE_API_URL=http://java-api:8080/api
```

---

## Building the UI

### Step 1: Install Dependencies

```bash
cd node-frontend
npm install
```

### Step 2: Development Server

```bash
# Start development server
npm run dev

# Runs on http://localhost:5173 (Vite default)
```

### Step 3: Build for Production

```bash
# Create production build
npm run build

# Output in dist/ folder
```

### Step 4: Preview Production Build

```bash
# Preview the production build
npm run preview
```

---

## Vite Configuration

```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true,
    proxy: {
      '/api': {
        target: 'http://java-api:8080',
        changeOrigin: true
      }
    }
  }
})
```

**What the proxy does:**
- When you request `/api/products`
- Vite forwards to `http://java-api:8080/api/products`

---

## Nginx Configuration

Nginx acts as a **reverse proxy** and **static file server**:

```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # Serve static files
        location / {
            try_files $uri $uri/ /index.html;
        }

        # Proxy API requests to backend
        location /api {
            proxy_pass http://java-api:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

### Key Nginx Concepts

| Directive | Purpose |
|-----------|---------|
| `root` | Directory to serve files from |
| `index` | Default file to serve |
| `try_files` | Check if file exists, fallback to index.html |
| `proxy_pass` | Forward requests to another server |

---

## Dockerizing the Frontend

### Multi-stage Build

```dockerfile
# Stage 1: Build the React app
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Build and Run

```bash
# Build image
docker build -t node-frontend:latest ./node-frontend

# Run container
docker run -p 3000:80 node-frontend:latest

# Access at http://localhost:3000
```

---

## Summary

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                  FREND-END FLOW                            │
│                                                             │
│   User opens browser                                        │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────────────────────────────────────┐ │
│   │ Nginx (Port 80)                                     │ │
│   │ - Serves static React files                         │ │
│   │ - Proxies /api to backend                           │ │
│   └─────────────────────────────────────────────────────┘ │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────────────────────────────────────┐ │
│   │ React Components                                    │ │
│   │ - App.jsx renders UI                                │ │
│   │ - useState manages data                            │ │
│   │ - useEffect fetches data                           │ │
│   └─────────────────────────────────────────────────────┘ │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────────────────────────────────────┐ │
│   │ Axios (HTTP Client)                                │ │
│   │ - Makes API calls to backend                       │ │
│   └─────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Takeaways

1. **React** - Component-based UI library
2. **Vite** - Fast build tool
3. **Axios** - HTTP client for API calls
4. **Nginx** - Reverse proxy in production
5. **Docker** - Containerization for deployment

---

## Next Steps

- **[05-Database](./05-database.md)** - Connect to MySQL
- **[06-Docker](./06-docker.md)** - Deep dive into containers
- **[07-Kubernetes](./07-kubernetes.md)** - Deploy to K8s
