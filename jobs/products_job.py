from pyspark.sql import SparkSession
import time

spark = SparkSession.builder \
    .appName("products_job") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# Database connection properties
db_props = {
    "user": "postgres",
    "password": "postgres",
    "driver": "org.postgresql.Driver"
}
db_url = "jdbc:postgresql://postgres:5432/demo"

# Read data
df = spark.read.jdbc(
    url=db_url,
    table="products",
    properties=db_props
)

# Job 1: Group by brand
print("Starting Job 1: Grouping by brand...")
result1 = df.groupBy("brand").count()
result1.show()

# Add delay to see RUNNING status in Spark UI
print("Adding 10 second delay...")
time.sleep(10)

# Job 2: More complex aggregation with delay
print("Starting Job 2: Complex aggregation...")
result2 = df.groupBy("brand") \
    .agg(
        {"price": "avg", "stock_quantity": "sum", "price": "max"}
    ) \
    .withColumnRenamed("avg(price)", "avg_price") \
    .withColumnRenamed("sum(stock_quantity)", "total_stock") \
    .withColumnRenamed("max(price)", "max_price")

# Cache to make operations slower and more visible
result2.cache()
result2.show()

# Job 3: Filter and aggregate with another delay
print("Adding another 5 second delay...")
time.sleep(5)

print("Starting Job 3: Expensive products analysis...")
from pyspark.sql.functions import count, avg

expensive_analysis = df.filter(df.price > 100) \
    .groupBy("brand") \
    .agg(
        count("price").alias("expensive_count"),
        avg("price").alias("avg_expensive_price")
    ) \
    .orderBy("expensive_count", ascending=False)

expensive_analysis.show()

print("All jobs completed!")
spark.stop()