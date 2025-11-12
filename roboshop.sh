#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-075219685ee98df3d"
INSTANCE_TYPE="t3.micro"   # change if needed
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z02152192PADH0ABCE6WY"
DOMAIN_NAME="udaypappu.fun"

#for instance in "${INSTANCES[@]}"; 
for instance in $@
do
  unset INSTANCE_ID
  ERRFILE=$(mktemp)

  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" --output text 2>"$ERRFILE" || true)

  if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
    echo "Launch failed for $instance — reason: $(tr '\n' ' ' <"$ERRFILE")"
    rm -f "$ERRFILE"
    continue
  fi
  rm -f "$ERRFILE"

  echo "Launched $instance ($INSTANCE_ID). Waiting for running..."
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

  if [ "$instance" != "frontend" ]; 
  then
    IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
  else
    IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    RECORD_NAME="$DOMAIN_NAME"
  fi

  if [ -z "$IP" ] || [ "$IP" = "None" ]; then
    echo "No IP for $instance ($INSTANCE_ID) — skipping Route53 update."
    continue
  fi

  echo "$instance IP address is $IP"

  aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch '{
      "Comment": "Creating or updating a record for '"$instance"'",
      "Changes": [
        {
          "Action": "UPSERT",
          "ResourceRecordSet": {
            "Name": "'"$instance"'.'"$DOMAIN_NAME"'",
            "Type": "A",
            "TTL": 60,
            "ResourceRecords": [{"Value": "'"$IP"'"}]
          }
        }
      ]
    }'
done