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
  const [apiStatus, setApiStatus] = useState('checking')

  useEffect(() => {
    checkApiHealth()
    fetchProducts()
  }, [])

  const checkApiHealth = async () => {
    try {
      await axios.get(`${API_URL}/health`, { timeout: 5000 })
      setApiStatus('up')
    } catch (err) {
      setApiStatus('down')
    }
  }

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
        <h1>🚀 EKS Microservices Dashboard</h1>
        <div className="status-badge">
          <span className={`status-dot ${apiStatus}`}></span>
          API: {apiStatus.toUpperCase()}
        </div>
      </header>

      <main className="main">
        <div className="stats">
          <div className="stat-card">
            <h3>Total Products</h3>
            <p className="stat-number">{products.length}</p>
          </div>
          <div className="stat-card">
            <h3>Total Value</h3>
            <p className="stat-number">
              ${products.reduce((sum, p) => sum + (p.price * p.quantity), 0).toFixed(2)}
            </p>
          </div>
        </div>

        <div className="actions">
          <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
            {showForm ? 'Cancel' : '+ Add Product'}
          </button>
        </div>

        {showForm && (
          <form className="product-form" onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="Product Name"
              value={newProduct.name}
              onChange={(e) => setNewProduct({...newProduct, name: e.target.value})}
              required
            />
            <input
              type="text"
              placeholder="Description"
              value={newProduct.description}
              onChange={(e) => setNewProduct({...newProduct, description: e.target.value})}
            />
            <input
              type="number"
              placeholder="Price"
              step="0.01"
              value={newProduct.price}
              onChange={(e) => setNewProduct({...newProduct, price: e.target.value})}
              required
            />
            <input
              type="number"
              placeholder="Quantity"
              value={newProduct.quantity}
              onChange={(e) => setNewProduct({...newProduct, quantity: e.target.value})}
              required
            />
            <button type="submit" className="btn-primary">Save Product</button>
          </form>
        )}

        {error && <div className="error">{error}</div>}

        {loading ? (
          <div className="loading">Loading...</div>
        ) : (
          <div className="product-grid">
            {products.map(product => (
              <div key={product.id} className="product-card">
                <h3>{product.name}</h3>
                <p>{product.description || 'No description'}</p>
                <div className="product-info">
                  <span className="price">${product.price}</span>
                  <span className="quantity">Qty: {product.quantity}</span>
                </div>
                <button className="btn-danger" onClick={() => handleDelete(product.id)}>
                  Delete
                </button>
              </div>
            ))}
            {products.length === 0 && (
              <p className="empty">No products yet. Add your first product!</p>
            )}
          </div>
        )}
      </main>

      <footer className="footer">
        <p>Deployed on AWS EKS | Kubernetes | Docker</p>
      </footer>
    </div>
  )
}

export default App
