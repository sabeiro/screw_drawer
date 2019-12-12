package com.databricks.apps.logs.chapter2;

import com.databricks.apps.logs.ApacheAccessLog;
import com.databricks.apps.logs.LogAnalyzerRDD;
import com.databricks.apps.logs.LogStatistics;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.api.java.JavaSQLContext;

val data = sparkContext.textFile("s3n://yourAccessKey:yourSecretKey@/path/")
val x = sc.textFile("s3n://b-datasets/flight_data/*") // we can just specify all the files.
x.take(5) // to make sure we read it correctly
x.saveAsTextFile("s3n://b-datasets/flight_data2/")
x = sc.textFile("s3n://b-datasets/flight_data/*") # we can just specify all the files.
x.take(5) # to make sure we read it correctly
x.saveAsTextFile("s3n://b-datasets/flight_data2/")


    
public class LogAnalyzerBatchImport {
  public static void main(String[] args) {
    SparkConf conf = new SparkConf().setAppName("Log Analyzer SQL");
    JavaSparkContext sc = new JavaSparkContext(conf);
    JavaSQLContext sqlContext = new JavaSQLContext(sc);

    if (args.length == 0) {
      System.out.println("Must specify an access logs file.");
      System.exit(-1);
    }
    String logFile = args[0];
    JavaRDD<ApacheAccessLog> accessLogs = sc.textFile(logFile)
        .map(ApacheAccessLog::parseFromLogLine);

    LogAnalyzerRDD logAnalyzerRDD = new LogAnalyzerRDD(sqlContext);
    LogStatistics logStatistics = logAnalyzerRDD.processRdd(accessLogs);
    logStatistics.printToStandardOut();

    sc.stop();
  }
}

jssc.hadoopConfiguration().set("fs.s3n.awsAccessKeyId", YOUR_ACCESS_KEY)
jssc.hadoopConfiguration().set("fs.s3n.awsSecretAccessKey", YOUR_SECRET_KEY)
