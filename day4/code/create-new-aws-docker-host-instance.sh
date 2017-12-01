#!/bin/bash
#security grop name, image id and ec2_instance dir variables set
SECURITY_GROUP_NAME="IheartAWS"
IMAGE_ID="ami-15e9c770"
INSTANCE_DIR="ec2_instance"

#exit ec2_instance dir exists
if [ -d "${INSTANCE_DIR}" ]; then
    exit
fi

#create ec2_instance dir
[ -d "${INSTANCE_DIR}" ] || mkdir ${INSTANCE_DIR}

#creates security-grou-name.txt file in ec2_instance folder
echo ${SECURITY_GROUP_NAME} > ./ec2_instance/security-group-name.txt

#create aws ec2 key-pair and changes modification on file to fix permission issues
#creates security-group-name.pem file for later use with accessing aws machine
echo "create key-pair for $SECURITY_GROUP_NAME"
aws ec2 create-key-pair --key-name ${SECURITY_GROUP_NAME} --query 'KeyMaterial' --output text > ${INSTANCE_DIR}/${SECURITY_GROUP_NAME}.pem
chmod 400 ${INSTANCE_DIR}/${SECURITY_GROUP_NAME}.pem
echo "$SECURITY_GROUP_NAME.pem created successfully"

#get security group id from security group from created in the command
echo "create security group $SECURITY_GROUP_NAME"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name ${SECURITY_GROUP_NAME} --description "security group for dev environment in EC2" --query "GroupId"  --output=text)
echo ${SECURITY_GROUP_ID} > ./ec2_instance/security-group-id.txt
echo "$SECURITY_GROUP_NAME created successfully"

#get public ip from amazon
echo "fetching amazon public ip to create CIDR"
MY_PUBLIC_IP=$(curl http://checkip.amazonaws.com)
#concatenate public ip address and port number
MY_CIDR=${MY_PUBLIC_IP}/32
echo "CIDR: $MY_CIDR, created successfully"

#authorize security group
echo "authorizing $SECURITY_GROUP_NAME and adding tcp protocols for http and ssh"
aws ec2 authorize-security-group-ingress --group-name ${SECURITY_GROUP_NAME} --protocol tcp --port 80 --cidr ${MY_CIDR}
aws ec2 authorize-security-group-ingress --group-name ${SECURITY_GROUP_NAME} --protocol tcp --port 22 --cidr ${MY_CIDR}

#run an instance from a seperated instance init script and fetch the generated instance key
echo "execute ec2-instance-init script and fetch instance ID"
INSTANCE_ID=$(aws ec2 run-instances --user-data file://ec2-instance-init.sh --image-id ${IMAGE_ID} --security-group-ids ${SECURITY_GROUP_ID} --count 1 --instance-type t2.micro --key-name ${SECURITY_GROUP_NAME} --query 'Instances[0].InstanceId'  --output=text)
echo ${INSTANCE_ID} > ./ec2_instance/instance-id.txt
echo "instance ID: $INSTANCE_ID, fetched successfully"

#export instance on aws ec2 and creates instance-public-name.txt in ec2_instance
echo "export instance"
aws ec2 wait --region us-east-2 instance-running --instance-ids ${INSTANCE_ID}
export INSTANCE_PUBLIC_NAME=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --query "Reservations[*].Instances[*].PublicDnsName" --output=text)
echo ${INSTANCE_PUBLIC_NAME} > ./ec2_instance/instance-public-name.txt
echo "$INSTANCE_PUBLIC_NAME exported successfully"
