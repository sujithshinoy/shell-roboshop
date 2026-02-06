#!/bin/bash/

SG_ID="sg-0310cfa82e8e5f6c3" # replace with you ID
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z012461222YNWWRFVF52N"
DOMINA_NAME="sujithshinoy.online"

for instance in $@
do
 INSTANCE_ID =$(aws ec2 run-instances \ 
 --image-id $AMI_ID \
 --instance-type "t3.micro" \ 
 --security-group-ids $SG_ID \ 
 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \ 
 --query 'Instances[0].InstanceId' \
 --output text )

  if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="$DOMIAN_NAME"
    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
         RECORD_NAME="$instance.$DOMINA_NAME"  # mongodb.sujithshinoy.online
        
    fi    

   echo "IP address :$IP"

   aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
     {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '

    echo "record updated for $instance"


done

