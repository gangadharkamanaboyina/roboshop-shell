#!/bin/bash

HOSTED_ZONE_ID="Z09642611L8N3EK9H86BE"
DOMAIN="gangu.fun"


for instance in "$@"; do
    InstanceId=$(aws ec2 run-instances \
        --image-id ami-09c813fb71547fc4f \
        --instance-type t3.micro \
        --security-groups allow-all \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    # if we want to wait for instance to be running
    # aws ec2 wait instance-running --instance-ids "$InstanceId"

    if [[ "$instance" == "frontend" ]]; then
        PublicIP=$(aws ec2 describe-instances \
            --instance-ids "$InstanceId" \
            --query "Reservations[*].Instances[*].PublicIpAddress" \
            --output text)

                  # Update Route 53 for front end with Public IP
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "{
          \"Comment\": \"Update $instance record\",
          \"Changes\": [
            {
              \"Action\": \"UPSERT\",
              \"ResourceRecordSet\": {
                \"Name\": \"$DOMAIN\",
                \"Type\": \"A\",
                \"TTL\": 1,
                \"ResourceRecords\": [{\"Value\": \"$PublicIP\"}]
              }
            }
          ]
        }"

    else
        PrivateIP=$(aws ec2 describe-instances \
            --instance-ids "$InstanceId" \
            --query "Reservations[*].Instances[*].PrivateIpAddress" \
            --output text)

                  # Update Route 53 for other instances with Private IP
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "{
          \"Comment\": \"Update $instance record\",
          \"Changes\": [
            {
              \"Action\": \"UPSERT\",
              \"ResourceRecordSet\": {
                \"Name\": \"$instance.$DOMAIN\",
                \"Type\": \"A\",
                \"TTL\": 1,
                \"ResourceRecords\": [{\"Value\": \"$PrivateIP\"}]
              }
            }
          ]
        }"

    fi

    echo "$instance: PublicIP is $PublicIP"
    echo "$instance: PrivateIP is $PrivateIP"

   
done