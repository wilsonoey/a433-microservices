#!/bin/bash

# Set variables
PROJECT_ID="qwiklabs-gcp-01-9316f5defaff"
REGION="us-central1"
ZONE="us-central1-a"
BUCKET_NAME="qwiklabs-gcp-01-9316f5defaff-bucket"
PUBSUB_TOPIC="topic-memories-268"
FUNCTION_NAME="memories-thumbnail-creator"
ENTRY_POINT="memories-thumbnail-creator"
IMAGE_URL="https://storage.googleapis.com/cloud-training/gsp315/map.jpg"
IMAGE_NAME="map.jpg"

# Task 1: Create a bucket
echo "Creating bucket..."
gsutil mb -l $REGION gs://$BUCKET_NAME

# Task 2: Create a Pub/Sub topic
echo "Creating Pub/Sub topic..."
gcloud pubsub topics create $PUBSUB_TOPIC

# Task 3: Create the thumbnail Cloud Function
echo "Creating Cloud Function..."
mkdir function
cat <<EOF > function/index.js
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('createThumbnail', cloudEvent => {
  const event = cloudEvent.data;
  console.log(\`Event: \${event}\`);
  console.log(\`Hello \${event.bucket}\`);
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64";
  const bucket = gcs.bucket(bucketName);
  const topicName = "$PUBSUB_TOPIC";
  const pubsub = new PubSub();

  if (fileName.search("64x64_thumbnail") == -1) {
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length);

    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg') {
      console.log(\`Processing Original: gs://\${bucketName}/\${fileName}\`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);

      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(\`Error: \${err}\`);
            reject(err);
          })
          .on("finish", () => {
            console.log(\`Success: \${fileName} → \${newFilename}\`);
            gcsNewObject.setMetadata(
              { contentType: 'image/' + filename_ext.toLowerCase() },
              function (err, apiResponse) { }
            );
            pubsub
              .topic(topicName)
              .publisher()
              .publish(Buffer.from(newFilename))
              .then(messageId => {
                console.log(\`Message \${messageId} published.\`);
              })
              .catch(err => {
                console.error('ERROR:', err);
              });
          });
      });
    } else {
      console.log(\`gs://\${bucketName}/\${fileName} is not an image I can handle\`);
    }
  } else {
    console.log(\`gs://\${bucketName}/\${fileName} already has a thumbnail\`);
  }
});
EOF

cat <<EOF > function/package.json
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
    "@google-cloud/pubsub": "^2.0.0",
    "@google-cloud/storage": "^5.0.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}
EOF

gcloud functions deploy $FUNCTION_NAME \
  --region=$REGION \
  --runtime=nodejs16 \
  --source=function \
  --entry-point=$ENTRY_POINT \
  --trigger-resource=gs://$BUCKET_NAME \
  --trigger-event=google.storage.object.finalize \
  --gen2

# Task 4: Test the infrastructure
echo "Uploading test image..."
wget $IMAGE_URL -O $IMAGE_NAME
gsutil cp $IMAGE_NAME gs://$BUCKET_NAME/

# Task 5: Remove the previous cloud engineer
echo "Removing previous cloud engineer..."
gcloud projects remove-iam-policy-binding $PROJECT_ID \
  --member='user:previous_engineer@example.com' \
  --role='roles/viewer'

echo "Script execution completed."
