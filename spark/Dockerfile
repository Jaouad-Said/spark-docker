# Fixed Spark Dockerfile with proper Jupyter setup
# spark/Dockerfile

ARG SPARK_VERSION=3.5.5
ARG PG_JDBC_VER=42.7.5

FROM apache/spark:${SPARK_VERSION}-scala2.12-java11-python3-ubuntu

# Switch to root for installations
USER root

# Update package manager and install necessary packages
RUN apt-get update && \
    apt-get install -y wget curl && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages including Jupyter
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Download PostgreSQL JDBC driver
ARG PG_JDBC_VER=42.7.5
RUN wget -O /opt/spark/jars/postgresql-${PG_JDBC_VER}.jar \
    https://jdbc.postgresql.org/download/postgresql-${PG_JDBC_VER}.jar && \
    chmod 644 /opt/spark/jars/postgresql-${PG_JDBC_VER}.jar

# Create workspace directory
WORKDIR /workspace
RUN mkdir -p /workspace/notebooks && \
    chown -R spark:spark /workspace

# Create proper home directory for spark user
RUN mkdir -p /home/spark && \
    chown -R spark:spark /home/spark

# Switch back to spark user
USER spark

# Set environment variables
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip:${PYTHONPATH}"
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS="lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --notebook-dir=/workspace/notebooks"

EXPOSE 4040 8888

# Default command to start Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--notebook-dir=/workspace/notebooks"]