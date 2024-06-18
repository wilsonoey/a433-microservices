export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME=$(gcloud config get-value project)

gcloud config set compute/region REGION

mkdir gcf_hello_world

cd gcf_hello_world

cat > index.js <<EOF_CP
/**
* Background Cloud Function to be triggered by Pub/Sub.
* This function is exported by index.js, and executed when
* the trigger topic receives a message.
*
* @param {object} data The event payload.
* @param {object} context The event metadata.
*/
exports.helloWorld = (data, context) => {
const pubSubMessage = data;
const name = pubSubMessage.data ? Buffer.from(pubSubMessage.data, 'base64').toString() : "Hello World";
console.log(`My Cloud Function: ${name}`);
};
EOF_CP

gsutil mb -p ${PROJECT_ID} gs://${BUCKET_NAME}

gcloud services disable cloudfunctions.googleapis.com

gcloud services enable cloudfunctions.googleapis.com

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member="serviceAccount:${PROJECT_ID}@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"

gcloud functions deploy helloWorld \
  --stage-bucket ${BUCKET_NAME} \
  --trigger-topic hello_world \
  --runtime nodejs20

gcloud functions describe helloWorld
