import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node Amazon S3
AmazonS3_node1702265439517 = glueContext.create_dynamic_frame.from_catalog(
    database="nycitytaxi",
    table_name="week3",
    transformation_ctx="AmazonS3_node1702265439517",
)

# Script generated for node Change Schema
ChangeSchema_node1702265455460 = ApplyMapping.apply(
    frame=AmazonS3_node1702265439517,
    mappings=[
        ("vendorid", "long", "vendorid", "long"),
        ("lpep_pickup_datetime", "string", "lpep_pickup_datetime", "string"),
        ("lpep_dropoff_datetime", "string", "lpep_dropoff_datetime", "string"),
        ("store_and_fwd_flag", "string", "store_and_fwd_flag", "string"),
        ("ratecodeid", "long", "ratecodeid", "long"),
        ("pulocationid", "long", "pulocationid", "long"),
        ("dolocationid", "long", "dolocationid", "long"),
        ("passenger_count", "long", "passenger_count", "long"),
        ("trip_distance", "double", "trip_distance", "double"),
        ("fare_amount", "double", "fare_amount", "double"),
        ("extra", "double", "extra", "double"),
        ("mta_tax", "double", "mta_tax", "double"),
        ("tip_amount", "double", "tip_amount", "double"),
        ("tolls_amount", "double", "tolls_amount", "double"),
        ("ehail_fee", "string", "ehail_fee", "string"),
        ("improvement_surcharge", "double", "improvement_surcharge", "double"),
        ("total_amount", "double", "total_amount", "double"),
        ("payment_type", "long", "payment_type", "long"),
        ("trip_type", "long", "trip_type", "long"),
        ("congestion_surcharge", "double", "congestion_surcharge", "double"),
    ],
    transformation_ctx="ChangeSchema_node1702265455460",
)

# Script generated for node Amazon S3
AmazonS3_node1702265458985 = glueContext.write_dynamic_frame.from_options(
    frame=ChangeSchema_node1702265455460,
    connection_type="s3",
    format="glueparquet",
    connection_options={"path": "s3://${bucket_name}", "partitionKeys": []},
    format_options={"compression": "snappy"},
    transformation_ctx="AmazonS3_node1702265458985",
)

job.commit()
