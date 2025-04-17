#!/bin/bash

AMI_ID="ami-00b94073831733d2e"

# Lấy danh sách các region
regions=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)

echo "Checking AMI $AMI_ID across regions..."

for region in $regions; do
  result=$(aws ec2 describe-images \
    --image-ids $AMI_ID \
    --region $region \
    --query "Images[*].{ID:ImageId, Name:Name, Owner:OwnerId}" \
    --output text 2>/dev/null)

  if [[ ! -z "$result" ]]; then
    echo "Found in region: $region"
    echo "$result"
    echo "------------------------------"
  fi
done

