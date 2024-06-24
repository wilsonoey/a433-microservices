export PROJECT_ID=$DEVSHELL_PROJECT_ID
export BUCKET=$PROJECT_ID

gsutil mb -p $PROJECT_ID \
    -c standard    \
    -l "REGION" \
    gs://${BUCKET}

gsutil -m cp -r gs://car_damage_lab_images/* gs://${BUCKET}

gsutil cp gs://car_damage_lab_metadata/data.csv .

sed -i -e "s/car_damage_lab_images/${BUCKET}/g" ./data.csv

cat ./data.csv

gsutil cp ./data.csv gs://${BUCKET}
