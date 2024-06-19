export YOURBUCKETNAME=1dntmmdmgdhmghdmgmdmmdmgdmghmghmdmdgmdg

export REGION=us-central1

gsutil mb gs://${YOURBUCKETNAME}

curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg

gsutil cp ada.jpg gs://${YOURBUCKETNAME}

rm ada.jpg

gsutil cp -r gs://${YOURBUCKETNAME}/ada.jpg .

gsutil cp gs://${YOURBUCKETNAME}/ada.jpg gs://${YOURBUCKETNAME}/image-folder/

gsutil ls gs://${YOURBUCKETNAME}

gsutil ls -l gs://${YOURBUCKETNAME}/ada.jpg

gsutil acl ch -u AllUsers:R gs://${YOURBUCKETNAME}/ada.jpg

gsutil acl ch -d AllUsers gs://${YOURBUCKETNAME}/ada.jpg

gsutil rm gs://${YOURBUCKETNAME}/ada.jpg
