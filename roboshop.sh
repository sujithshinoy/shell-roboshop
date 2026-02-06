#!/bin/bash/

SG_ID="sg-0310cfa82e8e5f6c3" # replace with you ID
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do
 aws ec2 run-instances 
 --image-id $AMI_ID \
 --instance-type t3.micro \ 
 --security-group-ids $SG_ID \ 
 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \ 
 --query 'Instances[0].InstanceId' \
 --output text  

done

