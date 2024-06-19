gcloud services disable dataflow.googleapis.com
gcloud services enable dataflow.googleapis.com
bq mk taxirides
bq mk \
--time_partitioning_field timestamp \
--schema ride_id:string,point_idx:integer,latitude:float,longitude:float,\
timestamp:timestamp,meter_reading:float,meter_increment:float,ride_status:string,\
passenger_count:integer -t taxirides.realtime


export BUCKET_NAME=$(gcloud config get-value project)
gsutil mb gs://$BUCKET_NAME/

sleep 5m

gcloud dataflow jobs run iotflow \
    --gcs-location gs://dataflow-templates-us-central1/latest/PubSub_to_BigQuery \
    --region us-central1 \
    --worker-machine-type e2-medium \
    --staging-location gs://$BUCKET_NAME/temp \
    --parameters inputTopic=projects/pubsub-public-data/topics/taxirides-realtime,outputTableSpec=qwiklabs-gcp-01-a8e4883695c7:taxirides.realtime
