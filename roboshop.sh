#!/bin/bash

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
        IP=$(aws ec2 describe-instances \
            --instance-ids "$InstanceId" \
            --query "Reservations[*].Instances[*].PublicIpAddress" \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$InstanceId" \
            --query "Reservations[*].Instances[*].PrivateIpAddress" \
            --output text)
    fi

    echo "$instance: $IP"

    {
  "Comment": "Update record to new IP",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$instance.gangu.fun",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          { "Value": "1.2.3.4" }
        ]
      }
    }
  ]
}

done