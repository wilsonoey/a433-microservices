export ZONE=us-east4-b
export REGION=us-east4

gcloud config set project qwiklabs-gcp-00-8869f7b1bdf6

gcloud dataproc clusters create example-cluster \
  --region=$REGION \
  --zone=$ZONE \
  --master-machine-type=e2-standard-2 \
  --master-boot-disk-size=50GB \
  --num-workers=2 \
  --worker-machine-type=e2-standard-2 \
  --worker-boot-disk-size=50GB

gcloud dataproc jobs submit spark \
  --region=$REGION \
  --cluster=example-cluster \
  --class=org.apache.spark.examples.SparkPi \
  --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
  -- 1000

gcloud dataproc clusters update example-cluster \
  --num-workers=4 \
  --region=$REGION
