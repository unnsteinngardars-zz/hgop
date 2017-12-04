#!/bin/bash -xv
#security grop name, image id and ec2_instance dir variables set
USERNAME=$(aws iam get-user --query 'User.UserName' --output text)
PEM_NAME=hgop-${USERNAME}
JENKINS_SECURITY_GROUP=jenkins-${USERNAME}
IMAGE_ID="ami-15e9c770"
INSTANCE_DIR="ec2_instance"

#exit ec2_instance dir exists
if [ -d "${INSTANCE_DIR}" ]; then
    exit
fi

#create ec2_instance dir
[ -d "${INSTANCE_DIR}" ] || mkdir ${INSTANCE_DIR}

#creates security-grou-name.txt file in ec2_instance folder
echo ${JENKINS_SECURITY_GROUP} > ./ec2_instance/jenkins-security-group.txt
echo ${PEM_NAME} > ./ec2_instance/pem.txt

#create aws ec2 key-pair and changes modification on file to fix permission issues
#creates security-group-name.pem file for later use with accessing aws machine
echo "create key-pair for $JENKINS_SECURITY_GROUP"
aws ec2 create-key-pair --key-name ${PEM_NAME} --query 'KeyMaterial' --output text > ${INSTANCE_DIR}/${PEM_NAME}.pem
chmod 400 ${INSTANCE_DIR}/${PEM_NAME}.pem
echo "$PEM_NAME.pem created successfully"

#get security group id from security group from created in the command
echo "create security group $JENKINS_SECURITY_GROUP"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name ${JENKINS_SECURITY_GROUP} --description "security group for dev environment in EC2" --query "GroupId"  --output=text)
echo ${SECURITY_GROUP_ID} > ./ec2_instance/security-group-id.txt
echo "$JENKINS_SECURITY_GROUP created successfully"

#get public ip from amazon
echo "fetching amazon public ip to create CIDR"
MY_PUBLIC_IP=$(curl http://checkip.amazonaws.com)
#concatenate public ip address and port number
MY_CIDR=${MY_PUBLIC_IP}/32
echo "CIDR: $MY_CIDR, created successfully"

#authorize security group
echo "authorizing $JENKINS_SECURITY_GROUP and adding tcp protocols for http and ssh"
set +e
aws ec2 authorize-security-group-ingress --group-name ${JENKINS_SECURITY_GROUP} --protocol tcp --port 80 --cidr ${MY_CIDR}
aws ec2 authorize-security-group-ingress --group-name ${JENKINS_SECURITY_GROUP} --protocol tcp --port 22 --cidr ${MY_CIDR}
aws ec2 authorize-security-group-ingress --group-name ${JENKINS_SECURITY_GROUP} --protocol tcp --port 8080 --cidr ${MY_CIDR}
set -e

#run an instance from a seperated instance init script and fetch the generated instance key
echo "execute ec2-instance-init script and fetch instance ID"
INSTANCE_ID=$(aws ec2 run-instances --user-data file://ec2-instance-init.sh --image-id ${IMAGE_ID} --security-group-ids ${SECURITY_GROUP_ID} --count 1 --instance-type t2.micro --key-name ${PEM_NAME} --query 'Instances[0].InstanceId'  --output=text)
echo ${INSTANCE_ID} > ./ec2_instance/instance-id.txt
echo "instance ID: $INSTANCE_ID, fetched successfully"

#export instance on aws ec2 and creates instance-public-name.txt in ec2_instance
echo "export instance"
aws ec2 wait --region us-east-2 instance-running --instance-ids ${INSTANCE_ID}
export INSTANCE_PUBLIC_NAME=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --query "Reservations[*].Instances[*].PublicDnsName" --output=text)
echo ${INSTANCE_PUBLIC_NAME} > ./ec2_instance/instance-public-name.txt
echo "$INSTANCE_PUBLIC_NAME exported successfully"

echo "Waiting for connection to instance"
status='unknown'
while [ ! "${status}" == "ok" ]
do
   status=$(ssh -i "./ec2_instance/${PEM_NAME}.pem"  -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 ec2-user@${INSTANCE_PUBLIC_NAME} echo ok 2>&1)
   sleep 2
done

set +e
scp -o StrictHostKeyChecking=no -i "./ec2_instance/${PEM_NAME}.pem" ec2-user@$(cat ./ec2_instance/instance-public-name.txt):/var/log/cloud-init-output.log ./ec2_instance/cloud-init-output.log
scp -o StrictHostKeyChecking=no -i "./ec2_instance/${PEM_NAME}.pem" ec2-user@$(cat ./ec2_instance/instance-public-name.txt):/var/log/user-data.log ./ec2_instance/user-data.log

aws ec2 associate-iam-instance-profile --instance-id $(cat ./ec2_instance/instance-id.txt) --iam-instance-profile Name=CICDServer-Instance-Profile
