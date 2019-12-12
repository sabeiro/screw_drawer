from pyspark.sql import SparkSession

spark = SparkSession \
    .builder \
    .appName("Python Spark SQL basic example") \
    .config("spark.some.config.option", "some-value") \
    .getOrCreate()

df = spark.read.json("examples/src/main/resources/people.json")
df.show()

val sqlDF = spark.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`")
