#!/bin/bash
# Quick Start Script for Spark + Hadoop + PostgreSQL Demo
# Save this as: start_demo.sh

echo "🚀 Starting Spark + Hadoop + PostgreSQL Demo Environment..."
echo "=========================================================="

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose not found. Please install Docker Compose first."
    exit 1
fi

# Optional: check python for data generation scripts
if ! command -v python &> /dev/null; then
    echo "⚠️  Python not found. If you plan to auto-generate data files, please install Python."
fi

# Optional: check pip
if ! command -v pip &> /dev/null; then
    echo "⚠️  pip not found. For Python package installs (like Faker), install pip."
fi

# Start the services
echo "📦 Starting containers (Hadoop, Spark, PostgreSQL)..."
docker-compose up -d

# Wait for PostgreSQL and Hadoop to be ready
echo "⏳ Waiting for PostgreSQL and Hadoop to initialize..."
sleep 15

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ All services are running!"
    echo ""
    echo "🌐 Access Points:"
    echo "  - JupyterLab (PySpark): http://localhost:8888"
    echo "  - Spark Master UI:      http://localhost:8080"
    echo "  - HDFS NameNode UI:     http://localhost:9870"
    echo "  - YARN ResourceManager: http://localhost:8088"
    echo "  - PostgreSQL:           localhost:5432"
    echo "    - User: postgres"
    echo "    - Password: postgres"
    echo "    - Database: demo"
    echo ""
    echo "📊 Sample Data Available:"
    echo "  - Products table (200+ sample products)"
    echo "  - Categories table (5 categories)"
    echo ""
    echo "📁 Example Data Flow:"
    echo "  - Ingest CSV into HDFS"
    echo "  - Analyze and transform with Spark (via Jupyter or scripts)"
    echo "  - Store results in PostgreSQL"
    echo ""
    echo "🔧 Quick Commands:"
    echo "  View logs:   docker-compose logs -f"
    echo "  Stop all:    docker-compose down"
    echo "  Restart:     docker-compose restart"
    echo ""
    echo "📚 Getting Started:"
    echo "  1. Open JupyterLab at http://localhost:8888"
    echo "  2. Run the example notebooks (or Python scripts) for Spark analytics"
    echo "  3. Query your demo data in PostgreSQL or with Spark!"
    echo ""
    echo "Happy analyzing! 🎉"
else
    echo "❌ Something went wrong. Check the logs:"
    docker-compose logs
fi
