// Encoders for most common types are automatically provided by importing spark.implicits._
import spark.implicits._

val peopleDF = spark.read.json("examples/src/main/resources/people.json")

// DataFrames can be saved as Parquet files, maintaining the schema information
peopleDF.write.parquet("people.parquet")

// Read in the parquet file created above
// Parquet files are self-describing so the schema is preserved
// The result of loading a Parquet file is also a DataFrame
val parquetFileDF = spark.read.parquet("people.parquet")

// Parquet files can also be used to create a temporary view and then used in SQL statements
parquetFileDF.createOrReplaceTempView("parquetFile")
val namesDF = spark.sql("SELECT name FROM parquetFile WHERE age BETWEEN 13 AND 19")
namesDF.map(attributes => "Name: " + attributes(0)).show()
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+



def convert(sqlContext: SQLContext, filename: String, schema: StructType, tablename: String) {
      // import text-based table first into a data frame.
      // make sure to use com.databricks:spark-csv version 1.3+ 
      // which has consistent treatment of empty strings as nulls.
      val df = sqlContext.read
        .format("com.databricks.spark.csv")
        .schema(schema)
        .option("delimiter","|")
        .option("nullValue","")
        .option("treatEmptyValuesAsNulls","true")
        .load(filename)
      // now simply write to a parquet file
      df.write.parquet("/user/spark/data/parquet1000g/"+tablename)
  }

  // usage exampe -- a tpc-ds table called catalog_page
  schema= StructType(Array(
          StructField("cp_catalog_page_sk",        IntegerType,false),
          StructField("cp_catalog_page_id",        StringType,false),
          StructField("cp_start_date_sk",          IntegerType,true),
          StructField("cp_end_date_sk",            IntegerType,true),
          StructField("cp_department",             StringType,true),
          StructField("cp_catalog_number",         LongType,true),
          StructField("cp_catalog_page_number",    LongType,true),
          StructField("cp_description",            StringType,true),
          StructField("cp_type",                   StringType,true)))

  convert(sqlContext,
          hadoopdsPath+"/catalog_page/*",
          schema,
          "catalog_page")



parquetWriter = new AvroParquetWriter(outputPath,
          avroSchema, compressionCodecName, blockSize, pageSize);



public class Avro2Parquet extends Configured implements Tool {
 
    public int run(String[] args) throws Exception {
        // all paths in HDFS
        // path to Avro schema file (.avsc)
        Path schemaPath = new Path(args[0]);
        Path inputPath = new Path(args[1]);
        Path outputPath = new Path(args[2]);
 
        Job job = new Job(getConf());
        job.setJarByClass(getClass());
        Configuration conf = job.getConfiguration();
 
        // read in the Avro schema
        FileSystem fs = FileSystem.get(conf);
        InputStream in = fs.open(schemaPath);
        Schema avroSchema = new Schema.Parser().parse(in);
 
        // point to input data
        FileInputFormat.addInputPath(job, inputPath);
        job.setInputFormatClass(AvroKeyInputFormat.class);
 
        // set the output format
        job.setOutputFormatClass(AvroParquetOutputFormat.class);
        AvroParquetOutputFormat.setOutputPath(job, outputPath);
        AvroParquetOutputFormat.setSchema(job, avroSchema);
        AvroParquetOutputFormat.setCompression(job, CompressionCodecName.SNAPPY);
        AvroParquetOutputFormat.setCompressOutput(job, true);
 
        // set a large block size to ensure a single row group.  see discussion
        AvroParquetOutputFormat.setBlockSize(job, 500 * 1024 * 1024);
 
        job.setMapperClass(Avro2ParquetMapper.class);
        job.setNumReduceTasks(0);
 
        return job.waitForCompletion(true) ? 0 : 1;
    }
 
    public static void main(String[] args) throws Exception {
        int exitCode = ToolRunner.run(new Avro2Parquet(), args);
        System.exit(exitCode);
    }
}

public class Avro2ParquetMapper extends
        Mapper<Something, NullWritable, Void, GenericRecord> {
 
    @Override
    protected void map(AvroKey key, NullWritable value,
            Context context) throws IOException, InterruptedException {
        context.write(null, key.datum());
    }
}
