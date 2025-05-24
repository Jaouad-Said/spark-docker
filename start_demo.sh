#!/bin/bash
# Quick Start Script for Spark + PostgreSQL Demo
# Save this as: start_demo.sh

echo "🚀 Starting Spark + PostgreSQL Demo Environment..."
echo "================================================="

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose not found. Please install Docker Compose first."
    exit 1
fi

# Start the services
echo "📦 Starting containers..."
docker-compose up -d

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to initialize..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "🌐 Access Points:"
    echo "  - JupyterLab: http://localhost:8888"
    echo "  - Spark UI: http://localhost:4040 (when Spark jobs are running)"
    echo "  - PostgreSQL: localhost:5432"
    echo "    - User: sparkuser"
    echo "    - Password: sparkpass"
    echo "    - Database: demo"
    echo ""
    echo "📊 Sample Data Available:"
    echo "  - 5,000 customers"
    echo "  - 2,000 products" 
    echo "  - 25,000 orders"
    echo "  - Customer reviews and ratings"
    echo "  - Product categories and inventory"
    echo ""
    echo "🔧 Quick Commands:"
    echo "  View logs: docker-compose logs -f"
    echo "  Stop all: docker-compose down"
    echo "  Restart: docker-compose restart"
    echo ""
    echo "📚 Getting Started:"
    echo "  1. Open JupyterLab at http://localhost:8888"
    echo "  2. Upload the spark_analytics_examples.py notebook"
    echo "  3. Run the examples to explore your data!"
    echo ""
    echo "Happy analyzing! 🎉"
else
    echo "❌ Something went wrong. Check the logs:"
    docker-compose logs
fi