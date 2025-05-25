from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("products_job").getOrCreate()

df = spark.read.jdbc(
    url="jdbc:postgresql://postgres:5432/demo",
    table="products",
    properties={
        "user": "postgres",
        "password": "postgres",
        "driver": "org.postgresql.Driver"
    }
)

result = df.groupBy("brand").count()
result.show()

spark.stop()
