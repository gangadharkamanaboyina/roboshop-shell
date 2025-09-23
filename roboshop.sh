#!/bin/bash

for instance in "$@"; 
do
      InstanceId=$(aws ec2 run-instances \
  --image-id ami-09c813fb71547fc4f \
  --instance-type t3.micro \
  --security-groups allow-all \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query "Instances[0].InstanceId" \
  --output text)

  if[[ $instance=="frontend" ]]; then

        IP=$(aws ec2 describe-instances \
  --instance-ids $InstanceId \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text)

  else

        IP$(aws ec2 describe-instances \
  --instance-ids $InstanceId \
  --query "Reservations[*].Instances[*].PrivateIpAddress" \
  --output text)
  fi

  echo "$instance: $IP"

done
