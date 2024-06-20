cd ~/user-authentication-with-iap/3-HelloVerifiedUser
sed -i 's/python37/python39/g' app.yaml
gcloud app deploy
LINK=$(gcloud app browse)
LINKU=${LINK#https://}
cat > details.json << EOF
{
  App name: IAP Example
  Application home page: $LINK
  Application privacy Policy link: $LINK/privacy
  Authorized domains: $LINKU
  Developer Contact Information: techvinechannel@gmail.com
}
EOF
cat details.json
