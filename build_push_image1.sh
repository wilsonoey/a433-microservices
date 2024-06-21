#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-west1"
ZONE="us-west1-c"
BASTION_TAG="bastion"
JUICE_SHOP_TAG="juice-shop"
ACME_MGMT_SUBNET="10.128.0.0/9"
INTERNAL_SSH_TAG="network-allow-ssh-internal-ingress-ql-819"
HTTP_TAG="network-allow-http-ingress-ql-819"

# Step 1: Remove overly permissive firewall rules
echo "Removing overly permissive firewall rules..."
# List all firewall rules and remove the ones that are overly permissive
# Assuming that overly permissive rules contain "allow-all" in their names
EXISTING_RULES=$(gcloud compute firewall-rules list --format="value(name)")
for RULE in $EXISTING_RULES; do
    if [[ $RULE == *"allow-all"* ]]; then
        gcloud compute firewall-rules delete $RULE --quiet
    fi
done

# Step 2: Start the bastion host instance
echo "Starting the bastion host instance..."
BASTION_INSTANCE=$(gcloud compute instances list --filter="tags.items:$BASTION_TAG" --format="value(name)")
gcloud compute instances start $BASTION_INSTANCE --zone=$ZONE

# Step 3: Create a firewall rule for SSH to bastion via IAP
echo "Creating firewall rule for SSH to bastion via IAP..."
gcloud compute firewall-rules create allow-ssh-iap-to-bastion \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges="35.235.240.0/20" \
    --target-tags=$BASTION_TAG

# Step 4: Create a firewall rule for HTTP traffic to juice-shop
echo "Creating firewall rule for HTTP traffic to juice-shop..."
gcloud compute firewall-rules create allow-http-to-juice-shop \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges="0.0.0.0/0" \
    --target-tags=$HTTP_TAG

# Step 5: Create a firewall rule for SSH from bastion to juice-shop
echo "Creating firewall rule for SSH from bastion to juice-shop..."
gcloud compute firewall-rules create allow-ssh-from-bastion-to-juice-shop \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=$ACME_MGMT_SUBNET \
    --target-tags=$INTERNAL_SSH_TAG

# Step 6: Assign tags to instances (if not already assigned)
echo "Assigning tags to instances..."
gcloud compute instances add-tags $BASTION_INSTANCE --tags=$BASTION_TAG --zone=$ZONE

JUICE_SHOP_INSTANCE=$(gcloud compute instances list --filter="tags.items:$JUICE_SHOP_TAG" --format="value(name)")
gcloud compute instances add-tags $JUICE_SHOP_INSTANCE --tags=$JUICE_SHOP_TAG,$INTERNAL_SSH_TAG,$HTTP_TAG --zone=$ZONE

# Verify the setup
echo "Verifying the setup..."
gcloud compute firewall-rules list --filter="name~'allow-'"

echo "Setup completed successfully."
